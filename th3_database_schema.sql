-- ==============================================================================
-- BÀI TẬP THỰC HÀNH 3 (TH3) - PHÁT TRIỂN ỨNG DỤNG HỌC TIẾNG ANH THÔNG MINH
-- HỆ CƠ SỞ DỮ LIỆU LUYỆN PHÁT ÂM TIẾNG ANH AI & THEO DÕI KỶ LUẬT (SPEAKUP AI)
-- Đơn vị thực hiện: Nhóm 16 - Lớp 65KTPM - Đại học Thủy Lợi
-- Thành viên phụ trách CSDL: Nguyễn Văn Huỳnh (Nhóm trưởng - 2351170599)
-- ==============================================================================

-- 1. BẬT TIỆN ÍCH MÃ HÓA VÀ UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. BẢNG NGƯỜI DÙNG (USERS)
-- Lưu trữ thông tin cá nhân, thiết lập kỷ luật và dữ liệu chuỗi Streak
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    avatar_url TEXT,
    current_streak INT DEFAULT 0 CHECK (current_streak >= 0),
    longest_streak INT DEFAULT 0 CHECK (longest_streak >= 0),
    last_practice_date DATE,
    streak_freeze_count INT DEFAULT 2 CHECK (streak_freeze_count >= 0),
    daily_goal_minutes INT DEFAULT 15 CHECK (daily_goal_minutes > 0),
    daily_goal_words INT DEFAULT 10 CHECK (daily_goal_words > 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. BẢNG DANH MỤC BÀI HỌC (LESSONS)
-- Quản lý các nhóm bài phát âm: Nguyên âm, Phụ âm, Trọng âm, Ngữ điệu
CREATE TABLE IF NOT EXISTS lessons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    difficulty_level VARCHAR(50) DEFAULT 'Beginner' CHECK (difficulty_level IN ('Beginner', 'Intermediate', 'Advanced')),
    category VARCHAR(100) NOT NULL, -- 'Vowels', 'Consonants', 'Diphthongs', 'Intonation'
    order_index INT DEFAULT 1,
    icon_name VARCHAR(50) DEFAULT 'school',
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. BẢNG TỪ VỰNG & MẪU CÂU LUYỆN TẬP (PRACTICE_WORDS)
-- Lưu trữ từ vựng, phiên âm chuẩn IPA và danh sách âm vị thành phần
CREATE TABLE IF NOT EXISTS practice_words (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
    word_or_phrase VARCHAR(255) NOT NULL,
    standard_ipa VARCHAR(255) NOT NULL,
    phoneme_tokens JSONB NOT NULL, -- Mảng JSON chứa chuỗi âm vị: ["k", "æ", "t"]
    meaning_vi TEXT,
    audio_sample_url TEXT,
    difficulty INT DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. BẢNG PHIÊN LUYỆN TẬP (PRACTICE_SESSIONS)
-- Ghi nhận mỗi lần học viên mở ứng dụng và tiến hành buổi học
CREATE TABLE IF NOT EXISTS practice_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES lessons(id) ON DELETE SET NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INT DEFAULT 0 CHECK (duration_seconds >= 0),
    words_attempted INT DEFAULT 0 CHECK (words_attempted >= 0),
    average_score NUMERIC(5,2) DEFAULT 0.00 CHECK (average_score BETWEEN 0.00 AND 100.00),
    daily_goal_met BOOLEAN DEFAULT FALSE
);

-- 6. BẢNG LỊCH SỬ CHẤM ĐIỂM PHÁT ÂM (PRONUNCIATION_LOGS)
-- Lưu trữ chi tiết từng lượt thu âm, điểm tổng quan và các chỉ số AI
CREATE TABLE IF NOT EXISTS pronunciation_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES practice_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    practice_word_id UUID NOT NULL REFERENCES practice_words(id) ON DELETE CASCADE,
    audio_recording_path TEXT,
    recognized_text TEXT,
    recognized_ipa TEXT,
    overall_score NUMERIC(5,2) NOT NULL CHECK (overall_score BETWEEN 0.00 AND 100.00),
    accuracy_score NUMERIC(5,2) NOT NULL CHECK (accuracy_score BETWEEN 0.00 AND 100.00),
    fluency_score NUMERIC(5,2) NOT NULL CHECK (fluency_score BETWEEN 0.00 AND 100.00),
    completeness_score NUMERIC(5,2) NOT NULL CHECK (completeness_score BETWEEN 0.00 AND 100.00),
    feedback_summary TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. BẢNG CHI TIẾT ĐÁNH GIÁ ÂM VỊ (PHONEME_EVALUATIONS)
-- Đánh dấu chi tiết từng âm vị: Chuẩn, Sai, Nuốt âm để phục vụ module phản hồi
CREATE TABLE IF NOT EXISTS phoneme_evaluations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    log_id UUID NOT NULL REFERENCES pronunciation_logs(id) ON DELETE CASCADE,
    phoneme_index INT NOT NULL,
    target_phoneme VARCHAR(10) NOT NULL,
    user_phoneme VARCHAR(10),
    status VARCHAR(20) NOT NULL CHECK (status IN ('CORRECT', 'INCORRECT', 'MISSED', 'INSERTED')),
    score NUMERIC(5,2) NOT NULL CHECK (score BETWEEN 0.00 AND 100.00),
    error_type VARCHAR(100), -- 'Vowel Substitution', 'Missing Ending Consonant', 'Wrong Stress'
    guidance_tip TEXT
);

-- 8. BẢNG THEO DÕI CHUỖI KỶ LUẬT THEO NGÀY (DAILY_STREAKS)
-- Lưu trữ lịch sử điểm danh ngày học, phục vụ Calendar View và Streak Tracker
CREATE TABLE IF NOT EXISTS daily_streaks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_date DATE NOT NULL,
    minutes_learned INT DEFAULT 0 CHECK (minutes_learned >= 0),
    words_practiced INT DEFAULT 0 CHECK (words_practiced >= 0),
    is_streak_counted BOOLEAN DEFAULT FALSE,
    is_freeze_applied BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_activity_date UNIQUE (user_id, activity_date)
);

-- 9. BẢNG THIẾT LẬP THÔNG BÁO NHẮC NHỞ (USER_NOTIFICATIONS_CONFIG)
-- Quản lý lịch nhắc nhở luyện tập hàng ngày và cảnh báo nguy cơ đứt chuỗi
CREATE TABLE IF NOT EXISTS user_notifications_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    is_enabled BOOLEAN DEFAULT TRUE,
    preferred_reminder_time TIME DEFAULT '20:00:00',
    reminder_days JSONB DEFAULT '["MON","TUE","WED","THU","FRI","SAT","SUN"]',
    urgent_streak_warning BOOLEAN DEFAULT TRUE,
    fcm_token TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. BẢNG ĐỀ XUẤT BÀI TẬP CẢI THIỆN CÁ NHÂN HÓA (RECOMMENDED_EXERCISES)
-- Lưu vết các âm học viên hay phát âm sai và tạo bài học khắc phục
CREATE TABLE IF NOT EXISTS recommended_exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    target_phoneme VARCHAR(10) NOT NULL,
    error_count INT DEFAULT 1 CHECK (error_count > 0),
    suggested_lesson_id UUID REFERENCES lessons(id) ON DELETE SET NULL,
    is_resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- INDEX TỐI ƯU HÓA HIỆU NĂNG TRUY VẤN
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_practice_words_lesson ON practice_words(lesson_id);
CREATE INDEX IF NOT EXISTS idx_pronunciation_logs_user ON pronunciation_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_pronunciation_logs_session ON pronunciation_logs(session_id);
CREATE INDEX IF NOT EXISTS idx_phoneme_evaluations_log ON phoneme_evaluations(log_id);
CREATE INDEX IF NOT EXISTS idx_daily_streaks_user_date ON daily_streaks(user_id, activity_date);
CREATE INDEX IF NOT EXISTS idx_recommended_exercises_user ON recommended_exercises(user_id, is_resolved);

-- ==============================================================================
-- DỮ LIỆU KHỞI TẠO MẪU (SEED DATA MẪU PHÁT ÂM CHUẨN)
-- ==============================================================================
INSERT INTO lessons (id, title, description, difficulty_level, category, order_index, icon_name)
VALUES 
    ('11111111-1111-1111-1111-111111111111', 'Phụ âm đuôi phổ biến (/s/, /z/, /t/, /d/)', 'Khắc phục lỗi nuốt âm đuôi kinh điển của người học Việt Nam', 'Beginner', 'Consonants', 1, 'record_voice_over'),
    ('22222222-2222-2222-2222-222222222222', 'Cặp nguyên âm ngắn và dài (/i:/ vs /ɪ/)', 'Phân biệt nguyên âm sheep vs ship chuẩn xác', 'Beginner', 'Vowels', 2, 'hearing'),
    ('33333333-3333-3333-3333-333333333333', 'Âm lưỡi răng vô thanh và hữu thanh (/θ/ và /ð/)', 'Luyện tập phát âm từ Think, Thank, That, Mother', 'Intermediate', 'Consonants', 3, 'mic')
ON CONFLICT (id) DO NOTHING;

INSERT INTO practice_words (id, lesson_id, word_or_phrase, standard_ipa, phoneme_tokens, meaning_vi, difficulty)
VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'cats', 'kæts', '["k", "æ", "t", "s"]', 'những con mèo (chú ý âm đuôi /ts/)', 1),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'dogs', 'dɒɡz', '["d", "ɒ", "ɡ", "z"]', 'những con chó (chú ý âm đuôi /gz/)', 1),
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', '22222222-2222-2222-2222-222222222222', 'sheet', 'ʃiːt', '["ʃ", "iː", "t"]', 'tấm trải / tờ giấy (nguyên âm dài /i:/)', 2),
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', '22222222-2222-2222-2222-222222222222', 'shit', 'ʃɪt', '["ʃ", "ɪ", "t"]', 'từ lóng (nguyên âm ngắn /ɪ/)', 2),
    ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '33333333-3333-3333-3333-333333333333', 'think', 'θɪŋk', '["θ", "ɪ", "ŋ", "k"]', 'suy nghĩ (âm th thổi gió /θ/)', 3)
ON CONFLICT (id) DO NOTHING;
