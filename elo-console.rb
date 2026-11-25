class EloConsole < Formula
  desc "ELO console -- local web console for the ELO Operator"
  homepage "https://github.com/ceaser/elo"
  url "https://github.com/ceaser/elo/archive/refs/tags/v0.16.0.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  license "MIT"

  bottle do
    root_url "https://github.com/ceaser/elo/releases/download/v0.16.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "99cbbd803fdcc8a99bd4ec51370c7278b5a4b4c70c8d69904c106f56a9f6928f"
  end

  depends_on "elixir" => :build
  depends_on "erlang" => :build

  def install
    cd "console" do
      ENV["MIX_ENV"] = "prod"
      system "mix", "local.hex", "--force"
      system "mix", "local.rebar", "--force"
      system "mix", "deps.get", "--only", "prod"
      system "mix", "assets.setup"
      system "mix", "assets.deploy"
      system "mix", "release", "--overwrite"
    end

    libexec.install Dir["console/_build/prod/rel/console/*"]

    (bin/"elo-console").write \
      (buildpath/"packaging/homebrew/bin-stub.sh").read.gsub("__NAME__", "elo-console")

    (share/"doc/elo-console/examples").install \
      "packaging/debian/console/examples/console.env.example"
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
