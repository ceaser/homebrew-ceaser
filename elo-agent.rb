class EloAgent < Formula
  desc "ELO agent -- Claude coding assistant for Telegram"
  homepage "https://github.com/ceaser/elo"
  url "https://github.com/ceaser/elo/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  license "MIT"

  bottle do
    root_url "https://github.com/ceaser/elo/releases/download/v0.2.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f77ec74a562152bba402c01effc94a05123943975175275393149729351c126a"
  end

  depends_on "git"
  depends_on "erlang" => :build
  depends_on "rebar3" => :build

  def install
    cd "agent" do
      system "rebar3", "as", "prod", "release"
    end

    libexec.install Dir["agent/_build/prod/rel/agent/*"]

    (bin/"elo-agent").write \
      (buildpath/"packaging/homebrew/bin-stub.sh").read.gsub("__NAME__", "elo-agent")

    (share/"doc/elo-agent/examples").install \
      "packaging/debian/agent/examples/shared.env.example",
      "packaging/debian/agent/examples/local.env.example",
      "packaging/homebrew/agent/examples/README.md",
      "packaging/homebrew/agent/examples/logs-retention.launchd.plist"
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
