cask "opendeck" do
  arch arm: "aarch64", intel: "x64"

  version "2.14.1"
  sha256 arm:   "d290ccdaf22c0c2735120e27de193da53a59ca7537093284c0fb7fb4c33d80a3",
         intel: "6476b95b5f136510c7646beb7974c2cc4d054a2a3c6a0e319e31c606215bd536"

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
