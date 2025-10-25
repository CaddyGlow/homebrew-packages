class Quickctx < Formula
  desc "Tool from CaddyGlow/quickctx"
  homepage "https://github.com/CaddyGlow/quickctx"
  version "0.1.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.4/quickctx-x86_64-apple-darwin.tar.gz"
      sha256 "824902bcf9c6a158f4e8fb3e9823bd67f3628b4239c47de9645baa88698b94f5"
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.4/quickctx-aarch64-apple-darwin.tar.gz"
      sha256 "b1c74094aa809bb344d068ed3ccfb91ed9ced16b8a4614d42f9206545085634f"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.4/quickctx-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "92b97e7255110d3bb4017723301511fb6df5f6e97e39b78d8cd2377bca58b0e0"
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/quickctx/releases/download/v0.1.4/quickctx-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "92416d0450a2178bcb0c1f171ae963af3af86ea2715ba9ff017dc4d4a358db2c"
    end
  end

  def install
    bin.install "quickctx"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/quickctx --version")
  end
end
