# Database Migration Instructions

## 🚀 Apply the Migration to Supabase

Follow these steps to upgrade your database:

### Step 1: Open Supabase Dashboard
1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Select your project: **onmewpqwqehkgwttzhwf**
3. Navigate to **SQL Editor** in the left sidebar

### Step 2: Run the Migration Script
1. Click **New Query**
2. Open the file: `migration_from_current.sql` (in your project root)
3. Copy the entire contents
4. Paste into the SQL Editor
5. Click **Run** (or press Ctrl+Enter)

### Step 3: Wait for Completion
- The migration should complete in **~30 seconds**
- You'll see "Success. No rows returned" when done

### Step 4: Verify Migration
Run this verification query in the SQL Editor:

```sql
-- Check all tables exist (should return 13 rows)
SELECT tablename FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;
```

**Expected tables:**
- achievements
- assessments
- emergency_contacts
- forum_comments
- forum_posts
- mood_entries
- notifications
- profiles
- resource_bookmarks
- resources
- sessions
- specialists
- user_achievements

### Step 5: Verify RLS Policies
```sql
-- All tables should have RLS enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';
```

All should show `rowsecurity = true`

---

## ✅ Migration Complete!

Once you've run the migration successfully, the database will be ready for the updated Flutter app.

## 🔄 Next: Update Flutter App

After migration, we need to:
1. Create Dart models for new tables
2. Update existing models with new fields
3. Create repositories for data access
4. Update UI to use new fields

---

## 🆘 Troubleshooting

**If you see errors:**
- Check you're connected to the correct project
- Ensure you have admin permissions
- Try running the script in smaller sections

**Need help?** Let me know what error message you see!
