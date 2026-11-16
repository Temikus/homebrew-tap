cask "agent-orchestrator" do
  arch arm: "arm64", intel: "x64"

  version "0.15.2"
  sha256 arm:   "2382e4e339ed99ab0c6ed2fa5409bafa79b017355f603b934d042ea57122177f",
         intel: "0bbb59bcb7b0bf5ac7d62ec6eace5df5aa3c47c0570faea05c141c491725c5de"

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
