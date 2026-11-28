class EloConsole < Formula
  desc "ELO console -- local web console for the ELO Operator"
  homepage "https://github.com/ceaser/homebrew-ceaser"
  url "https://github.com/ceaser/homebrew-ceaser/releases/download/elo-console-v0.19.0/elo-console-0.19.0-arm64.tar.gz"
  version "0.19.0"
  sha256 "05771490c17489b346736e9fa5e76fe1f0730183d1425f2a2c126cd56ef72f65"

  depends_on arch: :arm64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  service do
    run [opt_bin/"elo-console", "start"]
    keep_alive true
    log_path var/"log/elo-console.log"
    error_log_path var/"log/elo-console.log"
    working_dir Dir.home
    environment_variables HOME: Dir.home
  end

  def caveats
    <<~EOS
      First-time setup after installation:

        mkdir -p ~/.config/elo-console
        cp "#{opt_share}/doc/elo-console/examples/console.env.example" \\
           ~/.config/elo-console/console.env
        chmod 0600 ~/.config/elo-console/console.env

      Set CONSOLE_COOKIE in ~/.config/elo-console/console.env to the cookie
      the bot and agent use, then run preflight checks and start the console:

        elo-console precheck
        brew services start elo-console

      Then open http://localhost:4000 in a browser.
    EOS
  end

  test do
    assert_predicate bin/"elo-console", :exist?
    assert_predicate bin/"elo-console", :executable?
  end
end
