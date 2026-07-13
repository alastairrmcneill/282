String mapAuthErrorMessage(String? rawError) {
  if (rawError == null) return 'Something went wrong. Please try again.';

  if (rawError.contains('invalid-credential') ||
      rawError.contains('wrong-password') ||
      rawError.contains('user-not-found')) {
    return 'Incorrect email or password. Please try again.';
  }
  if (rawError.contains('email-already-in-use')) {
    return 'An account already exists with this email.';
  }
  if (rawError.contains('weak-password')) {
    return 'Password is too weak. Please choose a stronger password.';
  }
  if (rawError.contains('invalid-email')) {
    return 'Please enter a valid email address.';
  }
  if (rawError.contains('user-disabled')) {
    return 'This account has been disabled. Please contact support.';
  }

  return 'Something went wrong. Please try again.';
}
