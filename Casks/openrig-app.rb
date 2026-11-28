cask "openrig-app" do
  version "0.3.1"
  sha256 "b50aad6165bb0b8ce4dc1706fab75f9b0c362ac9f3c561cb8e5a4697958ceb1f"

  url "https://github.com/Temikus/openrig-app/releases/download/v#{version}/OpenRig-#{version}.dmg"
  name "OpenRig"
  desc "See what each agent seat in an OpenRig rig is doing and act on it"
  homepage "https://github.com/Temikus/openrig-app"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :golden_gate

  app "OpenRig.app"

  zap trash: [
    "~/Library/Caches/dev.openrig.OpenRig",
    "~/Library/HTTPStorages/dev.openrig.OpenRig",
    "~/Library/Preferences/dev.openrig.OpenRig.plist",
    "~/Library/Saved Application State/dev.openrig.OpenRig.savedState",
  ]

  caveats <<~EOS
    OpenRig.app needs a running OpenRig 0.7.x daemon:
      brew install temikus/tap/openrig
      rig daemon start
  EOS
end
