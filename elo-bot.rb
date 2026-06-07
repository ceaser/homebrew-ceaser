# CI replaces 0.0.11, 0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5, and 74862877dff05f56e6180b21fb77ba6d425574ae8d2fb0f51df1a22651a36281 before pushing
# this file to the ceaser/homebrew-ceaser tap as Formula/elo-bot.rb.
class EloBot < Formula
  desc "ELO bot -- Telegram front-end for ELO agents"
  homepage "https://github.com/ceaser/elo"
  url "https://github.com/ceaser/elo/archive/refs/tags/v0.0.11.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  license "MIT"

  bottle do
    root_url "https://github.com/ceaser/elo/releases/download/v0.0.11"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "74862877dff05f56e6180b21fb77ba6d425574ae8d2fb0f51df1a22651a36281"
  end

  depends_on "erlang" => :build
  depends_on "rebar3" => :build

  def install
    cd "bot" do
      system "rebar3", "as", "prod", "release"
    end

    libexec.install Dir["bot/_build/prod/rel/bot/*"]

    # Install a bin stub that chases symlinks on $0 to find the real script
    # location, then execs the release wrapper under libexec. The chase is
    # required for direct CLI invocation: /opt/homebrew/bin/elo-bot is a
    # symlink to a file in the Cellar, but /opt/homebrew/bin itself is a real
    # directory — `cd "$(dirname "$0")" && pwd -P` would NOT resolve the
    # symlink and would point ../libexec outside the Cellar.
    (bin/"elo-bot").write \
      (buildpath/"packaging/homebrew/bin-stub.sh").read.gsub("__NAME__", "elo-bot")

    (share/"doc/elo-bot/examples").install \
      "packaging/debian/bot/examples/bot.env.example",
      "packaging/debian/bot/examples/README.md"
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
