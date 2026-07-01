#!/usr/bin/env bash
# Cài bộ công cụ Claude Code global vào máy này (~/.claude).
# Chạy: bash install.sh
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"
DST="$HOME/.claude"

echo "→ Cài từ: $SRC"
echo "→ Vào:    $DST"

mkdir -p "$DST/agents" "$DST/skills/handoff" "$DST/skills/new-project"

cp "$SRC/agents/plan-reviewer.md"     "$DST/agents/plan-reviewer.md"
cp "$SRC/skills/handoff/SKILL.md"     "$DST/skills/handoff/SKILL.md"
cp "$SRC/skills/new-project/SKILL.md" "$DST/skills/new-project/SKILL.md"
echo "✓ Đã cài: agent plan-reviewer, skill /handoff, skill /new-project"

# settings.json chứa hook — cẩn thận không đè cấu hình đã có
if [ ! -f "$DST/settings.json" ]; then
  cp "$SRC/settings.json" "$DST/settings.json"
  echo "✓ Đã tạo settings.json (có SessionStart hook nạp HANDOFF.md)"
else
  echo "⚠ Máy này ĐÃ có ~/.claude/settings.json — KHÔNG đè để khỏi mất cấu hình cũ."
  echo "  Hãy tự thêm khối hook này vào (gộp vào 'hooks' nếu đã có):"
  echo "  -------------------------------------------------------------"
  cat "$SRC/settings.json"
  echo "  -------------------------------------------------------------"
fi

echo
echo "XONG. Khởi động lại Claude Code để hook SessionStart kích hoạt."
echo "Kiểm tra: gõ /new-project và /handoff xem có hiện không."
