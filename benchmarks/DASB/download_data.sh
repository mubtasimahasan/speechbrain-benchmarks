#!/bin/bash

# ============================================================
#   Speech Datasets Downloader (aria2c + manual instructions)
#   Target directory: ../../../datasets
# ============================================================

DATASET_DIR=../../../datasets
mkdir -p "$DATASET_DIR"
cd "$DATASET_DIR"

# Make sure aria2 is installed
# if ! command -v aria2c &> /dev/null; then
#     echo "aria2c not found. Installing..."
#     sudo apt update && sudo apt install -y aria2
# fi

# -------------------------- LibriSpeech --------------------------
echo "Downloading LibriSpeech subset..."
mkdir -p LibriSpeech && cd LibriSpeech

urls=(
  "https://openslr.trmal.net/resources/12/train-clean-100.tar.gz"
  "https://openslr.trmal.net/resources/12/dev-clean.tar.gz"
  "https://openslr.trmal.net/resources/12/test-clean.tar.gz"
  "https://openslr.trmal.net/resources/12/test-other.tar.gz"
)

for url in "${urls[@]}"; do
  echo "Downloading: $url"
  aria2c -x 16 -s 16 "$url"
done

cd ..

# -------------------------- SLURP --------------------------
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

# -------------------------- Common Voice Corpus --------------------------
echo "⚠️ Common Voice Corpus must be downloaded manually:"
echo "   Visit: https://commonvoice.mozilla.org/en"

# -------------------------- VoxCeleb1 --------------------------
echo "⚠️ VoxCeleb1 must be downloaded manually:"
echo "   Visit: http://www.robots.ox.ac.uk/~vgg/data/voxceleb/"

# -------------------------- IEMOCAP --------------------------
echo "⚠️ IEMOCAP dataset requires license agreement and must be requested:"
echo "   Visit: https://paperswithcode.com/dataset/iemocap"

# -------------------------- Speech Commands --------------------------
echo "Downloading Speech Commands..."
mkdir -p SpeechCommands && cd SpeechCommands
aria2c -x 16 -s 16 http://download.tensorflow.org/data/speech_commands_v0.02.tar.gz
cd ..

# -------------------------- VoiceBank --------------------------
echo "⚠️ VoiceBank dataset must be downloaded manually:"
echo "   Visit: https://datashare.ed.ac.uk/handle/10283/2791"
echo "   Required files:"
echo "     - clean_testset_wav.zip"
echo "     - clean_trainset_28spk_wav.zip"
echo "     - noisy_testset_wav.zip"
echo "     - noisy_trainset_28spk_wav.zip"

# -------------------------- Libri2Mix --------------------------
echo "Cloning LibriMix (for Libri2Mix)..."
git clone https://github.com/JorisCos/LibriMix
cd LibriMix
echo "⚠️ Run ./generate_librimix.sh storage_dir to prepare Libri2Mix after setting storage_dir"
cd ..

# -------------------------- LJSpeech --------------------------
echo "Downloading LJSpeech..."
mkdir -p LJSpeech && cd LJSpeech
aria2c -x 16 -s 16 https://data.keithito.com/data/speech/LJSpeech-1.1.tar.bz2
cd ..

echo "✅ All available datasets downloaded (or instructions printed for manual steps)."
echo "📂 Datasets are stored in: $DATASET_DIR"
