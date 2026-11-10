cask "agent-orchestrator" do
  arch arm: "arm64", intel: "x64"

  version "0.14.10"
  sha256 arm:   "4a53349c3ac228a886bdc243f0e4fa87d7e3c09bbde2ee4cddd4e7c0cc9f6d3e",
         intel: "839f2b5db940abf4f1f782d891d654bd592239a7dba3e4ec3c6a32b00344e49d"

  url "https://github.com/Untrivial-ai/agent-orchestrator/releases/download/v#{version}/agent-orchestrator-darwin-#{arch}.zip"
  name "Agent Orchestrator"
  desc "Run and supervise teams of coding agents"
  homepage "https://useao.dev/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :ventura

  app "Agent Orchestrator.app"
  # Workspace hooks shell out to `ao`, so it must be on PATH.
  binary "#{appdir}/Agent Orchestrator.app/Contents/Resources/daemon/ao"

  zap trash: [
    "~/.ao",
    "~/Library/Application Support/Agent Orchestrator",
    "~/Library/Caches/dev.agent-orchestrator.desktop*",
    "~/Library/Logs/Agent Orchestrator",
    "~/Library/Preferences/dev.agent-orchestrator.desktop.plist",
    "~/Library/Saved Application State/dev.agent-orchestrator.desktop.savedState",
  ]
end
