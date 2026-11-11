class HerdrCore < Formula
  # A string literal in livecheck trips FormulaAudit/LivecheckUrlSymbol: with
  # every stable url inside on_* blocks, the cop compares this url to itself.
  MANIFEST_URL = "https://releases.herdr.dev/core/latest.json".freeze

  desc "Run programs and coding agents in terminals that stay alive"
  homepage "https://herdr.dev"
  version "0.1.20"
  license "Apache-2.0"

  livecheck do
    url MANIFEST_URL
    strategy :json do |json|
      json["version"]
    end
  end

  on_macos do
    on_arm do
      url "https://releases.herdr.dev/core/0.1.20/herdr-core-macos-aarch64.tar.gz"
      sha256 "e58985d3fef6e909f33d3c5a4426e4898c81564a557d4636591cec9e3a06af26"
    end
    on_intel do
      url "https://releases.herdr.dev/core/0.1.20/herdr-core-macos-x86_64.tar.gz"
      sha256 "36c0331c3ffea0ffaada195b89a3c7496f7f3fc5bf35e4605c19c84e5c205a56"
    end
  end

  on_linux do
    on_arm do
      url "https://releases.herdr.dev/core/0.1.20/herdr-core-linux-aarch64.tar.gz"
      sha256 "5f3037379d15cc76cfc72d2fd1a4262ea1c5b24df278bf7cfd8adcff7b914862"
    end
    on_intel do
      url "https://releases.herdr.dev/core/0.1.20/herdr-core-linux-x86_64.tar.gz"
      sha256 "ac6b86890c451a37584620aaa438b71bc0d0bd430a2e7c1d7e095f052c414e74"
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
