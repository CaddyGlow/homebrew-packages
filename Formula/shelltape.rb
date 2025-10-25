class Shelltape < Formula
  desc "Tool from CaddyGlow/shelltape"
  homepage "https://github.com/CaddyGlow/shelltape"
  version "0.1.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/shelltape/releases/download/v0.1.4/shelltape-x86_64-apple-darwin.tar.gz"
      sha256 "c24202b9c81a43e39c9e02ba4cf976f12d88bfd6743b84ff06a203fd9a27ec92"
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/shelltape/releases/download/v0.1.4/shelltape-aarch64-apple-darwin.tar.gz"
      sha256 "f94c650c563f72476766ce9fde2661e7a8bc8b792df4e90d42c1153bff687428"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/shelltape/releases/download/v0.1.4/shelltape-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "28c11a9d1afa3b69fae80bcddc56eaa5c9cb58510133a25ae03dbfc97d86718c"
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/shelltape/releases/download/v0.1.4/shelltape-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "a6e079fab24e0e37a84420fc340684363151355ae7e7a04761e2e9114f3ae015"
    end
  end

  def install
    bin.install "shelltape"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/shelltape --version")
  end
end
