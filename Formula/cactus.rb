class Cactus < Formula
  desc "Energy-efficient AI inference engine for consumer devices"
  homepage "https://github.com/cactus-compute/cactus"
  url "https://github.com/cactus-compute/cactus/archive/refs/tags/v1.6.tar.gz"
  sha256 "7e988517ab4957c0d58128566653e875f03304830ef7866042264823dce2225f"
  license "Apache-2.0"

  depends_on "cmake"
  depends_on "python@3.12"

  def install
    # Install entire repo structure to libexec (replicates git clone)
    libexec.install Dir["*"]

    # Build the native library (cactus build)
    system "bash", libexec/"cactus/build.sh"

    # Build the CLI binaries (chat, asr)
    tests_build = libexec/"tests/build"
    tests_build.mkpath

    # Compile chat binary
    system ENV.cxx, "-std=c++20", "-O3",
           "-I#{libexec}",
           libexec/"tests/chat.cpp",
           libexec/"cactus/build/libcactus.a",
           "-o", tests_build/"chat",
           "-lcurl",
           "-framework", "Accelerate",
           "-framework", "CoreML",
           "-framework", "Foundation"

    # Compile asr binary
    system ENV.cxx, "-std=c++20", "-O3",
           "-I#{libexec}",
           libexec/"tests/asr.cpp",
           libexec/"cactus/build/libcactus.a",
           "-o", tests_build/"asr",
           "-lcurl",
           "-framework", "Accelerate",
           "-framework", "CoreML",
           "-framework", "Foundation"

    # Create virtual environment
    venv_dir = libexec/"venv"
    system "python3.12", "-m", "venv", venv_dir

    # Install dependencies
    pip = venv_dir/"bin/pip"
    system pip, "install", "--upgrade", "pip"
    system pip, "install", "--no-cache-dir", "-r", libexec/"python/requirements.txt"

    # Install cactus package
    system pip, "install", "-e", libexec/"python"

    # Create wrapper script
    (bin/"cactus").write <<~EOS
      #!/bin/bash
      source "#{venv_dir}/bin/activate"
      exec "#{venv_dir}/bin/cactus" "$@"
    EOS
  end

  def caveats
    <<~EOS
      Cactus has been installed!

      Quick start:
        cactus download LiquidAI/LFM2-1.2B    # Download a model (~500MB)
        cactus run LiquidAI/LFM2-1.2B         # Start chatting

      Transcription:
        cactus download UsefulSensors/moonshine-base
        cactus transcribe                     # Live microphone
        cactus transcribe --file audio.wav    # Transcribe file

      Weights are stored in: #{libexec}/weights

      For all commands: cactus --help
    EOS
  end

  test do
    assert_match "cactus", shell_output("#{bin}/cactus --help")
  end
end
