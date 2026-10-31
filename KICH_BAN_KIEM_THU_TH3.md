# 🧪 KỊCH BẢN KIỂM THỬ TOÀN DIỆN & MA TRẬN ĐÁNH GIÁ AI ĐA GIỌNG NÓI (TH3)
## DỰ ÁN: ỨNG DỤNG HỌC TIẾNG ANH THÔNG MINH (SPEAKUP AI)

---

> **Môn học:** Phát triển Ứng dụng Di động (CSE441)  
> **Nhóm thực hiện:** Nhóm 16 — Lớp 65KTPM — Trường Đại học Thủy Lợi  
> **Chủ trì kiểm thử:** Nguyễn Văn Huỳnh (Nhóm trưởng) phối hợp toàn thể thành viên  

---

## 1. MA TRẬN ĐỐI SOÁT KIỂM THỬ 7 MỤC CHECKLIST ĐỀ BÀI

| Mã Test | Mục Checklist Liên Quan | Mục Tiêu Kiểm Thử | Dữ Liệu Đầu Vào & Thao Tác | Kết Quả Mong Đợi | Trạng Thái |
|:---:|:---|:---|:---|:---|:---:|
| **TC-01** | **Mục 1: Cơ sở dữ liệu** | Kiểm tra toàn vẹn dữ liệu người dùng, bài học, nhật ký chấm điểm | Tạo tài khoản, lưu 10 bản ghi chấm điểm phát âm vào SQLite & PostgreSQL | Bản ghi được lưu đầy đủ khóa ngoại, không null, truy vấn < 50ms | ✅ PASS |
| **TC-02** | **Mục 2: Chuỗi Streak** | Kiểm tra đếm chuỗi ngày liên tục và cơ chế bảo vệ chuỗi (Freeze) | Người dùng học ngày 1, ngày 2; sau đó giả lập bỏ ngày 3 (có freeze) và ngày 4 | Ngày 2: Streak=2; Ngày 3: Kích hoạt Freeze giữ nguyên Streak=2; Ngày 4: Học tiếp Streak=3 | ✅ PASS |
| **TC-03** | **Mục 2: Mục tiêu ngày** | Kiểm tra tích lũy thời gian học và đánh dấu đạt mục tiêu | Người dùng đặt mục tiêu 15 phút, học 3 phiên 5 phút | Thanh tiến độ đạt 100%, hệ thống đánh dấu `daily_goal_met = true`, bắn hiệu ứng chúc mừng | ✅ PASS |
| **TC-04** | **Mục 3: Thu âm Micro** | Kiểm tra thu âm từ Microphone và xuất file âm thanh chuẩn | Bấm giữ nút Micro 3 giây đọc từ "cat", nhả nút | Tạo file WAV 16kHz mono, dung lượng 40-100KB, Waveform hiển thị sóng âm mượt mà | ✅ PASS |
| **TC-05** | **Mục 3: Speech API** | Kiểm tra nhận dạng Speech-to-Text | Truyền luồng âm thanh vừa thu vào STT Service | Nhận diện chính xác chuỗi văn bản "cat", độ tin cậy > 90% | ✅ PASS |
| **TC-06** | **Mục 4: AI Chấm Điểm** | So sánh âm vị và tính điểm Accuracy, Fluency, Completeness | So sánh âm vị người đọc /k æ t/ với âm vị chuẩn /k æ t/ | Điểm tổng thể đạt 95 - 100 điểm, đánh giá trạng thái "Xuất sắc" | ✅ PASS |
| **TC-07** | **Mục 5: Module Phản Hồi** | Kiểm tra tô màu âm vị và phát hiện lỗi nuốt âm cuối | Người đọc phát âm "cats" thành "cat" (thiếu âm /s/) | Âm /k/ và /æ/ tô xanh lá, âm /t/ tô vàng, âm /s/ tô đỏ kèm ghi chú "Nuốt phụ âm cuối /s/" | ✅ PASS |
| **TC-08** | **Mục 5: Đề xuất bài tập** | Tự động gợi ý bài tập khắc phục sau khi phát hiện lỗi lặp lại | Người dùng phát âm sai âm /θ/ trong 3 từ liên tiếp | Tạo bản ghi đề xuất bài học "Âm lưỡi răng /θ/ và /ð/" trên màn hình Dashboard | ✅ PASS |
| **TC-09** | **Mục 6: Hệ thống Nhắc nhở**| Lên lịch thông báo nhắc học định kỳ và cảnh báo nguy cơ đứt chuỗi | Cài đặt nhắc học lúc 20:00, giả lập đến 20:30 người dùng chưa học | Thiết bị nhận Notification nhắc nhở với nội dung khích lệ giữ chuỗi ngày học | ✅ PASS |
| **TC-10** | **Mục 7: Kiểm thử AI Đa giọng**| Độ ổn định của bộ chấm điểm trước nhiều chất giọng và âm sắc khác nhau | Kiểm thử 20 mẫu âm thanh từ các đối tượng khác nhau | Đạt độ chính xác nhận diện lỗi > 88% trên toàn bộ tập mẫu | ✅ PASS |

---

## 2. KỊCH BẢN KIỂM THỬ AI VỚI NHIỀU NGƯỜI DÙNG & CÁC GIỌNG NÓI KHÁC NHAU (CHECKLIST 7)

Để đảm bảo mô hình phân tích và chấm điểm phát âm bằng AI hoạt động công bằng, chuẩn xác và không bị thiên lệch theo một chất giọng đơn lẻ, Nhóm 16 thiết kế ma trận kiểm thử thực nghiệm trên 8 kịch bản giọng nói đa dạng:

| STT | Nhóm Đối Tượng / Chất Giọng | Đặc Điểm Giọng Nói & Tạp Âm | Từ Thử Nghiệm | Ký Hiệu Âm Vị Đọc Thảo | Kết Quả Phân Tích AI | Đánh Giá Độ Chuẩn Xác |
|:---:|:---|:---|:---|:---|:---|:---:|
| **1** | **Giọng Việt Nam chuẩn**<br>(Sinh viên phát âm tốt) | Ngữ điệu rõ ràng, có âm đuôi, tốc độ vừa phải (120 wpm) | `cats` | [k, æ, t, s] | Điểm: 96/100<br>Tất cả âm vị xanh lá. | ✅ Chuẩn xác 100% |
| **2** | **Giọng Việt nuốt âm đuôi**<br>(Lỗi phổ biến nhất) | Thiếu triệt để phụ âm cuối /s/, /t/, /d/ | `cats` | [k, æ, t] *(mất âm s)* | Điểm: 68/100<br>Cảnh báo thiếu âm đuôi /s/. | ✅ Bắt đúng lỗi |
| **3** | **Giọng Việt sai nguyên âm**<br>(Nhầm âm ngắn và dài) | Đọc nguyên âm dài /i:/ ngắn lại giống /ɪ/ | `sheet` | [ʃ, ɪ, t] *(thành shit)* | Điểm: 55/100<br>Báo sai nguyên âm, hướng dẫn kéo dài âm /i:/. | ✅ Bắt đúng lỗi |
| **4** | **Giọng bản xứ Anh - Mỹ (US)**<br>(Chuẩn General American) | Âm uốn lưỡi /r/ rõ, âm /æ/ mở rộng | `water` | [w, ɔː, t, ər] | Điểm: 98/100<br>Đạt chuẩn bản xứ. | ✅ Chuẩn xác 100% |
| **5** | **Giọng bản xứ Anh - Anh (UK)**<br>(Chuẩn Received Pronunciation) | Không bật âm /r/ cuối, âm /ɒ/ sâu | `water` | [w, ɔː, t, ə] | Điểm: 94/100<br>Chấp nhận biến thể ngữ âm UK. | ✅ Chuẩn xác 100% |
| **6** | **Giọng nữ cao / Trẻ em**<br>(Âm vực Pitch: 250 - 350 Hz) | Tần số cơ bản cao, âm thanh mỏng | `think` | [θ, ɪ, ŋ, k] | Điểm: 91/100<br>Bộ lọc tiền xử lý chuẩn hóa tần số tốt. | ✅ Chuẩn xác |
| **7** | **Giọng nam trầm**<br>(Âm vực Pitch: 85 - 130 Hz) | Tần số thấp, độ vang buồng ngực lớn | `think` | [θ, ɪ, ŋ, k] | Điểm: 93/100<br>Nhận diện âm vô thanh /θ/ chính xác. | ✅ Chuẩn xác |
| **8** | **Môi trường quán Cafe ồn ào**<br>(Tiếng ồn nền 60 - 65 dB) | Có tiếng nhạc nền và tiếng người nói chuyện xa | `dogs` | [d, ɒ, ɡ, z] | Điểm: 84/100<br>Bộ khử nhiễu lọc tốt, bắt được âm /z/. | ✅ Đạt yêu cầu |

---

## 3. TIÊU CHUẨN NGHIỆM THU KỸ THUẬT (ACCEPTANCE CRITERIA)

1. **Hiệu năng & Độ trễ:**
   * Thời gian xử lý từ khi học viên buông nút Micro đến khi hiển thị kết quả chấm điểm AI: **≤ 1.2 giây**.
   * Ứng dụng không gây hiện tượng lag giật giao diện (đảm bảo 60 FPS trong lúc hiển thị sóng âm Waveform).
2. **Độ chính xác thuật toán AI (AI Precision & Recall):**
   * Tỷ lệ phát hiện đúng lỗi nuốt phụ âm đuôi (Ending Consonants): **≥ 92%**.
   * Tỷ lệ phát hiện đúng lỗi thay thế nguyên âm (Vowel Substitution): **≥ 88%**.
   * Tỷ lệ dương tính giả (bắt nhầm âm đúng thành sai): **≤ 5%**.
3. **Độ tin cậy hệ thống kỷ luật:**
   * Không xảy ra tình trạng mất chuỗi Streak nếu người dùng đã hoàn thành bài học trước 23:59:59 của ngày.
   * Thông báo cục bộ nhắc học hiển thị đúng giờ hẹn ngay cả khi ứng dụng bị tắt chạy ngầm.
