cask "agent-orchestrator" do
  arch arm: "arm64", intel: "x64"

  version "0.15.6"
  sha256 arm:   "f5af99032611e34930582d1c1bf9c71224f1b5e65e55e240377d8abdffdda23a",
         intel: "818c50da9ddbcaa5bd48467206b6cbfaad6b1ea33ab990e0c22060dadd78fdba"

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
