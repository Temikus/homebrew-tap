cask "agent-orchestrator" do
  arch arm: "arm64", intel: "x64"

  version "0.14.2"
  sha256 arm:   "9f989fb2d96ed443938c1536b048a5850018330f916caa8807d6cb587db17529",
         intel: "5fa803f40b08db9b0414ac30ee61a90e1f4cfb3404a90e05acf903345c351f44"

  url "https://github.com/Untrivial-ai/agent-orchestrator/releases/download/v#{version}/agent-orchestrator-darwin-#{arch}.zip"
  name "Agent Orchestrator"
  desc "Run and supervise teams of coding agents"
  homepage "https://useao.dev/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on :macos

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
