---
name: codex-review
description: Nhờ Codex (CLI `codex exec`) mổ và sửa thẳng vào một file plan CHƯA code — Claude thẩm định diff rồi chốt. Dùng khi user gõ /codex-review <đường dẫn plan>, hoặc nói "nhờ codex review plan", "cho codex mổ kế hoạch", "codex review". Chỉ áp cho bước lập kế hoạch, không áp cho code đã viết.
---

# Codex review một file plan

Plan cần mổ: `$ARGUMENTS`. Rỗng thì hỏi user file nào.

Plan chưa thành file, mới nằm trong hội thoại → **ghi ra file trước rồi mới mổ**. Codex sửa thẳng vào file; không có file thì không có gì để sửa.

**Chỉ dùng ở bước plan.** Code đã viết rồi thì không dùng skill này — dùng `ponytail-audit` hoặc `/code-review`.

## Bước 0 — Kiểm tra `codex` CLI có sẵn không

`command -v codex`. Không có thì báo user cài/đăng nhập `codex` trước rồi dừng — đừng tự bịa kết quả review.

## Bước 1 — Cây phải sạch, ghi lại mốc

`git status --porcelain`. Còn thay đổi chưa commit thì **dừng**, báo user commit trước.
Lý do: Codex sắp ghi thẳng vào cây, `git diff` là mặt bằng review duy nhất — lẫn việc cũ vào là không đọc được nữa.

Không phải git repo → dựng repo tạm trong scratchpad, copy plan + file ngữ cảnh nó cần vào đó, commit baseline. **Đừng `git init` vào thư mục của user.**

Ghi lại mốc: `git rev-parse HEAD` → gọi là `BASE`. Bước 4 reset về đúng SHA này.

## Bước 2 — Codex vừa tìm lỗi vừa sửa

**Tốn tiền.** Mỗi lượt `codex exec` cỡ 100–150k token; một lần review đủ vòng là tối đa 4 lượt.
Plan dưới ~200 dòng, hoặc user nói "soi nhanh" → chạy bước 2 xong nhảy thẳng bước 5, bỏ vòng phản biện. Chạy đủ vòng chỉ khi plan lớn hoặc đụng tiền/dữ liệu thật.

```
codex exec -m gpt-5.6-sol -c model_reasoning_effort="high" -s workspace-write "<đề bài dưới>"
```

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

## Bước 4 — Codex phản biện, lặp đến đồng thuận

Sau khi Claude thẩm định xong (bước 3), chạy vòng phản biện:

### 4a — Codex phản biện quyết định của Claude

Commit diff hiện tại (tạm, để Codex đọc cây sạch). Chạy:

```
codex exec -m gpt-5.6-sol -c model_reasoning_effort="high" -s workspace-write "<đề bài dưới>"
```

Đề bài:

> Đọc file [file] và `git log -1 --format=%B` (message commit tạm vừa rồi).
>
> Claude vừa thẩm định bản sửa của Codex lần trước — có hunk giữ, có hunk bác.
> Nhiệm vụ: **phản biện lại** những chỗ Claude bác hoặc sửa lại. Với từng điểm bất đồng:
>
> - Nếu Claude đúng: ghi `[ĐỒNG Ý]` — giải thích ngắn vì sao chấp nhận.
> - Nếu Claude sai hoặc có phương án tốt hơn: ghi `[PHẢN BÁC]` — nêu bằng chứng cụ thể (data flow, race, mất tiền/dữ liệu, UX), đề xuất phương án và **sửa thẳng vào file**.
>
> Tiêu chí chốt: **phương án nào cho xác suất thành công thực tế cao nhất** — không phải đúng lý thuyết, không phải thanh lịch, mà là cái chạy được, ít hỏng nhất, dễ sửa nhất khi hỏng.
>
> Không khen, không tóm tắt. Chỉ in manifest `[ĐỒNG Ý]` / `[PHẢN BÁC]`.

### 4b — Claude xét lại

Đọc `git diff` từ commit tạm. Với từng `[PHẢN BÁC]`:

1. Codex có bằng chứng mới mà Claude bỏ sót → **nhận**, giữ sửa của Codex.
2. Codex lặp lại lý lẽ cũ, không có bằng chứng mới → **bác**, revert hunk đó.
3. Cả hai đều có lý, không ai thắng rõ → đánh dấu là **bất đồng thật**, đẩy lên user ở bước 5.

Tiêu chí chốt giống nhau: **xác suất thành công thực tế cao nhất**.

### 4c — Kiểm tra đồng thuận

- Không còn `[PHẢN BÁC]` nào, hoặc mọi phản bác đã được Claude xử lý xong (nhận hoặc bác có lý do) → **đồng thuận đạt**, sang bước 5.
- Còn phản bác mới mà Claude chưa xét → quay lại 4b (tối đa 1 vòng nữa — tổng cộng Codex phản biện tối đa 2 lần, tránh chạy vô hạn).
- Sau vòng cuối vẫn bất đồng → ghi rõ điểm bất đồng, đẩy lên user ở bước 5.

Reset commit tạm: `git reset --soft <BASE>` (SHA ghi ở bước 1), để diff gộp lại sạch cho user duyệt.
Đừng đếm `HEAD~N` — đếm nhầm là nuốt luôn commit thật của user.

## Bước 5 — Đưa user quyết

User phần lớn **không đọc code** — họ quản kết quả. Nên chỉ đẩy lên hai loại, và phải viết bằng ngôn ngữ hậu quả, không phải ngôn ngữ code:

- Mọi `[HỎI]` của Codex.
- Chỗ Claude và Codex **bất đồng thật** sau vòng phản biện mà không ai thắng rõ.

Mỗi mục viết đúng khuôn này:

> **Chuyện gì**: một câu, mô tả cái khách/user nhìn thấy — không nhắc tên file, tên hàm, tên cột.
> **Hai đường**: A thì được gì mất gì · B thì được gì mất gì.
> **Nghiêng về**: … vì …
> **Do dự vì**: …

Ví dụ đúng: "Khách nhắn lúc 11h đêm — để bot tự trả lời (nhanh, nhưng sai thì không ai chặn) hay giữ lại chờ sáng user duyệt (chậm 8 tiếng, nhưng không bao giờ sai)."
Ví dụ sai: "`submit_reply` nên set `status=pending` hay `sent` khi `confidence < threshold`."

Còn lại tự quyết, đừng hỏi.

## Bước 6 — Báo cáo bằng tiếng người

Cổng chặn — thiếu dòng nào thì quay lại làm nốt, đừng báo cáo:

- Mọi hunk trong `git diff` đã đọc và có kết luận giữ hoặc bác, kèm lý do.
- Mọi `[HỎI]` của Codex đã xuất hiện ở bước 5, không nuốt cái nào.
- Commit tạm đã reset về `BASE`; `git log` không còn commit rác.
- Không dòng báo cáo nào là tính từ suông ("plan chặt hơn") — mỗi dòng một hậu quả cụ thể.

**Không** dán `git diff`. Không liệt kê tên file. Báo đúng bốn phần:

1. **Đã sửa gì** — mỗi dòng một hậu quả nhìn thấy được: "trước đây khách bị nhắn lặp câu giữ chỗ 12 lần/giờ, giờ đúng 1 lần".
2. **Vòng phản biện** — Codex phản biện mấy vòng, điểm nào Claude nhận lại, điểm nào bác tới cùng — để user biết cả hai model đã đấu thật chứ không gật bừa.
3. **Bằng chứng nó chạy** — lệnh test/build của project, bao nhiêu/bao nhiêu, sạch không. Không chạy được thì nói thẳng là chưa có bằng chứng.
4. **Còn nợ gì** — thứ cố tình bỏ qua, và khi nào phải làm.

Không commit — chờ user gật ở bước 5.
