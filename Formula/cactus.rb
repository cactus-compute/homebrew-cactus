class Cactus < Formula
  desc "Low-latency AI inference engine for consumer devices"
  homepage "https://github.com/cactus-compute/cactus"
  url "https://github.com/cactus-compute/cactus/archive/refs/tags/v1.7.tar.gz"
  sha256 "eefa2601fd94418ffab67ec815c1eda37b0f51b9321cdc12b694ab32247ce26f"

  depends_on "cmake" => :build
  depends_on :macos
  depends_on "python@3.14"
  depends_on "sdl2" => :recommended

  def install
    %w[cactus python tests libs].each do |dir|
      (libexec/dir).install Dir["#{dir}/*"] if File.directory?(dir)
    end
    (libexec/"weights").mkpath

    cactus_build = libexec/"cactus/build"
    cactus_build.mkpath
    cd cactus_build do
      system "cmake", "..", *std_cmake_args
      system "make", "-j#{ENV.make_jobs}"
    end

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

    venv_dir = libexec/"venv"
    system "python3.14", "-m", "venv", venv_dir

    pip = venv_dir/"bin/pip"
    system pip, "install", "--upgrade", "pip"

    system pip, "install", "--no-cache-dir",
           "torch>=2.8.0", "transformers>=4.57.0", "numpy",
           "huggingface-hub>=0.36.0"

    system pip, "install", "--no-deps", "-e", libexec/"python"

    (bin/"cactus").write <<~EOS
      #!/bin/bash
      source "#{venv_dir}/bin/activate"
      exec "#{venv_dir}/bin/cactus" "$@"
    EOS
  end

  def caveats
    <<~EOS

      -----------------------------------------------------------------

      How to use the Cactus Repo/CLI:

      -----------------------------------------------------------------

      cactus auth                          manage Cactus Cloud API key
                                           shows status and prompts to set key

        Optional flags:
        --status                           show key status without prompting
        --clear                            remove the saved API key

      -----------------------------------------------------------------

      cactus run <model>                   opens playground for the model
                                           auto downloads and spins up

        Optional flags:
        --precision INT4|INT8|FP16         default: INT8
        --token <token>                    HF token (for gated models)
        --reconvert                        force model weights reconversion from source

      -----------------------------------------------------------------

      cactus transcribe [model]            live microphone transcription
                                           default model: whisper-small

        Optional flags:
        --file <audio.wav>                 transcribe audio file instead of mic
        --precision INT4|INT8|FP16         default: INT8
        --token <token>                    HF token (for gated models)
        --reconvert                        force model weights reconversion from source

        Examples:
        cactus transcribe                  live microphone transcription
        cactus transcribe --file audio.wav transcribe single file
        cactus transcribe openai/whisper-small   use different model
        cactus transcribe openai/whisper-small --file audio.wav

      -----------------------------------------------------------------

      cactus download <model>              downloads model to ./weights
                                           see supported weights on ReadMe

        Optional flags:
        --precision INT4|INT8|FP16         quantization (default: INT8)
        --token <token>                    HuggingFace API token
        --reconvert                        force model weights reconversion from source

      -----------------------------------------------------------------

      cactus convert <model> [output_dir]  converts model to custom directory
                                           supports LoRA adapter merging

        Optional flags:
        --precision INT4|INT8|FP16         quantization (default: INT8)
        --lora <path>                      LoRA adapter path to merge
        --token <token>                    HuggingFace API token

      -----------------------------------------------------------------

      cactus build                         builds cactus for ARM chips
                                           output: build/libcactus.a

        Optional flags:
        --apple                            build for Apple (iOS/macOS)
        --android                          build for Android
        --flutter                          build for Flutter (all platforms)
        --python                           build shared lib for Python FFI

      -----------------------------------------------------------------

      cactus clean                         removes all build artifacts

      -----------------------------------------------------------------

      cactus --help                        shows these instructions

      -----------------------------------------------------------------

      Model weights are stored in: #{libexec}/weights
    EOS
  end

  test do
    assert_match "cactus", shell_output("#{bin}/cactus --help")
  end
end
