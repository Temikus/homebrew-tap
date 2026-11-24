class Openrig < Formula
  include Language::Node::Shebang

  desc "Persistent teams of Claude Code, Codex and Pi agents with shared context"
  homepage "https://openrig.dev"
  url "https://registry.npmjs.org/@openrig/cli/-/cli-0.7.22.tgz"
  sha256 "7e7ce4051355b975e9f9c7abafd05aacdba83fae06a193e3cd31c98f41ffcabd"
  license "Apache-2.0"

  # Upstream supports Node 22 and 24 only. Homebrew's `node` is newer.
  depends_on "node@24"
  depends_on "tmux"

  conflicts_with "r-rig", "rig", because: "both install `rig` binary"

  def install
    system "npm", "install", *std_npm_args
    pkg = libexec/"lib/node_modules/@openrig/cli"
    rewrite_shebang detected_node_shebang, pkg/"dist/bin-wrapper.js", pkg/"tui/dist/main.js"
    bin.install_symlink libexec/"bin/openrig-tui"

    # `brew upgrade` deletes the old keg, but a running daemon keeps its old path.
    # Warn when the daemon in daemon.json runs from another keg. The daemon can't
    # be restarted from post_install: its sandbox blocks writes to ~/.openrig and tmux.
    (bin/"rig").write <<~SH
      #!/bin/sh
      case "$1 $2" in
        "daemon start"*|"daemon stop"*|"daemon logs"*|"--version "*|"-V "*|"completion "*) ;;
        *)
          if [ -z "${OPENRIG_URL:-}" ]; then
            state="${OPENRIG_HOME:-${RIGGED_HOME:-$HOME/.openrig}}/daemon.json"
            pid=$(sed -n 's/.*"pid":[^0-9]*//p' "$state" 2>/dev/null)
            pid=${pid%%[!0-9]*}
            cmd=""
            [ -n "$pid" ] && cmd=$(ps -ww -o command= -p "$pid" 2>/dev/null)
            case "$cmd" in
              */Cellar/openrig/*)
                running=${cmd#*/Cellar/openrig/}
                running=${running%%/*}
                if [ "$running" != "#{pkg_version}" ]; then
                  echo "rig: the OpenRig daemon (pid $pid) is running $running, but rig is #{pkg_version}." >&2
                  echo "rig: Homebrew may have removed $running's files, so the daemon can fail." >&2
                  echo "rig: Restart it on #{pkg_version}; tmux seats are kept:" >&2
                  echo "rig:   rig daemon stop && rig daemon start" >&2
                fi
                ;;
            esac
          fi
          ;;
      esac
      exec "#{libexec}/bin/rig" "$@"
    SH
    chmod 0755, bin/"rig"

    # better-sqlite3 ships prebuilds for every platform; keep only the native one.
    os = OS.mac? ? "darwin" : "linux"
    arch = Hardware::CPU.arm? ? "arm64" : "x64"
    pkg.glob("node_modules/better-sqlite3/prebuilds/*.node").each do |f|
      rm f if f.basename(".node").to_s != "#{os}-#{arch}"
    end
  end

  def caveats
    <<~EOS
      A daemon that was running during an upgrade keeps the old version and can
      fail once Homebrew removes the old files. Restart it on the new version;
      tmux seats are kept:
        rig daemon stop && rig daemon start
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rig --version")
    # Upstream's install check: loads better-sqlite3 and opens a database.
    system formula_opt_bin("node@24")/"node", libexec/"lib/node_modules/@openrig/cli/scripts/check-abi.mjs"

    # The wrapper warns only for a daemon running from another keg.
    ENV["OPENRIG_HOME"] = testpath
    node = formula_opt_bin("node@24")/"node"
    { "0.0.1" => true, pkg_version.to_s => false }.each do |keg, warns|
      pid = spawn(node, "-e", "setTimeout(() => {}, 60000)", "#{testpath}/Cellar/openrig/#{keg}/daemon.js")
      (testpath/"daemon.json").write %Q({\n  "pid": #{pid},\n  "port": 7433\n}\n)
      output = shell_output("#{bin}/rig --help 2>&1 >/dev/null")
      if warns
        assert_match "daemon (pid #{pid}) is running #{keg}, but rig is #{pkg_version}", output
      else
        refute_match "rig daemon stop", output
      end
    ensure
      Process.kill("TERM", pid) if pid
    end
  end
end
