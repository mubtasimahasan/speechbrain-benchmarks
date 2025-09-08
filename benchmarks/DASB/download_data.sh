#!/bin/bash

# ============================================================
#   Speech Datasets Downloader (aria2c + manual instructions)
#   Target directory: /srv/scratch/tmp/datasets
# ============================================================

DATASET_DIR=/srv/tmp/datasets
mkdir -p "$DATASET_DIR"
cd "$DATASET_DIR"

# -------------------------- LibriSpeech --------------------------
echo "Downloading LibriSpeech subset..."

urls=(
  "https://openslr.trmal.net/resources/12/train-clean-100.tar.gz"
  "https://openslr.trmal.net/resources/12/dev-clean.tar.gz"
  "https://openslr.trmal.net/resources/12/test-clean.tar.gz"
  "https://openslr.trmal.net/resources/12/test-other.tar.gz"
)

for url in "${urls[@]}"; do
  file=$(basename "$url")
  echo "Downloading: $file"
  aria2c -x 16 -s 16 "$url"
  echo "Extracting: $file"
  tar -xvzf "$file"
  rm "$file"
done


-------------------------- SLURP --------------------------
echo "Downloading SLURP dataset..."
mkdir -p SLURP && cd SLURP
aria2c -x 16 -s 16 https://zenodo.org/record/4274930/files/slurp_real.tar.gz
aria2c -x 16 -s 16 https://zenodo.org/record/4274930/files/slurp_synth.tar.gz
tar -xvzf slurp_real.tar.gz
tar -xvzf slurp_synth.tar.gz
rm slurp_real.tar.gz slurp_synth.tar.gz
aria2c -x 16 -s 16 https://raw.githubusercontent.com/pswietojanski/slurp/master/dataset/slurp/devel.jsonl
aria2c -x 16 -s 16 https://raw.githubusercontent.com/pswietojanski/slurp/master/dataset/slurp/test.jsonl
aria2c -x 16 -s 16 https://raw.githubusercontent.com/pswietojanski/slurp/master/dataset/slurp/train.jsonl
cd ..

# -------------------------- Speech Commands --------------------------
echo "Downloading Speech Commands..."
mkdir -p SpeechCommands && cd SpeechCommands
aria2c -x 16 -s 16 http://download.tensorflow.org/data/speech_commands_v0.02.tar.gz
tar -xvzf speech_commands_v0.02.tar.gz
rm speech_commands_v0.02.tar.gz
cd ..

# # -------------------------- LJSpeech --------------------------
echo "Downloading LJSpeech..."
mkdir -p LJSpeech && cd LJSpeech
aria2c -x 16 -s 16 https://data.keithito.com/data/speech/LJSpeech-1.1.tar.bz2
tar -xvjf LJSpeech-1.1.tar.bz2
rm LJSpeech-1.1.tar.bz2
cd ..

# # -------------------------- Libri2Mix --------------------------
echo "Cloning LibriMix (for Libri2Mix)..."
git clone https://github.com/JorisCos/LibriMix
cd LibriMix
bash generate_librimix.sh storage_dir
cd ..

# -------------------------- Common Voice Corpus --------------------------
# echo "Download Common Voice Corpus manually:"
# echo "   https://commonvoice.mozilla.org/en"

# -------------------------- VoxCeleb1 --------------------------
# echo "Download VoxCeleb1 manually:"
# echo "   http://www.robots.ox.ac.uk/~vgg/data/voxceleb/"

# -------------------------- VoiceBank --------------------------
# echo "Download VoiceBank dataset manually:"
# echo "   https://datashare.ed.ac.uk/handle/10283/2791"
# echo "   Required files:"
# echo "     - clean_testset_wav.zip"
# echo "     - clean_trainset_28spk_wav.zip"
# echo "     - noisy_testset_wav.zip"
# echo "     - noisy_trainset_28spk_wav.zip"

# echo "All available datasets downloaded and extracted (manual ones commented)."
# echo "Datasets are stored in: $DATASET_DIR"
