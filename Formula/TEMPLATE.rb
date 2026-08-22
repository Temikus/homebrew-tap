# Formula Template
# Copy this to Formula/<name>.rb and customize

class <Name> < Formula
  desc "One-line description"
  homepage "https://github.com/owner/repo"
  license "MIT"  # SPDX identifier

  # Livecheck for auto-bump
  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/owner/repo/releases/download/v#{version}/<name>-macos-aarch64.tar.gz"
      sha256 "REPLACE_WITH_ACTUAL_SHA256"
    end
    on_intel do
      url "https://github.com/owner/repo/releases/download/v#{version}/<name>-macos-x86_64.tar.gz"
      sha256 "REPLACE_WITH_ACTUAL_SHA256"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/owner/repo/releases/download/v#{version}/<name>-linux-aarch64.tar.gz"
      sha256 "REPLACE_WITH_ACTUAL_SHA256"
    end
    on_intel do
      url "https://github.com/owner/repo/releases/download/v#{version}/<name>-linux-x86_64.tar.gz"
      sha256 "REPLACE_WITH_ACTUAL_SHA256"
    end
  end

  def install
    bin.install "<name>"
    # Install completions, man pages, licenses if available
    # bash_completion.install "completions/<name>.bash"
    # zsh_completion.install "completions/<name>.zsh"
    # fish_completion.install "completions/<name>.fish"
    # man1.install "docs/<name>.1"
    # prefix.install "LICENSE"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/<name> --version").strip
    assert_match "expected help text", shell_output("#{bin}/<name> --help")
  end
end