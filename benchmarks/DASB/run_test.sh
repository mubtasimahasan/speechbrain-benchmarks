#!/bin/bash

export CODEC_PATH=/srv/workspace/mub/speech-rep-fusion
export CHECKPOINT_PATH=/srv/workspace/mub/speech-rep-fusion/saved_files/fusecodec_fusion
export SAVED_DIR=saved_files/output
export DATA_DIR=/tmp/datasets

export ORION_DB_TYPE=pickleddb
export ORION_DB_ADDRESS=$SAVED_DIR/results/speech_tokenizer/hopt/ASR-encodec-LSTM_hopt.pkl

export WANDB_API_KEY=

################### run extraction
python LibriSpeech/extraction/extract.py \
    LibriSpeech/extraction/hparams/speech_tokenizer.yaml \
    --data_folder=$DATA_DIR/LibriSpeech \
    --num_codebooks=8


################### LibriSpeech
python LibriSpeech/ASR/train.py \
    LibriSpeech/ASR/hparams/LSTM/train.yaml \
    --data_folder $SAVED_DIR/datasets/LibriSpeech \
    --cached_data_folder $SAVED_DIR/cache \
    --output_folder $SAVED_DIR/results/speech_tokenizer \
    --tokens_folder $SAVED_DIR/save/librispeech/ \
    --seed 1986 \
    --pretrain_embeddings_folder $SAVED_DIR/save/embeddings/

################### tune hyperparameter
bash run_hparam_optimization.sh \
  --exp_name "ASR-encodec-LSTM_hopt" \
  --hparams LibriSpeech/ASR/hparams/LSTM/train.yaml \
  --data_folder $DATA_DIR/LibriSpeech \
  --cached_data_folder $SAVED_DIR/cache \
  --output_folder $SAVED_DIR/results/speech_tokenizer \
  --task ASR \
  --dataset LibriSpeech \
  --seed 1986 \
  --nruns 1 \
  --nruns_eval 5 \
  --eval_metric WER \
  --exp_max_trials 20 \
  --tokens_folder $SAVED_DIR/save/librispeech/ \
  --run_name fusion \
  --pretrain_embeddings_folder $SAVED_DIR/save/embeddings/


## Slurp
# python SLURP/intent_classification/LSTM_linear/train_speech_tokenizer.py \
#     SLURP/intent_classification/LSTM_linear/hparams/train_speech_tokenizer.yaml \
#     --output_folder /teamspace/studios/this_studio/output \
#     --data_folder /teamspace/studios/this_studio/datasets/slurp

