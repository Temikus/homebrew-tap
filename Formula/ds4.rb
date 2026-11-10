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

    # Upstream writes gguf/ and the ds4flash.gguf link next to the script.
    # Use the working directory instead, so downloads never land in the Cellar.
    inreplace "download_model.sh" do |s|
      s.gsub! 'ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)', "ROOT=$(pwd)"
      s.gsub! "$ROOT/gguf-tools/", "#{pkgshare}/gguf-tools/"
    end
    # Help text only, so upstream rewording must not fail the build.
    inreplace "download_model.sh", "./download_model.sh", "ds4-download-model", audit_result: false
    inreplace "download_model.sh", %r{\./(ds4(?:-server)?) }, "\\1 ", audit_result: false
    inreplace "download_model.sh", "python3 -m pip install -U huggingface_hub hf_xet", "brew install hf",
              audit_result: false
    (pkgshare/"gguf-tools").install "gguf-tools/merge_deepseek41_shards.py"
    libexec.install "download_model.sh" => "ds4-download-model"
    bin.install_symlink libexec/"ds4-download-model"

    # The downloader's help has a "Targets:" section of "  name" lines, each
    # followed by an indented paragraph. Print the name and the first sentence.
    # Fall back to the full help if that layout changes.
    (bin/"ds4-list-models").write <<~SH
      #!/bin/sh
      help=$("#{opt_libexec}/ds4-download-model" --help) || exit
      list=$(printf '%s\\n' "$help" | awk '
        function flush() {
          if (name != "") { sub(/\\. .*/, ".", desc); printf "%-30s %s\\n", name, desc }
          name = ""; desc = ""
        }
        /^Targets:/ { t = 1; next }
        /^[A-Za-z]/ { flush(); t = 0 }
        t && /^  [a-z0-9]/ { flush(); name = substr($0, 3); next }
        t && /^       / { sub(/^ +/, ""); desc = desc (desc == "" ? "" : " ") $0 }
        END { flush() }
      ')
      if [ -n "$list" ]; then printf '%s\\n' "$list"; else printf '%s\\n' "$help"; fi
    SH
  end

  def caveats
    <<~EOS
      Models are not included. List them, then download into the current directory:
        ds4-list-models
        ds4-download-model ds4f-q2
      Then run ds4 from that directory, or pass -m <model.gguf>.
      PRO, V4.1, GLM and Qwen downloads also need the Hugging Face CLI: brew install hf
    EOS
  end

  test do
    assert_match "Usage", shell_output("#{bin}/ds4 --help 2>&1")
    assert_match(/^ds4f-q2 +2-bit routed experts/, shell_output(bin/"ds4-list-models"))
    assert_match "ds4-download-model ds4f-q2", shell_output("#{bin}/ds4-download-model --help")
  end
end
