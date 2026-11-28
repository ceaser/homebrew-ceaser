class EloAgent < Formula
  desc "ELO agent -- Claude coding assistant for Telegram"
  homepage "https://github.com/ceaser/homebrew-ceaser"
  url "https://github.com/ceaser/homebrew-ceaser/releases/download/elo-agent-v0.19.1/elo-agent-0.19.1-arm64.tar.gz"
  version "0.19.1"
  sha256 "50e2ef614552c8e0d6fa47e6c4601f91d8a9b31a88b0a3795933a242b4db818b"

  depends_on arch: :arm64
  depends_on :macos
  depends_on "git"

  def install
    prefix.install Dir["*"]
  end

  service do
    run [opt_bin/"elo-agent", "foreground"]
    keep_alive true
    log_path var/"log/elo-agent.log"
    error_log_path var/"log/elo-agent.log"
    working_dir Dir.home
    environment_variables HOME: Dir.home
  end

  def caveats
    <<~EOS
      First-time setup after installation:

        mkdir -p ~/.config/elo-agent
        cp "#{opt_share}/doc/elo-agent/examples/shared.env.example" \\
           ~/.config/elo-agent/shared.env
        cp "#{opt_share}/doc/elo-agent/examples/local.env.example" \\
           ~/.config/elo-agent/local.env
        chmod 0600 ~/.config/elo-agent/shared.env ~/.config/elo-agent/local.env

      Edit ~/.config/elo-agent/shared.env with BOT_NODE and AGENT_COOKIE,
      then run preflight checks and start the agent:

        elo-agent precheck
        brew services start elo-agent
    EOS
  end

  test do
    assert_predicate bin/"elo-agent", :exist?
    assert_predicate bin/"elo-agent", :executable?
  end
end
