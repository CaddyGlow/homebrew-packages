class Quickctx < Formula
  desc "Bidirectional file content aggregator and extractor for LLM contexts"
  homepage "https://github.com/CaddyGlow/quickctx"
  version "0.1.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.1/quickctx-x86_64-apple-darwin.tar.gz"
      sha256 ""  # Will be filled automatically by CI
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.1/quickctx-aarch64-apple-darwin.tar.gz"
      sha256 ""  # Will be filled automatically by CI
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.1/quickctx-x86_64-unknown-linux-gnu.tar.gz"
      sha256 ""  # Will be filled automatically by CI
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.1/quickctx-aarch64-unknown-linux-gnu.tar.gz"
      sha256 ""  # Will be filled automatically by CI
    end
  end

  def install
    bin.install "quickctx"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/quickctx --version")
  end
end
