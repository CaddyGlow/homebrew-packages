class Ghdl < Formula
  desc "Tool from CaddyGlow/ghdl"
  homepage "https://github.com/CaddyGlow/ghdl"
  version "0.1.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/ghdl/releases/download/v0.1.3/ghdl-x86_64-apple-darwin.tar.gz"
      sha256 "79912061133664aa2ace462580c00423e78b1231c25cec3a4d738fdc3e3a1564"
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/ghdl/releases/download/v0.1.3/ghdl-aarch64-apple-darwin.tar.gz"
      sha256 "510e73839bf5534e733e42b55e83e460d4a683df6083b0e4f5a60db3a4f8fa3c"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/ghdl/releases/download/v0.1.3/ghdl-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "f819890b6231746e85e398ee76abc6ce80442e08858b5eb23f41c5b0114e1c58"
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/ghdl/releases/download/v0.1.3/ghdl-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "93dbb9a0b467911653299f8052a351660a3539767d0a76cb8a6219285b4576fa"
    end
  end

  def install
    bin.install "ghdl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ghdl --version")
  end
end
