class Shelltape < Formula
  desc "Terminal command history recorder and browser with full context capture"
  homepage "https://github.com/CaddyGlow/shelltape"
  version "0.1.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/shelltape/releases/download/v0.1.1/shelltape-x86_64-apple-darwin.tar.gz"
      sha256 "9a3fa4a7d5b79d55d5fe2ca3900025881ac4cbd09da015a37fd0aa37cea030b9"
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/shelltape/releases/download/v0.1.1/shelltape-aarch64-apple-darwin.tar.gz"
      sha256 "507de1ba21ce4450d10bb1d63f73a54b6e0cf2b04b0da782abb908e17846c1aa"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/CaddyGlow/shelltape/releases/download/v0.1.1/shelltape-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "359b7bedd7bb009baf350c9707970c6a8bc4d14632c06f345bb1f8a47c9d657c"
    elsif Hardware::CPU.arm?
      url "https://github.com/CaddyGlow/shelltape/releases/download/v0.1.1/shelltape-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "fdd7c9ec8f160775efa4f7ecd5ee5cd615aa2b47b928f2900b50ac3518fa32c3"
    end
  end

  def install
    bin.install "shelltape"
  end

  def caveats
    <<~EOS
      To start recording your shell commands, add shelltape to your shell:

      For Bash, add to ~/.bashrc:
        eval "$(shelltape init bash)"

      For Zsh, add to ~/.zshrc:
        eval "$(shelltape init zsh)"

      For Fish, add to ~/.config/fish/config.fish:
        shelltape init fish | source

      Then restart your shell or source the config file.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/shelltape --version")
  end
end
