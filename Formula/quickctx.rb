class Quickctx < Formula
  desc "Tool from CaddyGlow/quickctx"
  homepage "https://github.com/CaddyGlow/quickctx"
  version "0.1.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.2/quickctx-x86_64-apple-darwin.tar.gz"
      sha256 ""
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.2/quickctx-aarch64-apple-darwin.tar.gz"
      sha256 ""
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.2/quickctx-x86_64-unknown-linux-gnu.tar.gz"
      sha256 ""
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.2/quickctx-aarch64-unknown-linux-gnu.tar.gz"
      sha256 ""
    end
  end

  def install
    bin.install "quickctx"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/quickctx --version")
  end
end
