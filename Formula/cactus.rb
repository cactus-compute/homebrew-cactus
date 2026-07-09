class Cactus < Formula
  desc "On-device AI inference"
  homepage "https://cactuscompute.com"
  url "https://files.pythonhosted.org/packages/36/4f/fbc693e6aa893e5787fc8b30c3a85f14c1f08ab450b6ce1be58197033462/cactus_compute-2.0.1.tar.gz"
  sha256 "ed0a78c2811baba2bd636086bb0729c5299454db3d057f61128e1a6b9cede06c"
  version "2.0.1"
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
