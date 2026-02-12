# Homebrew Tap for Cactus

[Cactus](https://github.com/cactus-compute/cactus) is an energy-efficient AI inference engine for running LLMs on consumer devices.

## Install

```bash
brew install cactus-compute/cactus/cactus
```

## Usage

```bash
# Download a model and start chatting
cactus download LiquidAI/LFM2-1.2B
cactus run LiquidAI/LFM2-1.2B

# Transcription
cactus download UsefulSensors/moonshine-base
cactus transcribe                      # Live microphone
cactus transcribe --file audio.wav     # From file

# See all commands
cactus --help
```

## Supported Models

| Model | Size | Type |
|-------|------|------|
| LiquidAI/LFM2-1.2B | ~500MB | Chat |
| LiquidAI/LFM2-350M | ~150MB | Chat |
| google/gemma-3-1b-it | ~500MB | Chat |
| UsefulSensors/moonshine-base | ~100MB | Speech |

For the full list see the [Cactus README](https://github.com/cactus-compute/cactus#supported-models).

## Updating the Formula

```bash
# 1. Get SHA256 for the new release tag
curl -sL https://github.com/cactus-compute/cactus/archive/refs/tags/<TAG>.tar.gz | shasum -a 256

# 2. Update Formula/cactus.rb with the new URL and SHA256

# 3. Push
git add . && git commit -m "Update cactus" && git push origin main
```

## Uninstalling

`brew uninstall cactus && brew untap cactus-compute/cactus`