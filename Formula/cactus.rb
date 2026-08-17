class Cactus < Formula
  desc "On-device AI inference"
  homepage "https://cactuscompute.com"
  url "https://files.pythonhosted.org/packages/b3/32/6a3a5acb493b18de846f4e6122014b280bb42c25a4406b159771204460cd/cactus_compute-2.1.0.tar.gz"
  sha256 "8f57702297e1cd72095fbf0847776ed49b0167b5cc34fbac519e7c6aecda4a5c"
  version "2.1.0"
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
