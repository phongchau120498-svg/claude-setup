---
name: handoff
description: Chốt phiên làm việc — cập nhật HANDOFF.md để phiên sau (hoặc agent khác) tiếp tục không cần đọc lại toàn bộ ngữ cảnh. Dùng khi user gõ /handoff, hoặc nói "chốt phiên", "cập nhật handoff", "bàn giao". Ghi việc CÒN LẠI + quyết định mới, KHÔNG chép việc đã làm (git đã lo).
---

# Chốt phiên & cập nhật HANDOFF

Mục tiêu: để phiên sau khởi động đúng bối cảnh, không hiểu sai, không làm lại.

## Nguyên tắc gốc (đọc trước khi ghi)
Tách thông tin theo NGUỒN SỰ THẬT, đừng nhét chung:
- **"Đã làm gì"** → git đã ghi. TUYỆT ĐỐI không chép danh sách việc-đã-xong vào HANDOFF (phình file, trùng git, phiên sau phải đọc rác).
- **"Còn lại gì" + "tại sao" + "ràng buộc mới"** → không nơi nào khác biết → đây mới là việc của HANDOFF.

## Quy trình
1. **Xác định phiên này đã làm gì:** chạy `git log --oneline -15` và `git status` để biết thay đổi thực tế. Đây là cơ sở, KHÔNG phải để chép vào file.
2. **Tìm HANDOFF.md** ở gốc dự án. Nếu chưa có, hỏi user có muốn tạo mới không rồi dựng theo cấu trúc mục 4.
3. **Đọc HANDOFF.md hiện tại** để biết định dạng & quy ước dự án đang dùng — bám theo đúng định dạng đó, đừng áp khuôn riêng.
4. **Cập nhật đúng 3 việc:**
   a. **Tick việc đã xong:** đối chiếu git với danh sách "còn lại", xoá/đánh dấu xong những mục đã hoàn thành trong phiên.
   b. **Thêm task mới phát sinh:** với mỗi task mới, thêm vào mục backlog theo format:
      - Tên task + trạng thái (🟢 sẵn sàng / 🟡 cân nhắc / 🔴 bị chặn)
      - Bối cảnh: vì sao cần
      - File liên quan: đường dẫn
      - Định nghĩa xong: điều kiện coi là hoàn thành
   c. **Ghi quyết định/ràng buộc mới:** nếu phiên này chốt điều gì phiên sau PHẢI tuân (vd "đã đổi X, đừng đụng lại", "chọn cách A vì B"). Đây là giá trị lớn nhất — git không kể được.
5. **Cập nhật dòng "Cập nhật lần cuối"** nếu file có.
6. **KHÔNG tự commit** trừ khi user yêu cầu. Báo lại tóm tắt những gì đã thêm/sửa vào HANDOFF.

## Kiểm tra trước khi xong
- Có lỡ chép việc-đã-làm vào không? → bỏ, để git lo.
- Task mới có đủ "bối cảnh + file + định nghĩa xong" để người lạ làm được không?
- Quyết định quan trọng của phiên có được ghi lại không?
- Nếu là bài học lâu dài về dự án/cách làm việc (không phải việc của riêng phiên này), gợi ý user lưu vào Claude memory thay vì HANDOFF.
