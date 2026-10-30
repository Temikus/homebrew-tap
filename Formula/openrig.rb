class Openrig < Formula
  include Language::Node::Shebang

  desc "Persistent teams of Claude Code, Codex and Pi agents with shared context"
  homepage "https://openrig.dev"
  url "https://registry.npmjs.org/@openrig/cli/-/cli-0.7.5.tgz"
  sha256 "22d67c2c7e0d0ab4a5ec9faac0a725d54f9ead2c0f71564985cf4ae240bb9754"
  license "Apache-2.0"

  # Upstream supports Node 22 and 24 only. Homebrew's `node` is newer.
  depends_on "node@24"
  depends_on "tmux"

  conflicts_with "r-rig", "rig", because: "both install `rig` binary"

  def install
    system "npm", "install", *std_npm_args
    pkg = libexec/"lib/node_modules/@openrig/cli"
    rewrite_shebang detected_node_shebang, pkg/"dist/bin-wrapper.js", pkg/"tui/dist/main.js"
    bin.install_symlink libexec.glob("bin/*")

    # better-sqlite3 ships prebuilds for every platform; keep only the native one.
    os = OS.mac? ? "darwin" : "linux"
    arch = Hardware::CPU.arm? ? "arm64" : "x64"
    pkg.glob("node_modules/better-sqlite3/prebuilds/*.node").each do |f|
      rm f if f.basename(".node").to_s != "#{os}-#{arch}"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rig --version")
    # Upstream's install check: loads better-sqlite3 and opens a database.
    system formula_opt_bin("node@24")/"node", libexec/"lib/node_modules/@openrig/cli/scripts/check-abi.mjs"
  end
end
