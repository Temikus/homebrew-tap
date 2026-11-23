class HerdrCore < Formula
  # A string literal in livecheck trips FormulaAudit/LivecheckUrlSymbol: with
  # every stable url inside on_* blocks, the cop compares this url to itself.
  MANIFEST_URL = "https://releases.herdr.dev/core/latest.json".freeze

  desc "Run programs and coding agents in terminals that stay alive"
  homepage "https://herdr.dev"
  version "0.1.22"
  license "Apache-2.0"

  livecheck do
    url MANIFEST_URL
    strategy :json do |json|
      json["version"]
    end
  end

  on_macos do
    on_arm do
      url "https://releases.herdr.dev/core/0.1.22/herdr-core-macos-aarch64.tar.gz"
      sha256 "90798daadefa8d126b90ef0bcdbe9c7dda9c6cfbf011a247065ab5da348f350e"
    end
    on_intel do
      url "https://releases.herdr.dev/core/0.1.22/herdr-core-macos-x86_64.tar.gz"
      sha256 "35144041969e870ddb4edcd2fd08fd26dfe5cee7d18e6b48adb276f90a48aa19"
    end
  end

  on_linux do
    on_arm do
      url "https://releases.herdr.dev/core/0.1.22/herdr-core-linux-aarch64.tar.gz"
      sha256 "98757985245d45f8d73dd85e68b139b7f167c28488bb89edd9834c3f5a5cf4cf"
    end
    on_intel do
      url "https://releases.herdr.dev/core/0.1.22/herdr-core-linux-x86_64.tar.gz"
      sha256 "3054ec3992ce80c5715d721caa9dcefa6056721d15dc113f4750afce763ba5df"
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
