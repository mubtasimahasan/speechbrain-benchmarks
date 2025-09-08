"""This lobe enables the integration of pretrained SpeechTokenizer.

Please, install speechtokenizer:
    pip install speechtokenizer

Reference: https://arxiv.org/abs/2308.16692

Transformer from HuggingFace needs to be installed:
https://huggingface.co/transformers/installation.html

Author
 * Pooneh Mousavi 2023

"""

import torch
import torch.nn as nn
from huggingface_hub import snapshot_download
import os

class SpeechTokenizer(nn.Module):
    """This lobe enables the integration of HuggingFace and SpeechBrain
    pretrained SpeechTokenizer.

    Please, install speechtokenizer:
    pip install speechtokenizer

    Source paper: https://arxiv.org/abs/2308.16692


    The model can be used as a fixed Discrete feature extractor or can be finetuned. It
    will download automatically the model from HuggingFace or use a local path.

    Arguments
    ---------
    source : str
        HuggingFace hub name: e.g "fnlp/SpeechTokenizer"
    save_path : str
        Path (dir) of the downloaded model.
    sample_rate : int (default: 16000)
        The audio sampling rate

    Example
    -------
    >>> import torch
    >>> inputs = torch.rand([10, 600])
    >>> model_hub = "fnlp/SpeechTokenizer"
    >>> save_path = "savedir"
    >>> model = SpeechTokenizer(model_hub, save_path)
    >>> tokens = model.encode(inputs)
    >>> tokens.shape
    torch.Size([8, 10, 2])
    >>> wav = model.decode(tokens)
    >>> wav.shape
    torch.Size([10, 640])
    """

    def __init__(
        self,
        source,
        save_path,
        sample_rate=16000,
    ):

        super().__init__()
        
        if os.path.isdir(source):
            import sys
            module_path = os.environ.get("CODEC_PATH")
            if module_path is None:
                raise ValueError("Please set SPEECH_TOKEN_MODIFIED env var")
            if module_path not in sys.path:
                sys.path.insert(0, module_path)
            from codec.model import Model as CodecModel

            # Local model
            saved_dir = source
            config_path = os.path.join(saved_dir, "config.json")
            ckpt_path = os.path.join(saved_dir, "Model_best_dev.pt")
            self.model = CodecModel.load_from_checkpoint(
                config_path, ckpt_path
            )
                        
        else:
            # Lazy import to avoid circular dependency issues
            try:
                from speechtokenizer import SpeechTokenizer
                self.SpeechTokenizer = SpeechTokenizer
            except ImportError:
                raise ImportError(
                    "Please install the speechtokenizer module using: "
                    "pip install speechtokenizer`"
                    "pip install beartype==0.1.1"
                )
    
            # download from HF Hub
            saved_dir = snapshot_download(
                repo_id=source,
                allow_patterns=["*config.json", "*SpeechTokenizer.pt"],
                cache_dir=save_path,
            )
            config_path = f"{saved_dir}/speechtokenizer_hubert_avg/config.json"
            ckpt_path = f"{saved_dir}/speechtokenizer_hubert_avg/SpeechTokenizer.pt"
            self.model = self.SpeechTokenizer.load_from_checkpoint(
                config_path, ckpt_path
            )

        self.model.eval()
        self.sample_rate = sample_rate

    def forward(self, wav, wav_lens=None):
        """Takes an input waveform and return its corresponding wav2vec encoding.

        Arguments
        ---------
        wav : torch.Tensor (signal)
            A batch of audio signals to transform to features.
        wav_lens : torch.Tensor
            The relative length of the wav given in SpeechBrain format.

        Returns
        -------
        tokens : torch.Tensor
            A (N_q, Batch x Seq) tensor of audio tokens

        """
        return self.encode(wav, wav_lens)

    def encode(self, wav, wav_lens=None):
        """Takes an input waveform and return its corresponding wav2vec encoding.

        Arguments
        ---------
        wav : torch.Tensor (signal)
            A batch of audio signals to transform to features.
        wav_lens : torch.Tensor
            The relative length of the wav given in SpeechBrain format.

        Returns
        -------
        tokens : torch.Tensor
            A (N_q, Batch x Seq) tensor of audio tokens

        """
        # Extract discrete codes from SpeechTokenizer
        with torch.no_grad():
            codes = self.model.encode(wav.unsqueeze(1))  # codes: (n_q, B, T)

        return codes

    def decode(self, codes):
        """Takes an input waveform and return its corresponding wav2vec encoding.

        Arguments
        ---------
        codes : torch.Tensor
            A (N_q, Batch x Seq) tensor of audio tokens

        Returns
        -------
        wav : torch.Tensor (signal)
            A batch of reconstructed audio signals.
        """

        RVQ_1 = codes[
            :1, :, :
        ]  # Contain content info, can be considered as semantic tokens
        RVQ_supplement = codes[
            1:, :, :
        ]  # Contain timbre info, complete info lost by the first quantizer

        # Concatenating semantic tokens (RVQ_1) and supplementary timbre tokens and then decoding
        wav = self.model.decode(torch.cat([RVQ_1, RVQ_supplement], dim=0))

        # Decoding from RVQ-i:j tokens from the ith quantizers to the jth quantizers
        # wav = self.model.decode(codes[i: (j + 1)], st=i)
        return wav.squeeze(1)
