#!/bin/bash

export CODEC_PATH=/srv/scratch/mub/speech-rep-fusion
export CHECKPOINT_PATH=/srv/scratch/mub/speech-rep-fusion/saved_files/fusecodec_fusion

export SAVED_DIR=/srv/scratch/tmp
mkdir -p $SCRATCH_DIR/data
mkdir -p $SCRATCH_DIR/cache
mkdir -p $SCRATCH_DIR/results

# python SLURP/intent_classification/LSTM_linear/train_speech_tokenizer.py \
#     SLURP/intent_classification/LSTM_linear/hparams/train_speech_tokenizer.yaml \
#     --output_folder /teamspace/studios/this_studio/output \
#     --data_folder /teamspace/studios/this_studio/datasets/slurp


## run extraction
python LibriSpeech/extraction/extract.py \
    LibriSpeech/extraction/hparams/speech_tokenizer.yaml \
    --data_folder=$SAVED_DIR/datasets/LibriSpeech \
    --num_codebooks=8

## LibriSpeech
bash run_experiments.sh \
    --hparams LibriSpeech/ASR/hparams/LSTM/train.yaml \
    --data_folder $SAVED_DIR/datasets/LibriSpeech \
    --cached_data_folder $SAVED_DIR/cache/ \
    --output_folder $SAVED_DIR/outputs/results/speech_tokenizer/save/librispeech \
    --task ASR --dataset LibriSpeech \
    --seed 1986 --nruns 2 --eval_metric WER \
    --tokens_folder $SAVED_DIR/data/LibriSpeech/extraction-emb/speech_tokenizer/save/librispeech/
