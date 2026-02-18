# Homebrew Tap for Cactus

[Cactus](https://github.com/cactus-compute/cactus) is an energy-efficient AI inference engine for running LLMs on consumer devices.

## Install

```bash
brew install cactus-compute/cactus/cactus
```

## Usage

```bash
cactus download LiquidAI/LFM2-1.2B
cactus run LiquidAI/LFM2-1.2B

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

## Releasing a New Version

Releases are automated via GitHub Actions in the [cactus repo](https://github.com/cactus-compute/cactus).
The workflow runs weekly (Mondays) and can also be triggered manually. It auto-increments the version tag (v1.7, v1.8, ...), creates a GitHub release, and updates this formula automatically.

### Manual release (from the cactus repo)

Go to **Actions → Release & Update Homebrew → Run workflow**. Optionally specify a version tag, or leave blank to auto-increment.

### Manual formula update (without the workflow)

```bash
# 1. Tag the cactus repo
cd /path/to/cactus
git tag dev
git push origin dev

# 2. Get SHA256 and update the formula
curl -sL https://github.com/cactus-compute/cactus/archive/refs/tags/v1.7-dev.tar.gz | shasum -a 256

# Edit Formula/cactus.rb — update the url and sha256 fields

cd /path/to/homebrew-cactus
git add . && git commit -m "Update cactus" && git push origin main
```

## Uninstalling

`brew uninstall cactus && brew untap cactus-compute/cactus`