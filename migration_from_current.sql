-- ============================================================================
-- HabiLift Incremental Migration Script
-- ============================================================================
-- Safely migrates from current basic schema to optimized schema
-- Preserves all existing data
-- Safe to run on production
-- ============================================================================

BEGIN;

-- ============================================================================
-- STEP 1: CREATE NEW ENUM TYPES
-- ============================================================================

-- Create new enum types (only if they don't exist)
DO $$ BEGIN
  CREATE TYPE user_type AS ENUM ('individual', 'parent', 'educator', 'specialist');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE assessment_type AS ENUM ('mental_health', 'wellness', 'anxiety', 'depression', 'stress', 'custom');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE notification_type AS ENUM ('session_reminder', 'assessment', 'system', 'forum', 'achievement');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE resource_category AS ENUM ('article', 'video', 'guide', 'podcast', 'tool', 'exercise');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE specialist_status AS ENUM ('active', 'inactive', 'on_leave');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Extend existing session_status enum
DO $$ BEGIN
  ALTER TYPE session_status ADD VALUE IF NOT EXISTS 'in_progress';
  ALTER TYPE session_status ADD VALUE IF NOT EXISTS 'no_show';
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;


-- ============================================================================
-- STEP 2: EXTEND EXISTING PROFILES TABLE
-- ============================================================================

-- Add new columns to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS gender TEXT CHECK (gender IN ('male', 'female', 'non-binary', 'prefer_not_to_say'));
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS age_range TEXT CHECK (age_range IN ('13-17', '18-24', '25-34', '35-44', '45-54', '55-64', '65+'));
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS date_of_birth DATE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS country TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS city TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS timezone TEXT DEFAULT 'UTC';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS preferred_language TEXT DEFAULT 'English';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS user_type user_type DEFAULT 'individual';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS goals TEXT[];
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS current_mood TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS streak_days INTEGER DEFAULT 0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_profile_public BOOLEAN DEFAULT false;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS allow_anonymous_forum BOOLEAN DEFAULT true;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{"email": true, "push": true, "sms": false}'::jsonb;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_active_at TIMESTAMPTZ DEFAULT now();

-- Add indexes for profiles
CREATE INDEX IF NOT EXISTS idx_profiles_user_type ON public.profiles(user_type);
CREATE INDEX IF NOT EXISTS idx_profiles_country ON public.profiles(country);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_last_active ON public.profiles(last_active_at DESC);

-- Add new RLS policy for public profiles
DROP POLICY IF EXISTS "Users can view public profiles" ON public.profiles;
CREATE POLICY "Users can view public profiles"
  ON public.profiles FOR SELECT
  USING (is_profile_public = true);


-- ============================================================================
-- STEP 3: EXTEND EXISTING SPECIALISTS TABLE
-- ============================================================================

ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL;
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS email TEXT UNIQUE;
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS specialties TEXT[];
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS qualifications TEXT[];
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS license_number TEXT;
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS total_reviews INTEGER DEFAULT 0;
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS total_sessions INTEGER DEFAULT 0;
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS status specialist_status DEFAULT 'active';
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS availability JSONB;
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS hourly_rate NUMERIC(10, 2);
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'USD';
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS country TEXT;
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS city TEXT;
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS timezone TEXT DEFAULT 'UTC';
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS languages TEXT[] DEFAULT ARRAY['English'];
ALTER TABLE public.specialists ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

-- Add indexes for specialists
CREATE INDEX IF NOT EXISTS idx_specialists_specialty ON public.specialists(specialty);
CREATE INDEX IF NOT EXISTS idx_specialists_status ON public.specialists(status);
CREATE INDEX IF NOT EXISTS idx_specialists_rating ON public.specialists(average_rating DESC);
CREATE INDEX IF NOT EXISTS idx_specialists_user_id ON public.specialists(user_id);

-- Update RLS policies for specialists
DROP POLICY IF EXISTS "Authenticated users can view specialists" ON public.specialists;
DROP POLICY IF EXISTS "Anyone can view active specialists" ON public.specialists;
CREATE POLICY "Anyone can view active specialists"
  ON public.specialists FOR SELECT
  USING (status = 'active');

DROP POLICY IF EXISTS "Specialists can update their own profile" ON public.specialists;
CREATE POLICY "Specialists can update their own profile"
  ON public.specialists FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());


-- ============================================================================
-- STEP 4: EXTEND EXISTING SESSIONS TABLE
-- ============================================================================

ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS session_type TEXT;
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS meeting_id TEXT;
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS meeting_password TEXT;
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS topic TEXT;
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS user_notes TEXT;
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS rating NUMERIC(2, 1) CHECK (rating >= 0 AND rating <= 5);
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS feedback TEXT;
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS specialist_feedback TEXT;
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS amount NUMERIC(10, 2);
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'USD';
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS payment_status TEXT CHECK (payment_status IN ('pending', 'paid', 'refunded', 'failed'));
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ;
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;

-- Add indexes for sessions
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON public.sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_specialist_id ON public.sessions(specialist_id);
CREATE INDEX IF NOT EXISTS idx_sessions_status ON public.sessions(status);
CREATE INDEX IF NOT EXISTS idx_sessions_time ON public.sessions(session_time DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_user_time ON public.sessions(user_id, session_time DESC);

-- Add RLS policy for specialists to view their sessions
DROP POLICY IF EXISTS "Specialists can view their sessions" ON public.sessions;
CREATE POLICY "Specialists can view their sessions"
  ON public.sessions FOR SELECT
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.specialists WHERE id = specialist_id
    )
  );


-- ============================================================================
-- STEP 5: EXTEND EXISTING MOOD_ENTRIES TABLE
-- ============================================================================

ALTER TABLE public.mood_entries ADD COLUMN IF NOT EXISTS mood_label TEXT;
ALTER TABLE public.mood_entries ADD COLUMN IF NOT EXISTS activities TEXT[];
ALTER TABLE public.mood_entries ADD COLUMN IF NOT EXISTS triggers TEXT[];
ALTER TABLE public.mood_entries ADD COLUMN IF NOT EXISTS energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 10);
ALTER TABLE public.mood_entries ADD COLUMN IF NOT EXISTS stress_level INTEGER CHECK (stress_level >= 1 AND stress_level <= 10);
ALTER TABLE public.mood_entries ADD COLUMN IF NOT EXISTS sleep_hours NUMERIC(3, 1);

-- Add indexes for mood_entries
CREATE INDEX IF NOT EXISTS idx_mood_entries_user_id ON public.mood_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_mood_entries_date ON public.mood_entries(entry_date DESC);
CREATE INDEX IF NOT EXISTS idx_mood_entries_user_date ON public.mood_entries(user_id, entry_date DESC);


-- ============================================================================
-- STEP 6: CREATE NEW ASSESSMENTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.assessments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  assessment_type assessment_type NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  score NUMERIC(5, 2),
  max_score NUMERIC(5, 2),
  percentage NUMERIC(5, 2),
  severity_level TEXT,
  results JSONB,
  recommendations TEXT[],
  completed_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_assessments_user_id ON public.assessments(user_id);
CREATE INDEX IF NOT EXISTS idx_assessments_type ON public.assessments(assessment_type);
CREATE INDEX IF NOT EXISTS idx_assessments_completed ON public.assessments(completed_at DESC);

ALTER TABLE public.assessments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage their own assessments" ON public.assessments;
CREATE POLICY "Users can manage their own assessments"
  ON public.assessments FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);


-- ============================================================================
-- STEP 7: CREATE NEW RESOURCES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  content TEXT,
  category resource_category NOT NULL,
  thumbnail_url TEXT,
  content_url TEXT,
  video_url TEXT,
  duration_minutes INTEGER,
  tags TEXT[],
  target_audience TEXT[],
  difficulty_level TEXT CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
  view_count INTEGER DEFAULT 0,
  like_count INTEGER DEFAULT 0,
  bookmark_count INTEGER DEFAULT 0,
  author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  author_name TEXT,
  is_published BOOLEAN DEFAULT false,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_resources_category ON public.resources(category);
CREATE INDEX IF NOT EXISTS idx_resources_published ON public.resources(is_published, published_at DESC);
CREATE INDEX IF NOT EXISTS idx_resources_tags ON public.resources USING GIN(tags);

ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view published resources" ON public.resources;
CREATE POLICY "Anyone can view published resources"
  ON public.resources FOR SELECT
  USING (is_published = true);

DROP POLICY IF EXISTS "Authors can manage their own resources" ON public.resources;
CREATE POLICY "Authors can manage their own resources"
  ON public.resources FOR ALL
  USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);


-- ============================================================================
-- STEP 8: CREATE NEW RESOURCE_BOOKMARKS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.resource_bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  resource_id UUID NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, resource_id)
);

CREATE INDEX IF NOT EXISTS idx_resource_bookmarks_user ON public.resource_bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_resource_bookmarks_resource ON public.resource_bookmarks(resource_id);

ALTER TABLE public.resource_bookmarks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage their own bookmarks" ON public.resource_bookmarks;
CREATE POLICY "Users can manage their own bookmarks"
  ON public.resource_bookmarks FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);


-- ============================================================================
-- STEP 9: CREATE NEW NOTIFICATIONS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type notification_type NOT NULL,
  action_url TEXT,
  action_data JSONB,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON public.notifications(user_id, is_read, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON public.notifications(created_at DESC);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own notifications" ON public.notifications;
CREATE POLICY "Users can view their own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own notifications" ON public.notifications;
CREATE POLICY "Users can update their own notifications"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);


-- ============================================================================
-- STEP 10: CREATE NEW FORUM_POSTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.forum_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT,
  tags TEXT[],
  is_anonymous BOOLEAN DEFAULT false,
  view_count INTEGER DEFAULT 0,
  like_count INTEGER DEFAULT 0,
  comment_count INTEGER DEFAULT 0,
  is_pinned BOOLEAN DEFAULT false,
  is_locked BOOLEAN DEFAULT false,
  is_deleted BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  last_activity_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_forum_posts_user_id ON public.forum_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_forum_posts_category ON public.forum_posts(category);
CREATE INDEX IF NOT EXISTS idx_forum_posts_activity ON public.forum_posts(last_activity_at DESC);

ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view non-deleted posts" ON public.forum_posts;
CREATE POLICY "Anyone can view non-deleted posts"
  ON public.forum_posts FOR SELECT
  USING (is_deleted = false);

DROP POLICY IF EXISTS "Users can create posts" ON public.forum_posts;
CREATE POLICY "Users can create posts"
  ON public.forum_posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own posts" ON public.forum_posts;
CREATE POLICY "Users can update their own posts"
  ON public.forum_posts FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own posts" ON public.forum_posts;
CREATE POLICY "Users can delete their own posts"
  ON public.forum_posts FOR DELETE
  USING (auth.uid() = user_id);


-- ============================================================================
-- STEP 11: CREATE NEW FORUM_COMMENTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.forum_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.forum_posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  parent_comment_id UUID REFERENCES public.forum_comments(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_anonymous BOOLEAN DEFAULT false,
  like_count INTEGER DEFAULT 0,
  is_deleted BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_forum_comments_post_id ON public.forum_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_forum_comments_user_id ON public.forum_comments(user_id);
CREATE INDEX IF NOT EXISTS idx_forum_comments_parent ON public.forum_comments(parent_comment_id);

ALTER TABLE public.forum_comments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view non-deleted comments" ON public.forum_comments;
CREATE POLICY "Anyone can view non-deleted comments"
  ON public.forum_comments FOR SELECT
  USING (is_deleted = false);

DROP POLICY IF EXISTS "Users can create comments" ON public.forum_comments;
CREATE POLICY "Users can create comments"
  ON public.forum_comments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own comments" ON public.forum_comments;
CREATE POLICY "Users can update their own comments"
  ON public.forum_comments FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own comments" ON public.forum_comments;
CREATE POLICY "Users can delete their own comments"
  ON public.forum_comments FOR DELETE
  USING (auth.uid() = user_id);


-- ============================================================================
-- STEP 12: CREATE NEW EMERGENCY_CONTACTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.emergency_contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  description TEXT,
  country TEXT,
  region TEXT,
  contact_type TEXT CHECK (contact_type IN ('hotline', 'crisis_center', 'hospital', 'support_group')),
  is_24_7 BOOLEAN DEFAULT false,
  operating_hours TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_emergency_contacts_country ON public.emergency_contacts(country);
CREATE INDEX IF NOT EXISTS idx_emergency_contacts_type ON public.emergency_contacts(contact_type);

ALTER TABLE public.emergency_contacts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view active emergency contacts" ON public.emergency_contacts;
CREATE POLICY "Anyone can view active emergency contacts"
  ON public.emergency_contacts FOR SELECT
  USING (is_active = true);


-- ============================================================================
-- STEP 13: CREATE NEW ACHIEVEMENTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  icon_url TEXT,
  requirement_type TEXT,
  requirement_count INTEGER,
  points INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view achievements" ON public.achievements;
CREATE POLICY "Anyone can view achievements"
  ON public.achievements FOR SELECT
  USING (true);


-- ============================================================================
-- STEP 14: CREATE NEW USER_ACHIEVEMENTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  achievement_id UUID NOT NULL REFERENCES public.achievements(id) ON DELETE CASCADE,
  earned_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, achievement_id)
);

CREATE INDEX IF NOT EXISTS idx_user_achievements_user ON public.user_achievements(user_id);

ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own achievements" ON public.user_achievements;
CREATE POLICY "Users can view their own achievements"
  ON public.user_achievements FOR SELECT
  USING (auth.uid() = user_id);


-- ============================================================================
-- STEP 15: CREATE TRIGGERS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_specialists_updated_at ON public.specialists;
CREATE TRIGGER update_specialists_updated_at BEFORE UPDATE ON public.specialists
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_sessions_updated_at ON public.sessions;
CREATE TRIGGER update_sessions_updated_at BEFORE UPDATE ON public.sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_resources_updated_at ON public.resources;
CREATE TRIGGER update_resources_updated_at BEFORE UPDATE ON public.resources
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_forum_posts_updated_at ON public.forum_posts;
CREATE TRIGGER update_forum_posts_updated_at BEFORE UPDATE ON public.forum_posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_forum_comments_updated_at ON public.forum_comments;
CREATE TRIGGER update_forum_comments_updated_at BEFORE UPDATE ON public.forum_comments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update forum post comment count
CREATE OR REPLACE FUNCTION update_post_comment_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.forum_posts
    SET comment_count = comment_count + 1,
        last_activity_at = now()
    WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.forum_posts
    SET comment_count = GREATEST(0, comment_count - 1)
    WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_forum_post_comment_count ON public.forum_comments;
CREATE TRIGGER update_forum_post_comment_count
  AFTER INSERT OR DELETE ON public.forum_comments
  FOR EACH ROW EXECUTE FUNCTION update_post_comment_count();

-- Function to update resource bookmark count
CREATE OR REPLACE FUNCTION update_resource_bookmark_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.resources
    SET bookmark_count = bookmark_count + 1
    WHERE id = NEW.resource_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.resources
    SET bookmark_count = GREATEST(0, bookmark_count - 1)
    WHERE id = OLD.resource_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_resource_bookmarks ON public.resource_bookmarks;
CREATE TRIGGER update_resource_bookmarks
  AFTER INSERT OR DELETE ON public.resource_bookmarks
  FOR EACH ROW EXECUTE FUNCTION update_resource_bookmark_count();


-- ============================================================================
-- STEP 16: CREATE VIEWS
-- ============================================================================

-- View for specialist statistics
CREATE OR REPLACE VIEW specialist_stats AS
SELECT
  s.id,
  s.name,
  s.specialty,
  s.average_rating,
  s.total_reviews,
  COUNT(DISTINCT sess.id) FILTER (WHERE sess.status = 'completed') as completed_sessions,
  COUNT(DISTINCT sess.id) FILTER (WHERE sess.status = 'scheduled') as upcoming_sessions
FROM public.specialists s
LEFT JOIN public.sessions sess ON s.id = sess.specialist_id
GROUP BY s.id, s.name, s.specialty, s.average_rating, s.total_reviews;

-- View for user wellness dashboard
CREATE OR REPLACE VIEW user_wellness_dashboard AS
SELECT
  p.id as user_id,
  p.name,
  p.wellness_score,
  p.streak_days,
  COUNT(DISTINCT me.id) as total_mood_entries,
  COUNT(DISTINCT a.id) as total_assessments,
  COUNT(DISTINCT s.id) as total_sessions,
  AVG(me.mood_score) as avg_mood_score
FROM public.profiles p
LEFT JOIN public.mood_entries me ON p.id = me.user_id
LEFT JOIN public.assessments a ON p.id = a.user_id
LEFT JOIN public.sessions s ON p.id = s.user_id
GROUP BY p.id, p.name, p.wellness_score, p.streak_days;


COMMIT;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- Run verification queries to confirm migration success:
--
-- 1. Check all tables exist:
--    SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;
--
-- 2. Check RLS is enabled:
--    SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';
--
-- 3. Check triggers:
--    SELECT trigger_name, event_object_table FROM information_schema.triggers WHERE trigger_schema = 'public';
--
-- ============================================================================
