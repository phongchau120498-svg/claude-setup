# claude-setup — bộ công cụ Claude Code dùng chung mọi dự án

Chứa các file GLOBAL (nằm ở `~/.claude/`, không thuộc dự án nào):

- `agents/plan-reviewer.md` — subagent phản biện kế hoạch
- `skills/handoff/SKILL.md` — lệnh `/handoff` chốt phiên
- `skills/new-project/SKILL.md` — lệnh `/new-project` dựng khung dự án mới
- `settings.json` — hook `SessionStart` tự nạp `HANDOFF.md`

## Cài lên một máy mới (vd máy công ty)

1. Mang cả thư mục `claude-setup` này sang máy đó (iCloud/Drive/USB/git đều được).
2. Mở Terminal, chạy:
   ```
   bash ~/claude-setup/install.sh
   ```
3. Khởi động lại Claude Code.
4. Kiểm tra: gõ `/new-project` và `/handoff` — nếu hiện là xong.

## Cập nhật sau này
Khi sửa/thêm công cụ global ở một máy, chép lại vào thư mục này rồi mang sang máy kia chạy lại `install.sh`. (Hoặc `git init` thư mục này + push để đồng bộ tự động.)
