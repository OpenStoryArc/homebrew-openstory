class OpenstoryMcp < Formula
  desc "MCP server for OpenStory — agent tools over stdio (optional companion)"
  homepage "https://github.com/OpenStoryArc/OpenStory"
  url "https://github.com/OpenStoryArc/OpenStory/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "ca18b250ecb54b16408d63011204b192864e07f63498a12b1d95f5593c09b691"
  license "Apache-2.0"
  head "https://github.com/OpenStoryArc/OpenStory.git", branch: "master"

  # Optional companion to `openstory`: install only if you want to give an agent
  # OpenStory's MCP tools. As of v0.3.0 the MCP server reads OpenStory over its
  # REST API (cwd-independent, remote-capable) — it no longer opens SQLite directly.
  depends_on "rust" => :build
  depends_on "openstory"

  def install
    cd "rs" do
      system "cargo", "install", *std_cargo_args(path: "mcp")
    end
  end

  def caveats
    <<~EOS
      Wire OpenStory's MCP tools into your agent (needs OpenStory running):
          claude mcp add openstory stdio #{opt_bin}/open-story-mcp

      The MCP server reads OpenStory over its REST API. Point it at your
      instance (local or remote):
          OPENSTORY_API_URL    (default http://localhost:3002)
          OPENSTORY_API_TOKEN  (optional bearer token for a secured instance)
          OPENSTORY_NATS_URL   (only for the live subscribe_* tools; default nats://localhost:4222)
    EOS
  end

  test do
    assert_path_exists bin/"open-story-mcp"

    # Guard the REST migration (v0.3.0+): the MCP reads OpenStory over its REST
    # API, so OPENSTORY_API_URL handling must be compiled into the binary. This
    # catches a regression to the old direct-SQLite-only build, which silently
    # returned empty results when pointed at an API instead of a data dir.
    assert_includes (bin/"open-story-mcp").binread, "OPENSTORY_API_URL"

    # The binary speaks the MCP protocol and exposes its tools (incl. the
    # REST-backed query tools). Timeout-guarded so it never hangs if the server
    # keeps stdout open after EOF; we only assert on what it emitted.
    require "timeout"
    handshake = <<~JSON
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"brew-test","version":"0"}}}
      {"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}
    JSON
    captured = +""
    begin
      Timeout.timeout(20) do
        IO.popen("#{bin}/open-story-mcp 2>/dev/null", "r+") do |io|
          io.write(handshake)
          io.close_write
          captured << io.read
        end
      end
    rescue Timeout::Error
      # server didn't close stdout on EOF — fine, the responses arrive first
    end
    assert_match "token_usage", captured
  end
end
