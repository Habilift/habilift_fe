import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithOtp(String emailOrPhone) async {
    if (emailOrPhone.contains('@')) {
      await _supabase.auth.signInWithOtp(email: emailOrPhone);
    } else {
      await _supabase.auth.signInWithOtp(phone: '+237$emailOrPhone');
    }
  }

  /// Send OTP to email for verification
  Future<void> sendEmailOTP(String email) async {
    // Use signInWithOtp with explicit OTP request
    await _supabase.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
      emailRedirectTo: null, // Disable magic link redirect
    );
  }

  Future<AuthResponse> verifyOtp(String emailOrPhone, String token) async {
    // Determine if it's email or phone
    final isEmail = emailOrPhone.contains('@');
    
    return await _supabase.auth.verifyOTP(
      // For email OTP sent via signInWithOtp, use magiclink type
      // For phone OTP, use sms type
      type: isEmail ? OtpType.magiclink : OtpType.sms,
      token: token,
      email: isEmail ? emailOrPhone : null,
      phone: isEmail ? null : '+237$emailOrPhone',
    );
  }


  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    return await _supabase.auth.signInWithOAuth(
      provider,
      redirectTo: null,
    );
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
