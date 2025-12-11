-- ============================================================================
-- FIX: Sign-up 500 Error - NULL name constraint violation
-- ============================================================================
-- Run this in Supabase SQL Editor
-- ============================================================================

-- Option 1: Make name column nullable (RECOMMENDED)
-- This allows users to sign up without a name and set it later in profile setup
ALTER TABLE public.profiles ALTER COLUMN name DROP NOT NULL;

-- Option 2: Update the trigger to ensure name is never null
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (
    id, 
    name, 
    email,
    created_at,
    updated_at
  )
  VALUES (
    new.id,
    COALESCE(
      new.raw_user_meta_data->>'name',
      new.raw_user_meta_data->>'full_name',
      split_part(new.email, '@', 1),  -- Use email username as fallback
      'User'
    ),
    new.email,
    now(),
    now()
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Verify the changes
SELECT 
  column_name,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'profiles' 
  AND table_schema = 'public'
  AND column_name = 'name';

SELECT 'Fix applied successfully! Try signing up again.' as status;
