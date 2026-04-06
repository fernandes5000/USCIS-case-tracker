// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'USCIS Case Tracker';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to track your USCIS cases';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get createAccount => 'Create account';

  @override
  String get createAccountSubtitle => 'Start tracking your USCIS cases';

  @override
  String get fullName => 'Full Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordMinLength => 'Minimum 8 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get myCases => 'My Cases';

  @override
  String hello(String name) {
    return 'Hello, $name';
  }

  @override
  String get noCasesYet => 'No cases yet';

  @override
  String get noCasesSubtitle =>
      'Add your USCIS receipt numbers\nto start tracking your cases.';

  @override
  String get addFirstCase => 'Add First Case';

  @override
  String get addCase => 'Add Case';

  @override
  String get receiptNumber => 'Receipt Number';

  @override
  String get receiptHint => 'e.g. EAC9999103403';

  @override
  String get receiptHelper => 'Found on your USCIS Notice of Action (I-797)';

  @override
  String get nicknameOptional => 'Nickname (optional)';

  @override
  String get nicknameHint => 'e.g. My Green Card, Spouse Visa';

  @override
  String get trackThisCase => 'Track This Case';

  @override
  String get caseAddedSuccess => 'Case added successfully';

  @override
  String get receiptRequired => 'Receipt number is required';

  @override
  String get receiptTooShort => 'Receipt number too short';

  @override
  String get receiptInvalidPrefix =>
      'Must start with 3 letters (e.g. IOE, EAC, WAC)';

  @override
  String get receiptInvalidSuffix => 'Digits must follow the 3-letter prefix';

  @override
  String get receiptInfoBanner =>
      'Your receipt number is on your USCIS Notice of Action (Form I-797). It starts with 3 letters followed by 10 digits.';

  @override
  String get currentStatus => 'Current Status';

  @override
  String get caseHistory => 'Case History';

  @override
  String caseHistoryCount(int count) {
    return '$count events';
  }

  @override
  String get statusUnavailable => 'Status unavailable';

  @override
  String get statusUnavailableSubtitle =>
      'Could not retrieve status from USCIS. Try refreshing.';

  @override
  String get editNickname => 'Edit Nickname';

  @override
  String get removeCase => 'Remove Case';

  @override
  String removeCaseConfirm(String receipt) {
    return 'Remove $receipt from your tracked cases? This cannot be undone.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get remove => 'Remove';

  @override
  String get refresh => 'Refresh';

  @override
  String get nickname => 'Nickname';

  @override
  String get nicknamePlaceholder => 'e.g. My Green Card';

  @override
  String get failedToUpdate => 'Failed to update';

  @override
  String get failedToRemove => 'Failed to remove';

  @override
  String get failedToAdd => 'Failed to add case. Please try again.';

  @override
  String get alreadyTracked => 'This case is already in your list.';

  @override
  String get invalidReceiptFormat => 'Invalid receipt number format.';

  @override
  String get caseNotFound => 'Case not found in USCIS system.';

  @override
  String get profile => 'Profile';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get language => 'Language';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get errorOccurred => 'An error occurred. Please try again.';

  @override
  String get connectionError =>
      'Could not connect to server. Check your connection.';

  @override
  String get sessionExpired => 'Session expired. Please sign in again.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageSpanish => 'Español';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';
}
