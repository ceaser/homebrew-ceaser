class SshTool < Formula
  desc "Read-only reader for home devices over ssh"
  homepage "https://github.com/ceaser/homebrew-ceaser"
  url "https://github.com/ceaser/homebrew-ceaser/releases/download/ssh-tool-v1.0.0/ssh-tool_1.0.0_darwin_arm64.tar.gz"
  version "1.0.0"
  sha256 "daccb162344779bde0544c9606e75aab8ad741cf27c5e58a4a4a5aac8b05a1d9"

  depends_on arch: :arm64
  depends_on :macos

  def install
    bin.install "ssh-tool"
    (doc/"examples").install "examples/devices.toml"
  end

  test do
    assert_match "ssh-tool #{version} (", shell_output("#{bin}/ssh-tool --version")
  end
end
