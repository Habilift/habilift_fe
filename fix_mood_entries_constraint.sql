-- ============================================================================
-- Fix Mood Entries Unique Constraint
-- ============================================================================
-- This script removes the unique constraint on (user_id, entry_date) 
-- to allow multiple mood entries per day for calculating daily means.
-- ============================================================================

BEGIN;

-- Drop the unique constraint on mood_entries
ALTER TABLE public.mood_entries 
DROP CONSTRAINT IF EXISTS mood_entries_user_id_entry_date_key;

-- Verify the constraint is removed
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 
    FROM information_schema.table_constraints 
    WHERE constraint_name = 'mood_entries_user_id_entry_date_key'
    AND table_name = 'mood_entries'
  ) THEN
    RAISE EXCEPTION 'Constraint still exists!';
  ELSE
    RAISE NOTICE 'Constraint successfully removed. Multiple mood entries per day are now allowed.';
  END IF;
END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- After running this script, users can now:
-- 1. Record multiple mood entries per day
-- 2. Daily mean will be calculated from all entries for that day
-- 3. Weekly mood trend will show accurate averages
-- ============================================================================
