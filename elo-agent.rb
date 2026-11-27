class EloAgent < Formula
  desc "ELO agent -- Claude coding assistant for Telegram"
  homepage "https://github.com/ceaser/homebrew-ceaser"
  url "https://github.com/ceaser/homebrew-ceaser/releases/download/elo-agent-v0.18.0/elo-agent-0.18.0-arm64.tar.gz"
  version "0.18.0"
  sha256 "18f30fec55f79e32d322538355e1c938df6caded26f7c1b116a5755314b430ed"

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
