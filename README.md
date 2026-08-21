# claude-setup — bộ công cụ Claude Code dùng chung mọi dự án

Chứa các file GLOBAL (nằm ở `~/.claude/`, không thuộc dự án nào):

- `agents/plan-reviewer.md` — subagent phản biện kế hoạch
- `skills/handoff/SKILL.md` — lệnh `/handoff` chốt phiên
- `skills/new-project/SKILL.md` — lệnh `/new-project` dựng khung dự án mới
- `skills/codex-review/SKILL.md` — lệnh `/codex-review <file plan>`, nhờ Codex CLI mổ + sửa thẳng vào một plan chưa code, Claude thẩm định lại
- `settings.json` — hook `SessionStart` tự nạp `HANDOFF.md`

## Cài lên một máy mới (vd máy nhà, máy công ty)

1. Clone repo này:
   ```
   git clone git@github.com:phongchau120498-svg/claude-setup.git ~/claude-setup
   ```
2. Chạy:
   ```
   bash ~/claude-setup/install.sh
   ```
3. Khởi động lại Claude Code.
4. Kiểm tra: gõ `/new-project`, `/handoff`, `/codex-review` — nếu hiện là xong.

Riêng `/codex-review` cần thêm CLI `codex` cài + đăng nhập sẵn trên máy đó — skill chỉ là hướng dẫn, không tự cài CLI.

## Cập nhật sau này
Sửa/thêm công cụ global ở máy nào thì chép lại vào thư mục `~/claude-setup` ở máy đó, `git add . && git commit && git push`. Máy khác chạy `git pull && bash install.sh` để nhận bản mới.
