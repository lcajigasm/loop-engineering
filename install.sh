#!/bin/sh
# install.sh — install the loop-engineering skill for Claude Code and/or
# OpenAI Codex CLI.
#
# Usage: ./install.sh [--claude] [--codex] [--all] [--project <path>] [--force]
#
#   --claude          install the Claude Code adapter only
#   --codex           install the Codex adapter only
#   --all             both (default)
#   --project <path>  install into a project instead of the personal scope
#                     (Claude: <path>/.claude/…; Codex: <path>/.agents/skills/…;
#                     Codex prompts have no project scope and are skipped)
#   --force           overwrite files you have modified since install
#
# Idempotent: re-running updates unmodified files in place. A manifest of
# installed checksums (.installed-manifest in each skill dir) is how it
# tells "old version we installed" (safe to update) from "user-modified"
# (skipped unless --force). Layout installed:
#
#   Claude Code:  <root>/skills/loop-engineering/{SKILL.md,core/}
#                 <root>/commands/le/<cmd>.md            → /le:<cmd>
#   Codex:        <root>/skills/loop-engineering/{SKILL.md,core/}
#                 ~/.codex/prompts/le-<cmd>.md           → /prompts:le-<cmd>
set -eu

SRC=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DO_CLAUDE=0 DO_CODEX=0 PROJECT="" FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --claude) DO_CLAUDE=1; shift ;;
    --codex) DO_CODEX=1; shift ;;
    --all) DO_CLAUDE=1; DO_CODEX=1; shift ;;
    --project) PROJECT="$2"; shift 2 ;;
    --force) FORCE=1; shift ;;
    -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown flag: $1 (try --help)" >&2; exit 1 ;;
  esac
done
[ "$DO_CLAUDE" = 0 ] && [ "$DO_CODEX" = 0 ] && DO_CLAUDE=1 DO_CODEX=1
if [ -n "$PROJECT" ] && [ ! -d "$PROJECT" ]; then
  echo "No such directory: $PROJECT" >&2; exit 1
fi

sum() { cksum "$1" | awk '{print $1 ":" $2}'; }
TAB=$(printf '\t')

MANIFEST=""    # set per install root
INSTALLED=0 UPDATED=0 UNCHANGED=0 SKIPPED=0

# install_file <src> <dest>
install_file() {
  src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ ! -f "$dest" ]; then
    cp "$src" "$dest"; INSTALLED=$((INSTALLED + 1))
  elif [ "$(sum "$src")" = "$(sum "$dest")" ]; then
    UNCHANGED=$((UNCHANGED + 1))
  else
    recorded=$(grep -F "$TAB$dest" "$MANIFEST" 2>/dev/null | tail -n 1 | cut -f1 || true)
    if [ "$FORCE" = 1 ] || [ "$recorded" = "$(sum "$dest")" ]; then
      cp "$src" "$dest"; UPDATED=$((UPDATED + 1))
    else
      echo "  SKIP (locally modified, use --force): $dest" >&2
      SKIPPED=$((SKIPPED + 1)); return 0
    fi
  fi
  # record/update manifest entry
  grep -vF "$TAB$dest" "$MANIFEST" 2>/dev/null > "$MANIFEST.tmp" || true
  printf '%s\t%s\n' "$(sum "$dest")" "$dest" >> "$MANIFEST.tmp"
  mv "$MANIFEST.tmp" "$MANIFEST"
}

# install_tree <srcdir> <destdir>  (files only, recursive)
install_tree() {
  base="$1" destbase="$2"
  # no pipe: a `find | while` subshell would lose the counters
  filelist=$(mktemp)
  find "$base" -type f > "$filelist"
  while read -r f; do
    install_file "$f" "$destbase/${f#"$base"/}"
  done < "$filelist"
  rm -f "$filelist"
}

install_adapter() {
  tool="$1" skillroot="$2" skill_src="$3"
  mkdir -p "$skillroot"
  MANIFEST="$skillroot/.installed-manifest"
  install_file "$skill_src" "$skillroot/SKILL.md"
  install_tree "$SRC/core" "$skillroot/core"
  find "$skillroot/core/scripts" -name '*.sh' -exec chmod +x {} + 2>/dev/null || true
  echo "  $tool skill + core -> $skillroot"
}

if [ "$DO_CLAUDE" = 1 ]; then
  root="${PROJECT:+$PROJECT/.claude}"; root="${root:-$HOME/.claude}"
  echo "Claude Code:"
  install_adapter "Claude Code" "$root/skills/loop-engineering" \
    "$SRC/claude-code/skills/loop-engineering/SKILL.md"
  MANIFEST="$root/skills/loop-engineering/.installed-manifest"
  install_tree "$SRC/claude-code/commands/le" "$root/commands/le"
  echo "  commands -> $root/commands/le (invoke as /le:<name>)"
fi

if [ "$DO_CODEX" = 1 ]; then
  echo "Codex:"
  if [ -n "$PROJECT" ]; then
    root="$PROJECT/.agents"
  else
    root="$HOME/.agents"
  fi
  install_adapter "Codex" "$root/skills/loop-engineering" \
    "$SRC/codex/skills/loop-engineering/SKILL.md"
  if [ -z "$PROJECT" ]; then
    MANIFEST="$root/skills/loop-engineering/.installed-manifest"
    install_tree "$SRC/codex/prompts" "$HOME/.codex/prompts"
    echo "  prompts -> $HOME/.codex/prompts (invoke as /prompts:le-<name>)"
  else
    echo "  prompts skipped: Codex custom prompts have no project scope"
  fi
fi

echo
echo "Done: $INSTALLED installed, $UPDATED updated, $UNCHANGED unchanged, $SKIPPED skipped."
if [ "$SKIPPED" -gt 0 ]; then
  echo "Skipped files were locally modified; re-run with --force to overwrite."
fi
echo "Try it: run /le:help (Claude Code) or /prompts:le-help (Codex) in any project."
