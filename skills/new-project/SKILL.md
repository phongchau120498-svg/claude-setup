---
name: new-project
description: Khởi tạo bộ khung vibe-coding chuẩn cho một dự án MỚI — tạo CLAUDE.md, HANDOFF.md, ROADMAP.md có nội dung thật (không phải template trống), git init nếu cần, và xác nhận bộ công cụ global (plan-reviewer, /handoff, SessionStart hook) đã sẵn sàng. Dùng khi user gõ /new-project, hoặc nói "khởi tạo dự án", "set up dự án mới", "dựng khung dự án".
---

# Khởi tạo dự án mới theo chuẩn vibe-coding

Mục tiêu: sau khi chạy xong, dự án có đủ 3 file kiến thức để mọi phiên/agent sau tự bám đúng bối cảnh, cộng bộ công cụ global hoạt động. Giao tiếp tiếng Việt.

## Nguyên tắc
- **Nội dung thật, không template rỗng.** Phải phỏng vấn user (hoặc đọc code nếu đã có) để điền thông tin cụ thể của dự án. File chung chung là vô dụng.
- **Không đè file đã có.** Nếu CLAUDE.md/HANDOFF.md/ROADMAP.md đã tồn tại, đọc và hỏi user muốn giữ, bổ sung, hay thay — KHÔNG ghi đè im lặng.
- **Ngắn gọn.** Mỗi file phải lean vì được nạp vào context mọi phiên.

## Quy trình

### 1. Kiểm tra bối cảnh
- Chạy `git status` xem đã là git repo chưa. Nếu chưa, hỏi user có muốn `git init` không rồi làm.
- `ls` + đọc lướt xem đã có code chưa (dự án mới tinh hay đã có sẵn). Nếu có code, đọc để tự suy stack thay vì hỏi lại.
- Kiểm tra global có sẵn công cụ không: `ls ~/.claude/agents/plan-reviewer.md ~/.claude/skills/handoff ~/.claude/settings.json`. Nếu thiếu cái nào, báo user (nhưng vẫn tiếp tục dựng phần project).

### 2. Phỏng vấn nhanh (chỉ hỏi cái chưa suy ra được từ code)
Hỏi gọn, ngôn ngữ kinh doanh, tối đa 4 câu:
1. App này là gì, phục vụ ai? (1-2 câu)
2. Stack dự định / đang dùng? (nếu code đã lộ thì bỏ qua)
3. Có ràng buộc cứng nào "đừng bao giờ đụng" không? (VD: đừng đổi schema, đừng bỏ service X, đừng dùng thư viện Y)
4. Mục tiêu/giai đoạn sắp tới là gì?

Có thể dùng AskUserQuestion nếu tiện. Nếu user bảo "cứ suy ra giúp anh", tự điền dựa trên code + ghi chú là giả định để user sửa sau.

### 3. Tạo `CLAUDE.md` (luật cứng, tự nạp mọi phiên)
Cấu trúc gọn:
```
# CLAUDE.md — <Tên dự án>
> Luật cứng, tự nạp mọi phiên. Giao tiếp: tiếng Việt.
## App là gì
## Stack + cách chạy (dev command)
## RÀNG BUỘC CỨNG (vi phạm = sai)   ← liệt kê từ câu hỏi 3
## Cách làm việc                     ← trỏ tới quy trình bên dưới
```

### 4. Tạo `HANDOFF.md` (việc còn lại + quyết định — KHÔNG chép việc đã làm)
```
# BÀN GIAO — <Tên dự án>
> File cho phiên/agent sau tiếp tục. Đọc trước khi làm.
> Cập nhật lần cuối: <ngày hôm nay>. Chỉ liệt kê VIỆC CẦN LÀM + quy ước còn hiệu lực.
> Việc đã xong xem git history.
## 0. Bối cảnh & cách chạy
## 1. <task đầu tiên>  (🟢 sẵn sàng / 🟡 cân nhắc / 🔴 bị chặn)
   - Bối cảnh / File liên quan / Định nghĩa xong
## Quyết định & ràng buộc còn hiệu lực
```

### 5. Tạo `ROADMAP.md` (chỉ nếu dự án đủ lớn / user muốn)
Mục tiêu cốt lõi + các giai đoạn. Nếu dự án nhỏ, bỏ qua và nói rõ.

### 6. Chốt
Báo cáo ngắn: đã tạo file nào, global sẵn sàng chưa. Nhắc quy trình 1 dòng:
> Vạch `PLAN.md` → `dùng subagent plan-reviewer` → sửa 🔴 → code → `git commit` + `/handoff`.
Nếu global hook `SessionStart` vừa mới tạo lần đầu, nhắc user restart Claude Code để hook kích hoạt.
KHÔNG tự commit trừ khi user yêu cầu.
```
