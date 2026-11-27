class EloBot < Formula
  desc "ELO bot -- Telegram front-end for ELO agents"
  homepage "https://github.com/ceaser/homebrew-ceaser"
  url "https://github.com/ceaser/homebrew-ceaser/releases/download/elo-bot-v0.18.1/elo-bot-0.18.1-arm64.tar.gz"
  version "0.18.1"
  sha256 "ff731a6aa241de05e20dff21c8a71d6a1022143644736ec4c3fc2e815ba0b8ae"

  depends_on arch: :arm64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  service do
    run [opt_bin/"elo-bot", "foreground"]
    keep_alive true
    log_path var/"log/elo-bot.log"
    error_log_path var/"log/elo-bot.log"
    working_dir Dir.home
    environment_variables HOME: Dir.home
  end

  def caveats
    <<~EOS
      First-time setup after installation:

        mkdir -p ~/.config/elo-bot
        cp "#{opt_share}/doc/elo-bot/examples/bot.env.example" \\
           ~/.config/elo-bot/bot.env
        chmod 0600 ~/.config/elo-bot/bot.env

      Edit ~/.config/elo-bot/bot.env with your Telegram bot token and agent
      node settings, then run preflight checks and start the bot:

        elo-bot precheck
        brew services start elo-bot
    EOS
  end

  test do
    assert_predicate bin/"elo-bot", :exist?
    assert_predicate bin/"elo-bot", :executable?
  end
end
