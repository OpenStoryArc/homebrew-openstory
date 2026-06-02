# homebrew-openstory

Homebrew tap for [OpenStory](https://github.com/OpenStoryArc/OpenStory) — real-time visibility into AI coding agent behavior.

## Install

```sh
brew tap OpenStoryArc/openstory
brew install openstory
brew services start nats-server
brew services start openstory
```

Open <http://localhost:3002>. The dashboard loads as soon as your first Claude Code session writes to `~/.claude/projects/`.

Data lives at `$(brew --prefix)/var/openstory`. Uninstalling preserves it.

## v0.1.0 — source build

This is the first public release. The formula compiles from source on install (~3 min: Rust + Node toolchain build the `open-story-cli` binary and the React dashboard). Prebuilt bottles for `arm64_sonoma` / `ventura` are planned for v0.2.0 via GHCR — see the main repo's `docs/BACKLOG.md` Distribution section.

## What you get

- `open-story` — the CLI (server, watcher, query commands)
- `brew services start openstory` — runs the server as a managed launchd job
- `share/openstory/static` — the React dashboard, served by the binary at `http://localhost:3002`

## Where the project lives

[OpenStoryArc/OpenStory](https://github.com/OpenStoryArc/OpenStory) — main repo. Issues, docs, and the architecture tour are there.

## Updating the formula

The canonical formula lives at `Formula/openstory.rb` in **this** tap repo. The main OpenStory repo keeps a synchronized copy at `Formula/openstory.rb` that the `Formula test` CI workflow validates by building it inside a `homebrew/brew` container on every PR that touches `Formula/**`. When a new tag ships, the main repo's formula is updated with the real `sha256`, then copied here.

## License

Apache-2.0 — matches the main OpenStory repo.
