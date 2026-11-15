class Fx < Formula
  desc "Tiny, open, embeddable, native coding agent"
  homepage "https://github.com/vercel-labs/fx"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.17/fx-macos-aarch64.tar.gz"
      sha256 "5cacb5b3624a79db8fd4e31dcbc59d6a933d7e5ed4c397776d95df6b618296a9"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.17/fx-macos-x86_64.tar.gz"
      sha256 "984eef6632d7bd27ff7b75befb52b9db32c25287905009db5822f6a669861fec"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.17/fx-linux-aarch64.tar.gz"
      sha256 "b4633b8987ec43f1b9454e4629f3b5a4f1e086aae36b84ae4fefeacd6a53761f"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.17/fx-linux-x86_64.tar.gz"
      sha256 "78c155d59fa59e42fd56d93037fd75041868c9c67865e8c7f0ca6dcdfac23e75"
    end
  end

  def install
    bin.install "fx"
    prefix.install "LICENSE", "THIRD_PARTY_NOTICES.md"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/fx --version").strip
    assert_match "coding agent", shell_output("#{bin}/fx --help")
  end
end
