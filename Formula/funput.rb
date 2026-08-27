class Funput < Formula
  desc "Vietnamese input for the terminal (Telex/VNI) via a transparent PTY wrapper"
  homepage "https://funput.app"
  # `url`/`sha256`/`version` and the `bottle do` block below are bumped by
  # .github/workflows/bottle.yml on each upstream release. The tarball is the
  # `app/` git repo (github.com/Funput/Funput), so the workspace root is the
  # tarball root and the umbrella binary lives in crates/funput-cli (bin: funput).
  url "https://github.com/Funput/Funput/archive/refs/tags/v1.2026.73.tar.gz"
  sha256 "36e7c04309feb90a383123beec04700b599a269c6cb2e4b78d2f32369462f5e9"
  license "MIT"
  head "https://github.com/Funput/Funput.git", branch: "main"

  depends_on "rust" => :build

  # Prebuilt bottles hosted on this tap's GitHub Releases. When no bottle exists
  # for a user's macOS version / arch, Homebrew falls back to building from source
  # (that is what `depends_on "rust" => :build` is for), so the tap works from day
  # one even before bottle CI has published for every platform.
  bottle do
    root_url "https://github.com/Funput/homebrew-tap/releases/download/funput-1.2026.73"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "4cda1880441be407e9b15a3a9ba7341de40628e3caa21e8b6d26017cd0cdfee1"
    sha256 cellar: :any,                 x86_64_linux: "98663e4d3779b770d41489f52ffd41a3147ffc558d8fc96150131b0efdc66822"
  end

  def install
    # `std_cargo_args` adds `--locked` (needs the committed Cargo.lock) and installs
    # into the formula prefix. funput-cli produces the single `funput` binary.
    system "cargo", "install", *std_cargo_args(path: "crates/funput-cli")
  end

  test do
    assert_match "funput", shell_output("#{bin}/funput --version")
    assert_match "Type Vietnamese", shell_output("#{bin}/funput term --help")
    # `dev` engine path works without a TTY: "vieejt" (Telex) composes to "việt".
    assert_equal "việt", shell_output("#{bin}/funput dev run vieejt --method telex").strip
  end
end
