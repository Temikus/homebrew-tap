cask "openrig-app" do
  version "0.1.0"
  sha256 "08157b7fe10ebc2602470fff245ce386dddb1880ee2b46fedcd4ff201b97dd66"

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
