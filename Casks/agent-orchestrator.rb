cask "agent-orchestrator" do
  arch arm: "arm64", intel: "x64"

  version "0.15.1"
  sha256 arm:   "7be6fb7b9b3c031525872c155542dcd19670c6d9b78e2e70e1aa2640a0851df9",
         intel: "6d810d40be801104409d01ee50b3f685595708def8bace3f1c154f83c6781ddc"

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
