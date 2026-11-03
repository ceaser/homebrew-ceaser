class SshTool < Formula
  desc "Read-only reader for home devices over ssh"
  homepage "https://github.com/ceaser/homebrew-ceaser"
  url "https://github.com/ceaser/homebrew-ceaser/releases/download/ssh-tool-v0.1.0/ssh-tool_0.1.0_darwin_arm64.tar.gz"
  version "0.1.0"
  sha256 "30266fe283adea9aefa28d6110bc9b11f9ebeed857da88270e29a9ce2e17a787"

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
