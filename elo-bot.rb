class EloBot < Formula
  desc "ELO bot -- Telegram front-end for ELO agents"
  homepage "https://github.com/ceaser/homebrew-ceaser"
  url "https://github.com/ceaser/homebrew-ceaser/releases/download/elo-bot-v0.18.0/elo-bot-0.18.0-arm64.tar.gz"
  version "0.18.0"
  sha256 "d8810a73bcfb09215178055f9c596c8c05eec890e7f425894f28e30b1ca11741"

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
