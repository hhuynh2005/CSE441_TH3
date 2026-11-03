# 📘 BÁO CÁO KỸ THUẬT NGHIỆM THU CHI TIẾT 7 MỤC CHECKLIST (TH3)
## DỰ ÁN: ỨNG DỤNG HỌC TIẾNG ANH THÔNG MINH - SPEAKUP AI
### HỆ THỐNG LUYỆN PHÁT ÂM TIẾNG ANH AI & THEO DÕI KỶ LUẬT HỌC TẬP HẰNG NGÀY

---

> 🏛️ **TRƯỜNG ĐẠI HỌC THỦY LỢI — KHOA CÔNG NGHỆ THÔNG TIN**  
> 📚 **Học phần:** Phát triển Ứng dụng Di động (Mobile Application Development - CSE441)  
> 👥 **Đơn vị thực hiện:** **Nhóm 16 — Lớp 65KTPM**  
> 👨‍💻 **Thành viên nhóm:**  
> 1. **Nguyễn Văn Huỳnh (2351170599)** — *Nhóm trưởng (Architecture, Database & DevOps)*  
> 2. **Lê Anh Tuấn (2151060296)** — *Thành viên (Streak, Progress & Notifications)*  
> 3. **Nguyễn Trung Kiên (2251172394)** — *Thành viên (Speech Recognition & Audio UI)*  
> 4. **Trần Anh Tuấn (2351170629)** — *Thành viên (AI Phoneme Engine & Feedback)*  
> 📅 **Thời gian hoàn thành:** Học kỳ 1 — Năm học 2026–2027  
> 📊 **Kết quả nghiệm thu tổng thể:** **Hoàn thành 7/7 Mục Checklist (100%) — 36/36 Test Cases Đạt**

---

## 📑 BẢNG TỔNG HỢP TIẾN ĐỘ VÀ ĐỐI SOÁT 7 MỤC CHECKLIST ĐỀ BÀI

| Mục | Nội Dung Checklist Yêu Cầu | Giải Pháp Kỹ Thuật Thực Hiện | Tệp Triển Khai Chính | Trạng Thái |
|:---:|:---|:---|:---|:---:|
| **1** | **Thiết kế cơ sở dữ liệu** | Xây dựng Schema CSDL quan hệ 7 bảng, hỗ trợ SQLite Local Cache Offline-First và đồng bộ đám mây PostgreSQL. | [`th3_database_schema.sql`](file:///D:/Nam_4/Mobile/TH3/th3_database_schema.sql)<br>[`THIET_KE_KIEN_TRUC_CSDL_TH3.md`](file:///D:/Nam_4/Mobile/TH3/THIET_KE_KIEN_TRUC_CSDL_TH3.md) | ✅ Hoàn thành 100% |
| **2** | **Theo dõi tiến độ học tập** | Thuật toán tính chuỗi ngày liên tục (Streak Counter), cơ chế bảo vệ Freeze Streak, quản lý Daily Goals và tổng thời gian học. | [`lib/services/streak_service.dart`](file:///D:/Nam_4/Mobile/TH3/lib/services/streak_service.dart)<br>[`lib/models/user_progress_model.dart`](file:///D:/Nam_4/Mobile/TH3/lib/models/user_progress_model.dart) | ✅ Hoàn thành 100% |
| **3** | **Tích hợp Speech Recognition API** | Quản lý thu âm Micro định dạng chuẩn WAV 16kHz mono, bộ lọc nhiễu Noise Gate, bóc tách mốc thời gian từ và âm vị, Web TTS & Audio Playback. | [`lib/services/audio_recording_manager.dart`](file:///D:/Nam_4/Mobile/TH3/lib/services/audio_recording_manager.dart)<br>[`lib/services/speech_recognition_service.dart`](file:///D:/Nam_4/Mobile/TH3/lib/services/speech_recognition_service.dart)<br>[`lib/widgets/waveform_visualizer.dart`](file:///D:/Nam_4/Mobile/TH3/lib/widgets/waveform_visualizer.dart) | ✅ Hoàn thành 100% |
| **4** | **AI so sánh âm vị & Chấm điểm** | Bộ chuyển ký tự sang ngữ âm quốc tế IPA (G2P), thuật toán căn gióng Levenshtein âm vị, công thức chấm điểm 3 tiêu chí: Accuracy, Fluency, Completeness. | [`lib/services/phoneme_comparison_engine.dart`](file:///D:/Nam_4/Mobile/TH3/lib/services/phoneme_comparison_engine.dart)<br>[`lib/services/pronunciation_scoring_service.dart`](file:///D:/Nam_4/Mobile/TH3/lib/services/pronunciation_scoring_service.dart) | ✅ Hoàn thành 100% |
| **5** | **Module phản hồi trực quan** | Thẻ điểm số trực quan (ScoreCardWidget), highlight tô màu trực tiếp từng âm vị (xanh: đúng, đỏ: sai, cam: nuốt âm), gợi ý bài học cá nhân hóa. | [`lib/widgets/score_card_widget.dart`](file:///D:/Nam_4/Mobile/TH3/lib/widgets/score_card_widget.dart)<br>[`lib/widgets/phoneme_feedback_widget.dart`](file:///D:/Nam_4/Mobile/TH3/lib/widgets/phoneme_feedback_widget.dart)<br>[`lib/services/targeted_lesson_recommender.dart`](file:///D:/Nam_4/Mobile/TH3/lib/services/targeted_lesson_recommender.dart) | ✅ Hoàn thành 100% |
| **6** | **Thông báo nhắc nhở & UI tiến độ** | Lập lịch thông báo định kỳ (`flutter_local_notifications`), cảnh báo khẩn cấp vào 20:00 cứu chuỗi Streak, giao diện Bảng điều khiển tiến độ Dashboard. | [`lib/services/daily_notification_service.dart`](file:///D:/Nam_4/Mobile/TH3/lib/services/daily_notification_service.dart)<br>[`lib/views/progress_dashboard_view.dart`](file:///D:/Nam_4/Mobile/TH3/lib/views/progress_dashboard_view.dart)<br>[`lib/widgets/streak_badge_widget.dart`](file:///D:/Nam_4/Mobile/TH3/lib/widgets/streak_badge_widget.dart) | ✅ Hoàn thành 100% |
| **7** | **Kiểm thử đa người dùng & Đa giọng nói** | Kịch bản kiểm thử Multi-Accent (giọng Việt, giọng nuốt âm đuôi, giọng bản xứ US/UK), 36 bài kiểm thử tự động đạt 100% và phân tích tĩnh không lỗi. | [`test/audio_recording_speech_test.dart`](file:///D:/Nam_4/Mobile/TH3/test/audio_recording_speech_test.dart)<br>[`test/phoneme_engine_test.dart`](file:///D:/Nam_4/Mobile/TH3/test/phoneme_engine_test.dart)<br>[`test/streak_service_test.dart`](file:///D:/Nam_4/Mobile/TH3/test/streak_service_test.dart) | ✅ 36/36 Tests Passed |

---

## 📌 PHẦN 1: CHECKLIST 1 — THIẾT KẾ CƠ SỞ DỮ LIỆU
* **Phụ trách:** Nguyễn Văn Huỳnh (2351170599) — Nhóm trưởng  
* **Tệp triển khai:** [`th3_database_schema.sql`](file:///D:/Nam_4/Mobile/TH3/th3_database_schema.sql), [`THIET_KE_KIEN_TRUC_CSDL_TH3.md`](file:///D:/Nam_4/Mobile/TH3/THIET_KE_KIEN_TRUC_CSDL_TH3.md)

### 1.1. Mục tiêu và Kiến trúc CSDL
Hệ thống CSDL được thiết kế theo mô hình lai (Hybrid Offline-First Cache) kết hợp giữa CSDL quan hệ chuẩn PostgreSQL trên Cloud (Supabase) và SQLite cục bộ trong thiết bị để học viên có thể học tập và lưu dữ liệu ngay cả khi mất mạng:

```mermaid
erDiagram
    USERS ||--o{ DAILY_STREAKS : tracks
    USERS ||--o{ PRACTICE_SESSIONS : conducts
    LESSONS ||--o{ PRACTICE_WORDS : contains
    PRACTICE_SESSIONS ||--o{ PRONUNCIATION_LOGS : records
    PRACTICE_WORDS ||--o{ PRONUNCIATION_LOGS : evaluated_in
    PRONUNCIATION_LOGS ||--o{ PHONEME_RESULTS : details

    USERS {
        VARCHAR id PK
        VARCHAR email
        VARCHAR display_name
        INTEGER daily_goal_minutes
        INTEGER daily_goal_words
        INTEGER streak_freeze_count
    }

    DAILY_STREAKS {
        VARCHAR id PK
        VARCHAR user_id FK
        INTEGER current_streak
        INTEGER longest_streak
        DATE last_practice_date
        INTEGER freeze_available
    }

    PRACTICE_WORDS {
        VARCHAR id PK
        VARCHAR lesson_id FK
        VARCHAR word
        VARCHAR ipa_target
        VARCHAR meaning_vi
        VARCHAR difficulty_level
    }

    PRONUNCIATION_LOGS {
        VARCHAR id PK
        VARCHAR session_id FK
        VARCHAR word_id FK
        FLOAT overall_score
        FLOAT accuracy_score
        FLOAT fluency_score
        FLOAT completeness_score
        VARCHAR recognized_text
    }

    PHONEME_RESULTS {
        VARCHAR id PK
        VARCHAR log_id FK
        VARCHAR phoneme_target
        VARCHAR phoneme_actual
        FLOAT score
        VARCHAR error_type
    }
```

### 1.2. Các bảng dữ liệu chính trong CSDL
1. **`users`:** Quản lý tài khoản, thông tin hồ sơ, mục tiêu ngày và số lượng khiên đóng băng Freeze Streak sở hữu.
2. **`daily_streaks`:** Lưu trữ chính xác chuỗi ngày học hiện tại (`current_streak`), kỷ lục chuỗi dài nhất (`longest_streak`), ngày học gần nhất và lịch sử điểm danh.
3. **`lessons` & `practice_words`:** Danh mục bài học phân cấp theo chủ đề (Daily Life, Business, Academic) và kho từ vựng kèm phiên âm chuẩn quốc tế IPA (`ipa_target`).
4. **`practice_sessions`:** Nhật ký phiên học ghi lại thời gian bắt đầu, kết thúc, tổng số phút học và số từ vựng đã luyện tập.
5. **`pronunciation_logs`:** Bảng ghi kết quả chấm điểm từng từ với đầy đủ điểm số thành phần (Accuracy, Fluency, Completeness, Overall Score).
6. **`phoneme_results`:** Lưu trữ chi tiết lỗi ở mức âm vị nhỏ nhất (âm đúng, âm sai thay thế, âm bị nuốt) phục vụ thuật toán cá nhân hóa bài học ở Checklist 5.

---

## 📌 PHẦN 2: CHECKLIST 2 — THEO DÕI TIẾN ĐỘ HỌC TẬP (STREAK & MỤC TIÊU)
* **Phụ trách:** Lê Anh Tuấn (2151060296)  
* **Tệp triển khai:** [`lib/services/streak_service.dart`](file:///D:/Nam_4/Mobile/TH3/lib/services/streak_service.dart), [`lib/models/user_progress_model.dart`](file:///D:/Nam_4/Mobile/TH3/lib/models/user_progress_model.dart)

### 2.1. Thuật toán tính toán chuỗi ngày liên tục (Streak Counter)
Thuật toán dựa trên việc tính toán khoảng cách ngày chuẩn hóa (`normalized difference in calendar days`) giữa ngày học hôm nay và ngày học hợp lệ gần nhất:

$$\Delta Days = Date_{today} - Date_{lastPractice}$$

* **Trường hợp 1 ($\Delta Days = 0$):** Học viên đã hoàn thành buổi học trong ngày. Chuỗi `current_streak` giữ nguyên, thời gian học (`todayMinutesLearned`) và số từ (`todayWordsPracticed`) được cộng dồn.
* **Trường hợp 2 ($\Delta Days = 1$):** Học viên tiếp tục duy trì kỷ luật vào ngày kế tiếp. Chuỗi `current_streak = current_streak + 1`. Tự động cập nhật `longest_streak = \max(longest_streak, current_streak)`.
* **Trường hợp 3 ($\Delta Days > 1$):** Học viên bỏ lỡ ít nhất 1 ngày:
  * *Nếu còn khiên Freeze Streak ($freezeCount > 0$):* Tự động tiêu hao 1 khiên để bảo toàn nguyên vẹn chuỗi ngày học mà không bị phạt.
  * *Nếu hết khiên Freeze Streak ($freezeCount = 0$):* Chuỗi ngày học bị gián đoạn và reset về giá trị `current_streak = 1`.

### 2.2. Cơ chế Giải cứu Chuỗi (Streak Recovery Challenge)
Nếu không may chuỗi ngày bị đứt, học viên có thể kích hoạt tính năng **"Thử thách Giải cứu Chuỗi"** thông qua bài kiểm tra phát âm đặc biệt (đọc chuẩn xác 5 từ vựng khó với điểm trung bình $\ge 85$). Khi vượt qua, chuỗi ngày học trước đó sẽ được khôi phục nguyên vẹn (`recoverBrokenStreak`).

### 2.3. Cấp độ kỷ luật (Discipline Rank) & Mục tiêu hàng ngày
* **Cấp độ kỷ luật:**
  * 1 - 2 ngày: 🥉 *Tập Sự (Novice Learner)*
  * 3 - 6 ngày: 🥈 *Kiên Trì (Consistent Practitioner)*
  * 7 - 13 ngày: 🥇 *Bứt Phá (Disciplined Scholar)*
  * 14 - 29 ngày: 🏆 *Bậc Thầy Kỷ Luật (Discipline Master)*
  * $\ge 30$ ngày: 👑 *Huyền Thoại Bền Bỉ (Legendary Streak)*
* **Daily Goals:** Học viên tùy chỉnh mục tiêu theo thời lượng (5p, 10p, 15p, 30p) hoặc số lượng từ (5, 10, 20 từ). Hệ thống tự động tính toán tỷ lệ phần trăm hoàn thành và đổi trạng thái hoàn thành khi vượt ngưỡng $100\%$.

---

## 📌 PHẦN 3: CHECKLIST 3 — TÍCH HỢP SPEECH RECOGNITION API & THU ÂM
* **Phụ trách:** Nguyễn Trung Kiên (2251172394)  
* **Tệp triển khai:** [`lib/services/audio_recording_manager.dart`](file:///D:/Nam_4/Mobile/TH3/lib/services/audio_recording_manager.dart), [`lib/services/speech_recognition_service.dart`](file:///D:/Nam_4/Mobile/TH3/lib/services/speech_recognition_service.dart), [`lib/widgets/waveform_visualizer.dart`](file:///D:/Nam_4/Mobile/TH3/lib/widgets/waveform_visualizer.dart)

### 3.1. Tiêu chuẩn âm thanh đầu vào (WAV 16kHz PCM)
Để mô hình AI nhận diện giọng nói và căn gióng âm vị đạt độ chính xác tối ưu, module `AudioRecordingManager` chuẩn hóa luồng âm thanh theo các thông số kỹ thuật tiêu chuẩn phòng lab:
* **Tần số lấy mẫu (Sample Rate):** 16.000 Hz (16kHz).
* **Số kênh âm thanh (Channels):** 1 kênh (Mono).
* **Độ sâu bit (Bit Depth):** 16-bit Linear PCM.
* **Tốc độ truyền dữ liệu (Bitrate):** $16.000 \times 1 \times 16 = 256.000\text{ bps}$ ($32\text{ KB/s}$).
* **Công thức kích thước tệp WAV có Header 44-byte:**
  $$\text{File Size} = 44 + (\text{Duration in seconds} \times 32.000)\text{ bytes}$$

### 3.2. Thuật toán lọc nhiễu môi trường Noise Gate
Bộ lọc Noise Gate loại bỏ các tạp âm tĩnh nền (tiếng quạt, tiếng đường phố, tiếng rì rầm quán cafe):

```dart
double applyNoiseGate(double rawAmplitude, {double threshold = 0.08}) {
  if (rawAmplitude < threshold) {
    return 0.0; // Triệt tiêu hoàn toàn tạp âm dưới ngưỡng
  }
  // Chuẩn hóa và làm mịn biên độ hợp lệ
  return ((rawAmplitude - threshold) / (1.0 - threshold)).clamp(0.0, 1.0);
}
```

### 3.3. Hiệu ứng Sóng âm thời gian thực & Bộ điều khiển Web MediaRecorder
* **Giao diện sóng âm [`WaveformVisualizerWidget`](file:///D:/Nam_4/Mobile/TH3/lib/widgets/waveform_visualizer.dart):** Nhận luồng dữ liệu biên độ âm thanh thời gian thực (chu kỳ 60ms ~ 16 FPS), hiển thị 24 cột sóng dao động mượt mà với hiệu ứng dải màu Gradient (Indigo sang Tím).
* **Bộ phát âm mẫu Text-to-Speech (TTS):** Tích hợp Web Speech Synthesis API (`window.speechSynthesis`) cho phép phát âm thanh từ mẫu của người bản xứ với 2 chất giọng: **US (Anh - Mỹ)** và **UK (Anh - Anh)**.
* **Bộ thu và phát lại giọng học viên:** Sử dụng `MediaRecorder` với luồng dữ liệu liên tục (`timeslice: 200ms`), tạo tệp Blob âm thanh thực tế và phát lại trực tiếp qua loa thiết bị khi học viên bấm nghe lại (▶️).

---

## 📌 PHẦN 4: CHECKLIST 4 — MÔ HÌNH AI SO SÁNH ÂM VỊ & CÔNG THỨC CHẤM ĐIỂM
* **Phụ trách:** Trần Anh Tuấn (2351170629)  
* **Tệp triển khai:** [`lib/services/phoneme_comparison_engine.dart`](file:///D:/Nam_4/Mobile/TH3/lib/services/phoneme_comparison_engine.dart), [`lib/services/pronunciation_scoring_service.dart`](file:///D:/Nam_4/Mobile/TH3/lib/services/pronunciation_scoring_service.dart)

### 4.1. Bộ chuyển đổi Ký tự sang Ngữ âm quốc tế (G2P Engine)
Module `PhonemeComparisonEngine` chuyển đổi từ vựng tiếng Anh chuẩn sang chuỗi âm vị ngữ âm quốc tế IPA (dựa trên bảng ký âm 44 âm vị quốc tế):
* `cat` $\rightarrow$ `['k', 'æ', 't']`
* `cats` $\rightarrow$ `['k', 'æ', 't', 's']`
* `think` $\rightarrow$ `['θ', 'ɪ', 'ŋ', 'k']`
* `water` $\rightarrow$ `['w', 'ɔː', 't', 'ər']`

### 4.2. Thuật toán Căn gióng âm vị Levenshtein (Phonetic Alignment)
Khoảng cách chỉnh sửa ngữ âm tính toán số phép biến đổi nhỏ nhất (Thay thế, Thêm, Xóa/Nuốt âm) giữa chuỗi âm vị mục tiêu $T$ và chuỗi âm vị thực tế người dùng phát âm $A$:

$$D(i, j) = \min \begin{cases}
D(i-1, j) + \text{Cost}_{del} & \text{(Nuốt âm / Bỏ sót)} \\
D(i, j-1) + \text{Cost}_{ins} & \text{(Thêm âm lạ)} \\
D(i-1, j-1) + \text{Cost}_{sub}(T_i, A_j) & \text{(Phát âm sai âm vị)}
\end{cases}$$

Ma trận khoảng cách đặc biệt gán trọng số phạt nặng cho lỗi nuốt phụ âm cuối (ending sounds như `/s/`, `/t/`, `/d/`, `/z/`) — đây là lỗi kinh điển nhất của học viên Việt Nam khi nói tiếng Anh.

### 4.3. Công thức chấm điểm phát âm toàn diện
Hệ thống chấm điểm theo thang điểm chuẩn 100 dựa trên 3 trụ cột:

$$\text{Accuracy Score} = \left( 1.0 - \frac{\text{Phonetic Levenshtein Distance}}{\max(|T|, |A|)} \right) \times 100$$

$$\text{Fluency Score} = \left( 100 - (\text{Số khoảng lặng ngập ngừng} \times 15) \right) \times \left( \frac{\text{WPM}}{120} \right)$$

$$\text{Completeness Score} = \left( \frac{\text{Số âm vị phát âm đủ}}{\text{Tổng số âm vị mục tiêu}} \right) \times 100$$

Điểm tổng hợp cuối cùng (Weighted Composite Score):

$$\mathbf{Total\ Score} = 0.50 \times \text{Accuracy} + 0.25 \times \text{Fluency} + 0.25 \times \text{Completeness}$$

---

## 📌 PHẦN 5: CHECKLIST 5 — XÂY DỰNG MODULE PHẢN HỒI TRỰC QUAN
* **Phụ trách:** Trần Anh Tuấn (2351170629)  
* **Tệp triển khai:** [`lib/widgets/score_card_widget.dart`](file:///D:/Nam_4/Mobile/TH3/lib/widgets/score_card_widget.dart), [`lib/widgets/phoneme_feedback_widget.dart`](file:///D:/Nam_4/Mobile/TH3/lib/widgets/phoneme_feedback_widget.dart), [`lib/services/targeted_lesson_recommender.dart`](file:///D:/Nam_4/Mobile/TH3/lib/services/targeted_lesson_recommender.dart)

### 5.1. Thẻ điểm số trực quan (ScoreCardWidget)
* Điểm tổng thể được hiển thị dạng vòng tròn tiến độ nổi bật với thang màu trực quan:
  * $\ge 85$ điểm: Xanh lục (Xuất sắc — Chuẩn người bản xứ).
  * 70 – 84 điểm: Xanh dương (Tốt — Phát âm dễ hiểu).
  * 50 – 69 điểm: Cam (Cần cải thiện — Có lỗi âm vị).
  * $< 50$ điểm: Đỏ (Chưa đạt — Phát âm sai nhiều âm).
* Hiển thị chi tiết 3 thanh tiến độ thành phần: *Độ chính xác (Accuracy)*, *Độ trôi chảy (Fluency)*, *Độ đầy đủ (Completeness)*.

### 5.2. Widget Highlight tô màu trực quan âm vị (PhonemeFeedbackWidget)
Từng ký tự âm vị trong từ vựng được bóc tách và tô màu riêng biệt theo bảng mã màu:
* 🟢 **Xanh lá cây:** Phát âm chính xác hoàn toàn so với phiên âm chuẩn.
* 🔴 **Màu đỏ:** Phát âm sai âm vị (kèm hiển thị âm vị sai người dùng đã nói để nhận biết).
* 🟠 **Màu cam:** Nuốt âm / Bỏ sót âm (đặc biệt là âm gió `/s/` và âm đuôi `/t/`).
* Có phần **Hướng dẫn khẩu hình miệng (Mouth Anatomy Tips)** hướng dẫn đặt lưỡi và răng chuẩn để sửa lỗi (Ví dụ: đối với âm `/θ/`: *"Đặt đầu lưỡi giữa hai hàm răng trên và dưới, thổi luồng hơi nhẹ mà không rung dây thanh"*).

### 5.3. Thuật toán Gợi ý Bài tập cải thiện cá nhân hóa (TargetedLessonRecommender)
Dựa trên lịch sử các âm vị bị điểm kém trong bảng `phoneme_results`, thuật toán tự động tổng hợp danh sách các âm vị yếu nhất của học viên và đề xuất gói bài tập gồm:
1. Bài luyện âm đơn cô lập (Drill exercises).
2. Các cặp từ tối thiểu tương phản (Minimal pairs: ví dụ phân biệt `/i:/` vs `/ɪ/` trong `sheet` vs `shit`).
3. Mẫu câu giao tiếp thực tế chứa nhiều âm vị học viên thường nói sai.

---

## 📌 PHẦN 6: CHECKLIST 6 — HỆ THỐNG THÔNG BÁO NHẮC NHỞ & UI TIẾN ĐỘ
* **Phụ trách:** Lê Anh Tuấn (2151060296)  
* **Tệp triển khai:** [`lib/services/daily_notification_service.dart`](file:///D:/Nam_4/Mobile/TH3/lib/services/daily_notification_service.dart), [`lib/views/progress_dashboard_view.dart`](file:///D:/Nam_4/Mobile/TH3/lib/views/progress_dashboard_view.dart), [`lib/widgets/streak_badge_widget.dart`](file:///D:/Nam_4/Mobile/TH3/lib/widgets/streak_badge_widget.dart)

### 6.1. Dịch vụ Thông báo cục bộ hàng ngày (Daily Notification Service)
* **Lên lịch định kỳ:** Sử dụng `flutter_local_notifications` lên lịch thông báo nhắc học đúng vào khung giờ người dùng tùy chọn (mặc định 20:00).
* **Cảnh báo khẩn cấp nguy cơ mất chuỗi (Smart Emergency Warning):** Vào lúc 20:00 hằng ngày, hệ thống quét trạng thái `checkStreakRiskStatus`. Nếu học viên chưa học bài trong ngày và có chuỗi ngày $\ge 3$, thông báo khẩn cấp với thông điệp: *"🔥 Chuỗi X ngày của bạn sắp tan biến vào 24:00 đêm nay! Hãy dành 5 phút luyện nói ngay!"* sẽ được gửi đến thiết bị.
* **Thông báo chúc mừng kỷ lục:** Tự động gửi thông báo vinh danh khi chuỗi ngày đạt mốc quan trọng (3, 7, 14, 30 ngày).

### 6.2. Giao diện Bảng điều khiển tiến độ học tập (ProgressDashboardView)
* **Thẻ hồ sơ học viên (Header Profile):** Hiển thị thông tin người học, ID sinh viên, và Cúp cấp độ kỷ luật.
* **Huy hiệu Chuỗi ngày ([`StreakBadgeWidget`](file:///D:/Nam_4/Mobile/TH3/lib/widgets/streak_badge_widget.dart)):** Hiển thị biểu tượng ngọn lửa rực sáng kèm số ngày học liên tục và số lượng khiên đóng băng Freeze Streak khả dụng.
* **Ma trận điểm danh học tập (Study Heatmap):** Hiển thị trực quan 7 ngày trong tuần, tích xanh các ngày đã hoàn thành và cảnh báo ngày hôm nay chưa hoàn thành.
* **Biểu đồ mục tiêu ngày (Daily Goal Progress):** Vòng tròn tiến độ trực quan thể hiện số phút học và số từ đã phát âm trong ngày.

---

## 📌 PHẦN 7: CHECKLIST 7 — KIỂM THỬ ĐA NGƯỜI DÙNG & ĐA GIỌNG NÓI (MULTI-ACCENT TESTING)
* **Phụ trách:** Nguyễn Văn Huỳnh (2351170599 — Chủ trì) cùng cả nhóm  
* **Tệp triển khai:** [`test/audio_recording_speech_test.dart`](file:///D:/Nam_4/Mobile/TH3/test/audio_recording_speech_test.dart), [`test/phoneme_engine_test.dart`](file:///D:/Nam_4/Mobile/TH3/test/phoneme_engine_test.dart), [`test/streak_service_test.dart`](file:///D:/Nam_4/Mobile/TH3/test/streak_service_test.dart), [`KICH_BAN_KIEM_THU_TH3.md`](file:///D:/Nam_4/Mobile/TH3/KICH_BAN_KIEM_THU_TH3.md)

### 7.1. Ma trận Kiểm thử Đa chất giọng (Multi-Accent Test Matrix)

Hệ thống được kiểm thử thực tế trên 5 nhóm chất giọng điển hình:

| Mã Test | Nhóm Đối Tượng & Chất Giọng | Mẫu Kiểm Thử | Hành Vi Mong Muốn | Kết Quả Thực Tế | Trạng Thái |
|:---:|:---|:---|:---|:---|:---:|
| **TC-MULTI-01** | Giọng Việt Nam phát âm chuẩn | Từ `"cat"` (`/kæt/`) | AI nhận diện chuẩn xác 100%, điểm số $\ge 90$ | Nhận diện `"cat"`, Accuracy: 100, Tổng điểm: 96.5 | ✅ PASSED |
| **TC-MULTI-02** | Giọng Việt Nam nuốt âm đuôi | Từ `"cats"` đọc thành `"cat"` | Phát hiện thiếu âm `/s/`, phạt điểm Completeness, gợi ý khẩu hình | Nhận diện `"cat"`, báo thiếu âm `/s/`, điểm: 72.8 | ✅ PASSED |
| **TC-MULTI-03** | Giọng bản xứ Anh - Mỹ (US Accent) | Từ `"think"` (`/θɪŋk/`) | Nhận diện đúng phụ âm răng môi `/θ/`, điểm tối đa | Nhận diện `"think"`, Accuracy: 100, Fluency: 98 | ✅ PASSED |
| **TC-STT-04** | Giọng nói trong môi trường ồn | Âm lượng nền 35dB (Cafe) | Thuật toán Noise Gate lọc sạch tạp âm, độ tin cậy $\ge 85\%$ | Lọc sạch nhiễu nền, độ tin cậy: 87.2% | ✅ PASSED |
| **TC-STT-05** | Phát âm mẫu bản xứ US vs UK | Từ `"water"` | Phát đúng chuẩn uốn lưỡi US (`/ˈwɔːtər/`) và UK (`/ˈwɔːtə/`) | Web Speech TTS phát chuẩn 2 giọng US và UK | ✅ PASSED |

### 7.2. Kết quả Chạy Toàn Bộ Kiểm Thử Tự Động (`flutter test`)
```bash
$ flutter test
Flutter assets will be downloaded from https://storage.flutter-io.cn.
00:00 +0: loading test/audio_recording_speech_test.dart
...
00:02 +36: All tests passed!
```
* **Tổng số test cases:** 36 bài kiểm thử.
* **Tỷ lệ vượt qua (Pass Rate):** **36/36 (100%)**.
* **Thời gian thực thi:** 2.8 giây.

### 7.3. Kết quả Phân tích Tĩnh (`dart analyze`)
```bash
$ dart analyze
Analyzing TH3...
No issues found!
```
* Mã nguồn tuân thủ 100% chuẩn quy ước code Dart/Flutter, 0 lỗi biên dịch, 0 cảnh báo linter.

---

## 🚀 HƯỚNG DẪN KHỞI CHẠY ỨNG DỤNG VÀ THỰC NGHIỆM

### 1. Khởi chạy Ứng dụng trên Trình duyệt Web (Chrome / Edge)
```bash
flutter run -d chrome
```
*Hoặc truy cập trực tiếp qua cổng máy chủ cục bộ độc lập:* **[http://localhost:8080/](http://localhost:8080/)**

### 2. Khởi chạy Ứng dụng trên Máy ảo Android (Pixel 34)
```bash
flutter emulators --launch Pixel_34
flutter run -d android
```

### 3. Thực hiện Kiểm thử Toàn bộ Hệ thống
```bash
flutter test
```

---

## 🏆 KẾT LUẬN & ĐÁNH GIÁ CHUNG
Dự án **SpeakUp AI (TH3 - Nhóm 16)** đã hiện thực hóa đầy đủ và toàn diện 7 mục Checklist theo yêu cầu của Bộ môn Công nghệ Phần mềm — Khoa CNTT — Trường Đại học Thủy Lợi:
1. CSDL quan hệ chuẩn hóa 3NF kết hợp cơ chế Offline-First lưu trữ an toàn hồ sơ học tập.
2. Logic Streak thông minh với khiên bảo vệ Freeze Streak và bài test cứu chuỗi độc đáo.
3. Module thu âm chuẩn hóa 16kHz WAV với lọc nhiễu Noise Gate và Web MediaRecorder phát lại giọng thực tế.
4. Thuật toán so sánh âm vị Levenshtein với bộ trọng số phạt đặc biệt cho học viên Việt Nam.
5. Thẻ điểm số và hệ thống tô màu âm vị trực quan kèm hướng dẫn khẩu hình chi tiết.
6. Hệ thống thông báo nhắc nhở thông minh cảnh báo đứt chuỗi lúc 20:00.
7. Bộ kiểm thử đa chất giọng với 36/36 test cases đạt chuẩn 100%.
