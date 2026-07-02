class Funput < Formula
  desc "Vietnamese input for the terminal (Telex/VNI) via a transparent PTY wrapper"
  homepage "https://funput.app"
  # `url`/`sha256`/`version` and the `bottle do` block below are bumped by
  # .github/workflows/bottle.yml on each upstream release. The tarball is the
  # `app/` git repo (github.com/Funput/Funput), so the workspace root is the
  # tarball root and the umbrella binary lives in crates/funput-cli (bin: funput).
  url "https://github.com/Funput/Funput/archive/refs/tags/v1.2026.41.tar.gz"
  sha256 "b459893f2c8b38d2264ff5ee43b61d43d4fd7a2d59e3fc1f34092a56c602b6b2"
  license "MIT"
  head "https://github.com/Funput/Funput.git", branch: "main"

  depends_on "rust" => :build

  # Prebuilt bottles hosted on this tap's GitHub Releases. When no bottle exists
  # for a user's macOS version / arch, Homebrew falls back to building from source
  # (that is what `depends_on "rust" => :build` is for), so the tap works from day
  # one even before bottle CI has published for every platform.
  bottle do
    root_url "https://github.com/Funput/homebrew-tap/releases/download/funput-1.2026.41"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "73d69e1caa4e88d1dd11f479297776c69c908afadd48270bef67b1a3227c573a"
    sha256 cellar: :any,                 x86_64_linux: "cb1b143b94717709b1e626f9099facb5b73cf57cd51faa7dd8ba964283d76122"
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
