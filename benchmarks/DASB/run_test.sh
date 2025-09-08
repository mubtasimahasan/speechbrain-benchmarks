#!/bin/bash

export CODEC_PATH=/srv/scratch/mub/speech-rep-fusion
export CHECKPOINT_PATH=/srv/scratch/mub/speech-rep-fusion/saved_files/fusecodec_fusion
export SAVED_DIR=/srv/tmp

export WANDB_API_KEY=

## run extraction
# python LibriSpeech/extraction/extract.py \
#     LibriSpeech/extraction/hparams/speech_tokenizer.yaml \
#     --data_folder=$SAVED_DIR/datasets/LibriSpeech \
#     --num_codebooks=8


## LibriSpeech
python LibriSpeech/ASR/train.py \
    LibriSpeech/ASR/hparams/LSTM/train.yaml \
    --data_folder $SAVED_DIR/datasets/LibriSpeech \
    --cached_data_folder $SAVED_DIR/output/cache \
    --output_folder $SAVED_DIR/output/results/speech_tokenizer \
    --tokens_folder $SAVED_DIR/output/save/librispeech/ \
    --seed 1986


## Slurp
# python SLURP/intent_classification/LSTM_linear/train_speech_tokenizer.py \
#     SLURP/intent_classification/LSTM_linear/hparams/train_speech_tokenizer.yaml \
#     --output_folder /teamspace/studios/this_studio/output \
#     --data_folder /teamspace/studios/this_studio/datasets/slurp

