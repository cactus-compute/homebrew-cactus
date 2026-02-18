class Cactus < Formula
  desc "Low-latency AI inference engine for consumer devices"
  homepage "https://github.com/cactus-compute/cactus"
  url "https://github.com/cactus-compute/cactus/archive/refs/tags/v1.7-dev3.tar.gz"
  sha256 "6f996edc7076150ba88bb6e2226801212324a62723bca69d5ce8dca91b1dd68a"

  depends_on "cmake" => :build
  depends_on :macos
  depends_on "python@3.12"
  depends_on "sdl2" => :recommended

  def install
    # Install only the directories needed for build and runtime.
    # The Python CLI resolves native library and binary paths relative
    # to the source tree, so the repo layout must be preserved.
    %w[cactus python tests libs].each do |dir|
      (libexec/dir).install Dir["#{dir}/*"] if File.directory?(dir)
    end
    (libexec/"weights").mkpath

    # Build the native library (libcactus.a + libcactus.dylib)
    cactus_build = libexec/"cactus/build"
    cactus_build.mkpath
    cd cactus_build do
      system "cmake", "..", *std_cmake_args
      system "make", "-j#{ENV.make_jobs}"
    end

    # Compile the chat and asr binaries used by `cactus run` and `cactus transcribe`
    tests_build = libexec/"tests/build"
    tests_build.mkpath

    vendored_curl = libexec/"libs/curl/macos/libcurl.a"

    compile_flags = [
      "-std=c++20", "-O3",
      "-I#{libexec}",
    ]
    link_flags = [
      cactus_build/"libcactus.a",
      vendored_curl.to_s,
      "-framework", "Accelerate",
      "-framework", "CoreML",
      "-framework", "Foundation",
      "-framework", "Security",
      "-framework", "SystemConfiguration",
      "-framework", "CFNetwork",
    ]

    system ENV.cxx, *compile_flags,
           libexec/"tests/chat.cpp", *link_flags,
           "-o", tests_build/"chat"

    if build.with? "sdl2"
      sdl2_prefix = Formula["sdl2"].opt_prefix
      system ENV.cxx, *compile_flags,
             "-DHAVE_SDL2", "-I#{sdl2_prefix}/include",
             libexec/"tests/asr.cpp", *link_flags,
             "-L#{sdl2_prefix}/lib", "-lSDL2",
             "-o", tests_build/"asr"
    else
      system ENV.cxx, *compile_flags,
             libexec/"tests/asr.cpp", *link_flags,
             "-o", tests_build/"asr"
    end

    # Set up Python virtual environment with CLI dependencies
    venv_dir = libexec/"venv"
    system "python3.12", "-m", "venv", venv_dir

    pip = venv_dir/"bin/pip"
    system pip, "install", "--upgrade", "pip"

    # Install only the dependencies needed for CLI usage (download, run, transcribe).
    # We skip requirements.txt because it includes torchvision and other VLM-only
    # packages that are not needed for basic CLI workflows.
    system pip, "install", "--no-cache-dir",
           "torch>=2.8.0", "transformers>=4.57.0", "numpy",
           "huggingface-hub>=0.36.0", "silero-vad>=6.2.0"

    # Editable install is required: the CLI resolves native library and
    # binary paths relative to the source tree (python/src/ -> ../../cactus/build/).
    system pip, "install", "--no-deps", "-e", libexec/"python"

    (bin/"cactus").write <<~EOS
      #!/bin/bash
      source "#{venv_dir}/bin/activate"
      exec "#{venv_dir}/bin/cactus" "$@"
    EOS
  end

  def caveats
    <<~EOS
      Quick start:
        cactus download LiquidAI/LFM2-1.2B
        cactus run LiquidAI/LFM2-1.2B

      Transcription:
        cactus download openai/whisper-small
        cactus transcribe
        cactus transcribe --file audio.wav

      Model weights are stored in: #{libexec}/weights
      For all commands: cactus --help
    EOS
  end

  test do
    assert_match "cactus", shell_output("#{bin}/cactus --help")
  end
end
