class Cactus < Formula
  desc "On-device AI inference"
  homepage "https://cactuscompute.com"
  url "https://files.pythonhosted.org/packages/be/76/f4bdb7cb4610f9e901a1f0c695b5c3e40c4a765abfa10ab192a30ba4e9aa/cactus_compute-2.2.2.tar.gz"
  sha256 "6a4140f07aef491b384293b234c17d788cd505eb743dd076bc546cdea644ea62"
  version "2.2.2"
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
