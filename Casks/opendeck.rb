cask "opendeck" do
  arch arm: "aarch64", intel: "x64"

  version "2.14.2"
  sha256 arm:   "cb8e4592210e895abfaa92bc7093a07df4a7caa6e45745f711a5c466cb014da4",
         intel: "b5f9c75f1a8c0503726bb8f56815b659148c1f80808ef72b1f17a49e10e44b27"

  url "https://github.com/nekename/OpenDeck/releases/download/v#{version}/OpenDeck_#{version}_#{arch}.dmg"
  name "OpenDeck"
  desc "Stream Deck software with support for Elgato plugins"
  homepage "https://github.com/nekename/OpenDeck"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "OpenDeck.app"

  zap trash: [
    "~/Library/Application Support/com.amansprojects.opendeck",
    "~/Library/Application Support/opendeck",
    "~/Library/Caches/opendeck",
    "~/Library/LaunchAgents/OpenDeck.plist",
    "~/Library/Logs/opendeck",
    "~/Library/Preferences/opendeck.plist",
    "~/Library/WebKit/opendeck",
  ]

  caveats <<~EOS
    OpenDeck is not notarized by Apple. On first launch, allow it in
    System Settings > Privacy & Security > Open Anyway.

    Plugins built only for Windows need Wine.
  EOS
end
