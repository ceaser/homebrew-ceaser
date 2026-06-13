# CI replaces 0.0.15, 0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5, and 9d9bf7c41e7cefeed0ec79339a5940d2554a34a4ca7f89d4edcd0c6dd769d18a before pushing
# this file to the ceaser/homebrew-ceaser tap as Formula/elo-agent.rb.
class EloAgent < Formula
  desc "ELO agent -- Claude coding assistant for Telegram"
  homepage "https://github.com/ceaser/elo"
  url "https://github.com/ceaser/elo/archive/refs/tags/v0.0.15.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  license "MIT"

  bottle do
    root_url "https://github.com/ceaser/elo/releases/download/v0.0.15"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9d9bf7c41e7cefeed0ec79339a5940d2554a34a4ca7f89d4edcd0c6dd769d18a"
  end

  depends_on "git"
  depends_on "erlang" => :build
  depends_on "rebar3" => :build

  def install
    # Build the OTP release with bundled ERTS.
    cd "agent" do
      system "rebar3", "as", "prod", "release"
    end

    # Install the release tree.  The release already contains bin/elo-agent
    # (the env-loading wrapper placed there by the relx overlay).
    libexec.install Dir["agent/_build/prod/rel/agent/*"]

    # Install a bin stub that chases symlinks on $0 to find the real script
    # location, then execs the release wrapper under libexec. The chase is
    # required for direct CLI invocation: /opt/homebrew/bin/elo-agent is a
    # symlink to a file in the Cellar, but /opt/homebrew/bin itself is a real
    # directory — `cd "$(dirname "$0")" && pwd -P` would NOT resolve the
    # symlink and would point ../libexec outside the Cellar.
    (bin/"elo-agent").write \
      (buildpath/"packaging/homebrew/bin-stub.sh").read.gsub("__NAME__", "elo-agent")

    # Install example config files.
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
