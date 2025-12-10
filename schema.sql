-- ============================================================================
-- HabiLift Supabase Schema
-- ============================================================================
-- This script sets up the necessary tables, relationships, and security
-- policies for the HabiLift application.
--
-- Best Practices Included:
-- 1. UUIDs for primary keys.
-- 2. Row Level Security (RLS) enabled on all tables with policies.
-- 3. Foreign key relationships with cascading deletes where appropriate.
-- 4. Timestamps for tracking record creation and updates.
-- 5. A trigger to automatically create a user profile upon sign-up.
-- ============================================================================


-- ============================================================================
-- 1. PROFILES TABLE
-- Stores public user data. This table is linked to Supabase's internal
-- `auth.users` table.
-- ============================================================================
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  avatar_url TEXT,
  wellness_score NUMERIC(3, 1) CHECK (wellness_score >= 0 AND wellness_score <= 10),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Comments for the profiles table
COMMENT ON TABLE public.profiles IS 'Stores public-facing user profile information, linked to the authentication system.';
COMMENT ON COLUMN public.profiles.id IS 'Links to auth.users.id. Primary key.';
COMMENT ON COLUMN public.profiles.wellness_score IS 'A user''s self-reported wellness score, on a scale of 0-10.';

-- RLS Policy for Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile."
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile."
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);


-- ============================================================================
-- 2. SPECIALISTS TABLE
-- Stores information about the mental health specialists available.
-- ============================================================================
CREATE TABLE public.specialists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  specialty TEXT NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  years_of_experience INT,
  average_rating NUMERIC(2, 1) DEFAULT 0.0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Comments for the specialists table
COMMENT ON TABLE public.specialists IS 'Contains all information about the specialists available for booking.';

-- RLS Policy for Specialists
ALTER TABLE public.specialists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view specialists."
  ON public.specialists FOR SELECT
  USING (auth.role() = 'authenticated');


-- ============================================================================
-- 3. Custom ENUM type for session status
-- ============================================================================
CREATE TYPE public.session_status AS ENUM ('scheduled', 'completed', 'cancelled');


-- ============================================================================
-- 4. SESSIONS TABLE
-- Represents a booking between a user and a specialist.
-- ============================================================================
CREATE TABLE public.sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  specialist_id UUID NOT NULL REFERENCES public.specialists(id) ON DELETE CASCADE,
  session_time TIMESTAMPTZ NOT NULL,
  duration_minutes INT DEFAULT 50,
  status public.session_status DEFAULT 'scheduled',
  meeting_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Comments for the sessions table
COMMENT ON TABLE public.sessions IS 'Represents a booked session between a user and a specialist.';

-- RLS Policy for Sessions
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view and manage their own sessions."
  ON public.sessions FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);


-- ============================================================================
-- 5. MOOD_ENTRIES TABLE
-- Tracks a user's mood over time, used for charts and streaks.
-- ============================================================================
CREATE TABLE public.mood_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  mood_score NUMERIC(3, 1) NOT NULL CHECK (mood_score >= 0 AND mood_score <= 10),
  notes TEXT,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, entry_date) -- Ensures only one mood entry per user per day
);

-- Comments for the mood_entries table
COMMENT ON TABLE public.mood_entries IS 'Stores daily mood entries for a user to track wellness over time.';

-- RLS Policy for Mood Entries
ALTER TABLE public.mood_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own mood entries."
  ON public.mood_entries FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);


-- ============================================================================
-- 6. AUTOMATION: TRIGGER TO CREATE PROFILE ON SIGN-UP
-- This function runs automatically when a new user signs up in Supabase Auth.
-- It creates a corresponding row in the `public.profiles` table.
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email)
  VALUES (new.id, new.raw_user_meta_data->>'name', new.email);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ============================================================================
-- End of Schema
-- ============================================================================
