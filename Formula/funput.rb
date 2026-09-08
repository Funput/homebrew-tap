class Funput < Formula
  desc "Vietnamese input for the terminal (Telex/VNI) via a transparent PTY wrapper"
  homepage "https://funput.app"
  # `url`/`sha256`/`version` and the `bottle do` block below are bumped by
  # .github/workflows/bottle.yml on each upstream release. The tarball is the
  # `app/` git repo (github.com/Funput/Funput), so the workspace root is the
  # tarball root and the umbrella binary lives in crates/funput-cli (bin: funput).
  url "https://github.com/Funput/Funput/archive/refs/tags/v1.2026.77.tar.gz"
  sha256 "fd74b3bbd398701a0d00a09be7f050f3284edacc38bae5c4659bc176d73c3ace"
  license "MIT"
  head "https://github.com/Funput/Funput.git", branch: "main"

  depends_on "rust" => :build

  # Prebuilt bottles hosted on this tap's GitHub Releases. When no bottle exists
  # for a user's macOS version / arch, Homebrew falls back to building from source
  # (that is what `depends_on "rust" => :build` is for), so the tap works from day
  # one even before bottle CI has published for every platform.
  bottle do
    root_url "https://github.com/Funput/homebrew-tap/releases/download/funput-1.2026.77"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "e6a8b931ca4c2eefa2b00fdf399e94e879f8b98abcd8170ce946abb73310dff3"
    sha256 cellar: :any,                 x86_64_linux: "f3025d8e71bc0e86d19e98813b21544ac387aaaea2320800ad42d98982ed112f"
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
