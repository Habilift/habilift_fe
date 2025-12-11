# Supabase OTP Configuration - Detailed Guide

## Problem: Receiving Magic Link Instead of OTP Code

By default, Supabase sends a **magic link** (clickable URL) instead of a **6-digit OTP code**. Here's how to fix it:

---

## Solution 1: Configure Supabase Dashboard (Recommended)

### **Step 1: Access Email Provider Settings**

1. Go to https://supabase.com/dashboard
2. Select your project
3. Navigate to **Authentication** → **Providers**
4. Click on **Email** provider

### **Step 2: Enable OTP Mode**

Look for these settings:
- **"Confirm email"** - Set to **DISABLED** (we handle verification via OTP)
- **"Secure email change enabled"** - Set to **ENABLED** (forces OTP)
- **"Double confirm email changes"** - Set to **ENABLED**

### **Step 3: Configure Email Templates**

1. Go to **Authentication** → **Email Templates**
2. Select **"Magic Link"** template
3. Change the template to show OTP code:

**Replace this:**
```html
<a href="{{ .ConfirmationURL }}">Confirm your email</a>
```

**With this:**
```html
<h2>Your Verification Code</h2>
<h1 style="font-size: 36px; letter-spacing: 8px;">{{ .Token }}</h1>
<p>This code expires in 5 minutes.</p>
```

### **Step 4: Save and Test**

1. Click **Save**
2. Test sign-up in your app
3. Check email - should now receive OTP code

---

## Solution 2: Use Supabase CLI (Alternative)

If dashboard settings don't work, use Supabase CLI:

```bash
# Update auth config
supabase link --project-ref onmewpqwqehkgwttzhwf
supabase db push

# Or update via SQL
```

---

## Solution 3: Verify Current Settings

Run this in Supabase SQL Editor to check current config:

```sql
-- Check auth config
SELECT * FROM auth.config;

-- Check email template
SELECT * FROM auth.email_templates WHERE template_name = 'magic_link';
```

---

## Important Notes

### **OTP vs Magic Link**

- **Magic Link**: User clicks link in email → auto-login
- **OTP Code**: User enters 6-digit code in app → manual verification

### **Supabase Behavior**

By default, `signInWithOtp()` sends:
- **Web apps**: Magic link
- **Mobile apps**: OTP code (if configured)

To force OTP for web:
1. Disable email confirmation
2. Use custom email template with `{{ .Token }}`
3. Set `emailRedirectTo: null`

---

## Troubleshooting

### Still Getting Magic Link?

1. **Clear browser cache** and try again
2. **Wait 60 seconds** (rate limiting)
3. **Check Supabase logs**: Dashboard → Logs → Auth Logs
4. **Verify email template** has `{{ .Token }}` not `{{ .ConfirmationURL }}`

### OTP Not Working?

1. **Check OTP expiration**: Default is 60s, increase to 300s
2. **Verify email provider is enabled**
3. **Check spam folder**
4. **Test with different email** (Gmail, Outlook, etc.)

---

## Quick Fix: Test with Phone OTP

If email OTP is still not working, test with phone OTP instead:

```dart
// In auth_screen.dart, use phone signup
await authRepo.signInWithOtp('+237${phoneNumber}');
```

Phone OTP **always sends a code**, never a magic link.

---

## Contact Supabase Support

If none of these work:
1. Go to Supabase Dashboard
2. Click **Support** (bottom left)
3. Ask: "How to send OTP code instead of magic link for email verification?"
