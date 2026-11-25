cask "openrig-app" do
  version "0.2.2"
  sha256 "3a5682033f44264659d58b59d234d11a6358c17e59fcc9b458cdf61fce55a94f"

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
