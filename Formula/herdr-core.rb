class HerdrCore < Formula
  # A string literal in livecheck trips FormulaAudit/LivecheckUrlSymbol: with
  # every stable url inside on_* blocks, the cop compares this url to itself.
  MANIFEST_URL = "https://releases.herdr.dev/core/latest.json".freeze

  desc "Run programs and coding agents in terminals that stay alive"
  homepage "https://herdr.dev"
  version "0.1.21"
  license "Apache-2.0"

  livecheck do
    url MANIFEST_URL
    strategy :json do |json|
      json["version"]
    end
  end

  on_macos do
    on_arm do
      url "https://releases.herdr.dev/core/0.1.21/herdr-core-macos-aarch64.tar.gz"
      sha256 "1ab38dd9270f63a8f794d6d60e8702eb0d1c85a72bda85d735e5eea43f05ffed"
    end
    on_intel do
      url "https://releases.herdr.dev/core/0.1.21/herdr-core-macos-x86_64.tar.gz"
      sha256 "e377e1d342cddce0346da5b2f3c281b9701e4731c00024c7c5028265e77a217f"
    end
  end

  on_linux do
    on_arm do
      url "https://releases.herdr.dev/core/0.1.21/herdr-core-linux-aarch64.tar.gz"
      sha256 "e844a2bfab48a226097679d076bc83042fe57fccef5387ef802e5b24e78b529a"
    end
    on_intel do
      url "https://releases.herdr.dev/core/0.1.21/herdr-core-linux-x86_64.tar.gz"
      sha256 "78424755c10a40dde38a0bdb55c20ac19706e9ae05ed68fc2acf1fcff0d941c1"
    end
  end

  def install
    if OS.mac?
      # Upstream's installer runs the core from its signed bundle, so macOS
      # privacy grants attach to "Herdr Core", not to each launching terminal.
      libexec.install "Herdr Core.app"
      bin.install_symlink libexec/"Herdr Core.app/Contents/MacOS/herdr-core"
    else
      bin.install "herdr-core"
    end
    bin.install_symlink "herdr-core" => "hc"
  end

  test do
    assert_match "hc #{version}", shell_output("#{bin}/hc --version")
    assert_match "terminals that stay alive", shell_output("#{bin}/herdr-core --help")
  end
end
