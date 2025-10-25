class Ghdl < Formula
  desc "GitHub download manager - Fast parallel downloads from GitHub releases"
  homepage "https://github.com/CaddyGlow/ghdl"
  version "0.1.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/ghdl/releases/download/v0.1.1/ghdl-x86_64-apple-darwin.tar.gz"
      sha256 "072b039c82d3fbd1dc6a5d07cf9f08ead8f74c6d6d2ef318f8a2b5a5f7f3a5c1"
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/ghdl/releases/download/v0.1.1/ghdl-aarch64-apple-darwin.tar.gz"
      sha256 "b583f40d689644258a8fc364f90d5c33b35f9898131c1f58a070bce117f6e189"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/ghdl/releases/download/v0.1.1/ghdl-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "d155a69accb2eab89a91d3d321cff7cb1f1514fa92c3c7458b7cf78e9b44ea25"
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/ghdl/releases/download/v0.1.1/ghdl-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "d2f4d249ac9bf036b25c0fceec18b71099a8560218e15d1224327fbb6bcc18fe"
    end
  end

  def install
    bin.install "ghdl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ghdl --version")
  end
end
