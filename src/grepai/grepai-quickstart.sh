#!/bin/bash
# Displayed at container start via postStartCommand

cat <<'MSG'

  ╔═════════════════════════════════════════════════════════════╗
  ║                     GrepAI — Quick Start                    ║
  ╠═════════════════════════════════════════════════════════════╣
  ║                                                             ║
  ║  1. Initialize your project:                                ║
  ║     grepai init                                             ║
  ║                                                             ║
  ║  2. Index your codebase:                                    ║
  ║     grepai watch                                            ║
  ║                                                             ║
  ║  3. Search semantically:                                    ║
  ║     grepai search "user authentication"                     ║
  ║                                                             ║
  ╠═════════════════════════════════════════════════════════════╣
  ║  MCP integration (Claude Code):                             ║
  ║     claude mcp add grepai -- grepai mcp-serve               ║
  ║                                                             ║
  ║  Docs:                                                      ║
  ║   https://yoanbernabeu.github.io/grepai/quickstart/         ║
  ║   https://yoanbernabeu.github.io/grepai/mcp/                ║
  ╚═════════════════════════════════════════════════════════════╝

MSG
