---
name: codex-review
description: Nhờ Codex CLI mổ và sửa thẳng vào một file plan CHƯA code — Claude thẩm định diff rồi chốt. Dùng khi user gõ /codex-review <đường dẫn plan>, hoặc nói "nhờ codex review plan", "cho codex mổ kế hoạch", "codex review". Chỉ áp cho bước lập kế hoạch, không áp cho code đã viết.
---

# Codex review một file plan

Plan cần mổ: lấy từ tham số user đưa vào (rỗng = hỏi user file nào).

**Chỉ dùng ở bước plan.** Code đã viết rồi thì không dùng skill này — dùng `ponytail-audit` hoặc `/code-review`.

## Bước 0 — Kiểm tra `codex` CLI có sẵn không

`command -v codex`. Không có thì báo user cài/đăng nhập `codex` trước rồi dừng — đừng tự bịa kết quả review.

## Bước 1 — Cây phải sạch

`git status --porcelain`. Còn thay đổi chưa commit thì **dừng**, báo user commit trước.
Lý do: Codex sắp ghi thẳng vào cây, `git diff` là mặt bằng review duy nhất — lẫn việc cũ vào là không đọc được nữa.

## Bước 2 — Codex vừa tìm lỗi vừa sửa

```
codex exec --ephemeral -m gpt-5.6-sol -s workspace-write "<đề bài dưới>"
```

Flag giải thích:
- `--ephemeral`: không lưu session rác vào lịch sử Codex.
- `-m gpt-5.6-sol`: model reasoning mạnh nhất hiện tại; thay bằng model khác nếu user yêu cầu.
- `-s workspace-write`: cho phép Codex ghi file trong workspace.

Đề bài đưa cho Codex:

> Đọc và sửa plan: [file]. Đây là kế hoạch CHƯA code. Bối cảnh: đội nhỏ/part-time, ưu tiên ít moving part hơn là đúng lý thuyết (hỏi user nếu quy mô dự án khác — nhiều người, đã production — thì bỏ giả định này).
>
> Tìm lỗi thật (mâu thuẫn nội tại, race, mất dữ liệu, auth, tiền/đơn hàng), chỗ over-engineer, rủi ro vận hành.
> **SỬA THẲNG vào file** — đừng chỉ mô tả. Sửa ngắn nhất có tác dụng, không nhân tiện refactor.
>
> Xong thì in manifest, mỗi thay đổi một khối:
>
> ```
> [SỬA] file:dòng — vấn đề — đã sửa thành gì
> [ĐỀ XUẤT] file:dòng — vấn đề — phương án đã chọn — phương án loại và vì sao
> [HỎI] mô tả — 2-3 phương án kèm đánh đổi — không tự sửa
> ```
>
> - `[SỬA]`: lỗi rõ ràng, chỉ có một cách đúng.
> - `[ĐỀ XUẤT]`: có nhiều đường, đã chọn một và sửa rồi — ghi rõ đường bị loại.
> - `[HỎI]`: **không đụng file** — đổi scope, đánh đổi sản phẩm, ảnh hưởng tiền/khách/dữ liệu thật.
>
> Không khen, không tóm tắt lại file.

## Bước 3 — Claude thẩm định

Đọc `git diff`, **không tin manifest**. Với từng hunk:

1. Đối chiếu với code/plan thật. Codex đọc sót ngữ cảnh là chuyện thường — đã gặp nhiều lần.
2. Sai hoặc thừa → `git checkout -- <file>` hoặc sửa lại hunk đó, ghi rõ vì sao bác.
3. Đúng → giữ.
4. `[ĐỀ XUẤT]` mà thấy phương án bị loại tốt hơn → đổi, nói rõ lý do.

Nếu project đang bật ponytail: hunk nào là kiến trúc thừa cho quy mô hiện tại thì bác, kể cả khi nó đúng về kỹ thuật.

## Bước 4 — Đưa user quyết

User phần lớn **không đọc code** — họ quản kết quả. Nên chỉ đẩy lên hai loại, và phải viết bằng ngôn ngữ hậu quả, không phải ngôn ngữ code:

- Mọi `[HỎI]` của Codex.
- Chỗ Claude và Codex **bất đồng** mà Claude không đủ cơ sở chốt.

Mỗi mục viết đúng khuôn này:

> **Chuyện gì**: một câu, mô tả cái khách/user nhìn thấy — không nhắc tên file, tên hàm, tên cột.
> **Hai đường**: A thì được gì mất gì · B thì được gì mất gì.
> **Nghiêng về**: … vì …
> **Do dự vì**: …

Ví dụ đúng: "Khách nhắn lúc 11h đêm — để bot tự trả lời (nhanh, nhưng sai thì không ai chặn) hay giữ lại chờ sáng user duyệt (chậm 8 tiếng, nhưng không bao giờ sai)."
Ví dụ sai: "`submit_reply` nên set `status=pending` hay `sent` khi `confidence < threshold`."

Còn lại tự quyết, đừng hỏi.

## Bước 5 — Báo cáo bằng tiếng người

**Không** dán `git diff`. Không liệt kê tên file. Báo đúng bốn phần:

1. **Đã sửa gì** — mỗi dòng một hậu quả nhìn thấy được: "trước đây khách bị nhắn lặp câu giữ chỗ 12 lần/giờ, giờ đúng 1 lần".
2. **Bác gì của Codex, vì sao** — để user biết Claude có thẩm định thật không, hay gật bừa.
3. **Bằng chứng nó chạy** — lệnh test/build của project, bao nhiêu/bao nhiêu, sạch không. Không chạy được thì nói thẳng là chưa có bằng chứng.
4. **Còn nợ gì** — thứ cố tình bỏ qua, và khi nào phải làm.

Không commit — chờ user gật ở bước 4.
