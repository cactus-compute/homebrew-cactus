class Cactus < Formula
  desc "On-device AI inference"
  homepage "https://cactuscompute.com"
  url "https://files.pythonhosted.org/packages/4c/e4/a6a3e04454febfa05d174468f946350dda1d62e3cc6404f1cfe72629da6c/cactus_compute-2.2.1.tar.gz"
  sha256 "487ed69319597d2736ce47447f1d9f0b0fc2ca87d9630215eb0af0d65e5a3613"
  version "2.2.1"
  license "Cactus Compute License"
  include Language::Python::Virtualenv
  depends_on "python@3.12"
  depends_on macos: :sonoma
  depends_on arch: :arm64

  livecheck do
    url "https://pypi.org/pypi/cactus-compute/json"
    regex(/"version":\s*"(\d+(?:\.\d+)+)"/i)
  end

  def install
    virtualenv_create(libexec, "python3.12")
    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "pip",
           "--python=#{libexec}/bin/python", "install", "cactus-compute==#{version}"
    bin.install_symlink libexec/"bin/cactus"
  end

  def caveats
    <<~EOS
      cactus code needs Node.js >= 22 on PATH.
      cactus convert (torch) is opt-in, same as pip's [convert] extra:
      #{Formula["python@3.12"].opt_bin}/python3.12 -m pip --python=#{libexec}/bin/python install "cactus-compute[convert]==#{version}"
    EOS
  end

  test do
    assert_equal "cactus #{version}\n", shell_output("#{bin}/cactus --version")
    assert_match "libcactus_engine",
      Dir[libexec/"lib/python*/site-packages/cactus/bindings/lib/*"].join
  end
end
