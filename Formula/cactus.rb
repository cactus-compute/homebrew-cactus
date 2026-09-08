class Cactus < Formula
  desc "On-device AI inference"
  homepage "https://cactuscompute.com"
  url "https://files.pythonhosted.org/packages/cc/ca/2185933661850150a004f393fd01e0a48a3be8ced3afbfd2489d72c032d0/cactus_compute-2.2.0.tar.gz"
  sha256 "9bcd425d3a2065a1e33b9f0cbc015aafdca8cb74256fe4d589107298ff41c904"
  version "2.2.0"
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
