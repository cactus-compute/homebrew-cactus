class Cactus < Formula
  desc "On-device AI inference"
  homepage "https://cactuscompute.com"
  url "https://files.pythonhosted.org/packages/e0/54/10ef02ad95d989a27f978d5e412d4c4f466f3134ee4399c01b39c3d256ff/cactus_compute-2.0.0.tar.gz"
  sha256 "b4087046c0d79314399f21b8caeadafa5e915bdd51146b9fadb9ab0299ec9075"
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
    venv = virtualenv_create(libexec, "python3.12")
    venv.pip_install "cactus-compute==#{version}"
    bin.install_symlink libexec/"bin/cactus"
  end

  test do
    assert_equal "cactus #{version}\n", shell_output("#{bin}/cactus --version")
  end
end
