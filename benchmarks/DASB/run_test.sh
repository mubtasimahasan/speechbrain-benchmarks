export CODEC_PATH=/teamspace/studios/this_studio/speech-token-modified
export CHECKPOINT_PATH=/teamspace/studios/this_studio/speech-token-modified/saved_files/fusecodec_fusion


python SLURP/intent_classification/LSTM_linear/train_speech_tokenizer.py \
    SLURP/intent_classification/LSTM_linear/hparams/train_speech_tokenizer.yaml \
    --output_folder /teamspace/studios/this_studio/output \
    --data_folder /teamspace/studios/this_studio/datasets/slurp

# More will be updated later.