class Ds4 < Formula
  desc "DeepSeek V4, GLM and Qwen local inference engine for Apple Silicon"
  homepage "https://github.com/antirez/ds4"
  url "https://github.com/antirez/ds4/archive/890898cfb437ed256be58ebcf7c58a6dfa8f2f53.tar.gz"
  version "0.0.20261102.1026"
  sha256 "b3185de7483739e16973851241a6a19e2f63c603fa417e94e8944d789141d9ab"
  license "MIT"
  head "https://github.com/antirez/ds4.git", branch: "main"

  # Upstream has no tags. scripts/bump-formula.sh pins the latest main commit.
  livecheck do
    skip "No tagged releases"
  end

  depends_on arch: :arm64
  depends_on :macos

  def install
    system "make", "NATIVE_CPU_FLAG=", "DEBUG_FLAGS="
    pkgshare.install "metal"

    # The binaries read Metal kernels from ./metal at runtime unless each
    # DS4_METAL_*_SOURCE variable points at the file.
    sources = File.read("ds4_metal.m").scan(%r{@"(DS4_METAL_\w+_SOURCE)",\s*@"metal/([\w.]+)"})
    odie "No Metal source variables found in ds4_metal.m" if sources.empty?
    env = sources.to_h { |var, file| [var, pkgshare/"metal"/file] }

    bin.install %w[ds4 ds4-server ds4-bench ds4-eval ds4-agent]
    bin.env_script_all_files libexec, env
    pkgshare.install "download_model.sh"
  end

  def caveats
    <<~EOS
      Models are not included. Download one into a directory of your choice:
        cp #{opt_pkgshare}/download_model.sh . && sh ./download_model.sh ds4f-q2
      Then run ds4 from that directory, or pass -m <model.gguf>.
    EOS
  end

  test do
    assert_match "Usage", shell_output("#{bin}/ds4 --help 2>&1")
  end
end
