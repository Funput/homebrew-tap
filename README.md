# Funput Homebrew Tap

Homebrew formulae for [Funput](https://funput.app). Ship this directory as its own
public GitHub repo named **`Funput/homebrew-tap`** (the `homebrew-` prefix is
required so `brew tap funput/tap` resolves to it).

## Install

```sh
brew tap funput/tap
brew install funput
```

Works on both **macOS** and **Linux** (Linuxbrew). `brew install funput` uses a
prebuilt **bottle** when one exists for your platform — macOS **arm64** or
**`x86_64_linux`** (instant, no compiler). Otherwise Homebrew falls back to building
from source — that is what `depends_on "rust" => :build` in the formula is for — so
the tap works everywhere, including platforms with no free CI runner to bottle on:
**Intel macOS** and **arm64 Linux** build from source.

The single `funput` binary is the umbrella command:

- `funput term -- <program>` — type Vietnamese (Telex/VNI) inside terminal apps via
  a transparent PTY wrapper. Toggle with `Ctrl-\`. No IME, no system permissions.
- `funput term install --alias <cmd>` — wire it into your shell so it's always on.
- `funput dev …` — engine dev/CI tools (`run`, `repl`, `coverage`).

## How releases flow

1. A tag push on `Funput/Funput` runs its `release.yml`, which (for real,
   non-prerelease releases) fires a `repository_dispatch` of type `release` at this
   repo with the version in `client_payload.version`.
   - Requires a `HOMEBREW_TAP_TOKEN` secret on the main repo: a PAT with
     `contents: write` on `Funput/homebrew-tap`.
2. [`bottle.yml`](.github/workflows/bottle.yml) here then:
   - bumps `url` + `sha256` in [`Formula/funput.rb`](Formula/funput.rb) to the new tag,
   - builds bottles on `macos-14` (arm64) and `ubuntu-latest` (`x86_64_linux`),
   - uploads the bottle tarballs to a `funput-<version>` GitHub Release on this repo,
   - merges the per-platform checksums into the formula's `bottle do` block and commits.

You can also run `bottle.yml` manually via **workflow_dispatch**, passing the
version, to (re)build bottles for an existing release.

## Notes

- **No code signing / notarization needed.** CLI binaries installed via Homebrew are
  not quarantined by Gatekeeper, so bottles don't require an Apple Developer signature.
- **`homebrew-core`** (plain `brew install funput` with no tap) is a separate, later
  step gated by Homebrew's own review. This third-party tap is fully self-managed.
- The formula builds from the source tarball of `Funput/Funput`, whose git root is
  the `app/` workspace — hence the crate path `crates/funput-cli` inside the formula.

## Validating changes locally

```sh
brew tap funput/tap /path/to/this/repo    # tap from a local clone
brew audit --tap funput/tap funput
brew install --build-from-source funput
brew test funput
```
