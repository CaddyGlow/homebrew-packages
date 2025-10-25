class Quickctx < Formula
  desc "Tool from CaddyGlow/quickctx"
  homepage "https://github.com/CaddyGlow/quickctx"
  version "0.1.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.2/quickctx-x86_64-apple-darwin.tar.gz"
      sha256 "cebc9617f89822b2e0436e61886f6b73ffb20174c1d37a7c520dddae4f14c992"
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.2/quickctx-aarch64-apple-darwin.tar.gz"
      sha256 "5d0cec191087ba42c5d7cccd326b8c5a413ee0490709c95d904e31bd737979ba"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.2/quickctx-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "30c767d6afe0623f5d710ef10ed20290462dc00ef5f136704234c9b2ea5178be"
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.2/quickctx-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "b3d867bfa982795b3d21a574daeab8f87450c08870a87300e5a1062cf2704cf0"
    end
  end

  def install
    bin.install "quickctx"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/quickctx --version")
  end
end
