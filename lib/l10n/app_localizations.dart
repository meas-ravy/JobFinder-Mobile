import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_km.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_lo.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('km'),
    Locale('ko'),
    Locale('lo'),
    Locale('ms'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Jober'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to the app'**
  String get welcomeBack;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose the language'**
  String get chooseLanguage;

  /// No description provided for @selectLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language below. This helps us serve you better.'**
  String get selectLanguageSubtitle;

  /// No description provided for @suggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get suggestion;

  /// No description provided for @allLanguagesLabel.
  ///
  /// In en, this message translates to:
  /// **'All Languages'**
  String get allLanguagesLabel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @cambodia.
  ///
  /// In en, this message translates to:
  /// **'Cambodia'**
  String get cambodia;

  /// No description provided for @englishUS.
  ///
  /// In en, this message translates to:
  /// **'English(US)'**
  String get englishUS;

  /// No description provided for @japan.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get japan;

  /// No description provided for @china.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get china;

  /// No description provided for @malaysia.
  ///
  /// In en, this message translates to:
  /// **'Malaysia'**
  String get malaysia;

  /// No description provided for @laos.
  ///
  /// In en, this message translates to:
  /// **'Laos'**
  String get laos;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Completed!'**
  String get profileCompletedTitle;

  /// No description provided for @profileCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A complete profile increases the chances of a recruiter being more interested in recruiting you'**
  String get profileCompletedSubtitle;

  /// No description provided for @myResume.
  ///
  /// In en, this message translates to:
  /// **'My Resume'**
  String get myResume;

  /// No description provided for @switchToRecruiter.
  ///
  /// In en, this message translates to:
  /// **'Switch to Recruiter'**
  String get switchToRecruiter;

  /// No description provided for @switchRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch Role'**
  String get switchRoleTitle;

  /// No description provided for @switchRoleContent.
  ///
  /// In en, this message translates to:
  /// **'Switch to Recruiter mode? You can switch back anytime.'**
  String get switchRoleContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @switchLabel.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchLabel;

  /// No description provided for @switchingToRecruiter.
  ///
  /// In en, this message translates to:
  /// **'Switching to Recruiter...'**
  String get switchingToRecruiter;

  /// No description provided for @failedToSwitchRole.
  ///
  /// In en, this message translates to:
  /// **'Failed to switch role'**
  String get failedToSwitchRole;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfServices.
  ///
  /// In en, this message translates to:
  /// **'Terms of Services'**
  String get termsOfServices;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutUs;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmContent;

  /// No description provided for @myDocuments.
  ///
  /// In en, this message translates to:
  /// **'My Documents'**
  String get myDocuments;

  /// No description provided for @newResume.
  ///
  /// In en, this message translates to:
  /// **'New resume'**
  String get newResume;

  /// No description provided for @coverLetter.
  ///
  /// In en, this message translates to:
  /// **'Cover letter'**
  String get coverLetter;

  /// No description provided for @featureSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'We will add this feature soon, stay tuned!'**
  String get featureSoonMessage;

  /// No description provided for @myResumes.
  ///
  /// In en, this message translates to:
  /// **'My Resumes'**
  String get myResumes;

  /// No description provided for @noResumesYet.
  ///
  /// In en, this message translates to:
  /// **'No resumes yet'**
  String get noResumesYet;

  /// No description provided for @createFirstResume.
  ///
  /// In en, this message translates to:
  /// **'Create your first resume to get started'**
  String get createFirstResume;

  /// No description provided for @deleteCvTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete CV'**
  String get deleteCvTitle;

  /// No description provided for @deleteCvConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this CV?'**
  String get deleteCvConfirm;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLabel(Object error);

  /// No description provided for @chooseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Choose Template'**
  String get chooseTemplate;

  /// No description provided for @searchTemplateHint.
  ///
  /// In en, this message translates to:
  /// **'Search your template'**
  String get searchTemplateHint;

  /// No description provided for @allTab.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTab;

  /// No description provided for @simpleTab.
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get simpleTab;

  /// No description provided for @professionalTab.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get professionalTab;

  /// No description provided for @minimalistTab.
  ///
  /// In en, this message translates to:
  /// **'Minimalist'**
  String get minimalistTab;

  /// No description provided for @modernTab.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get modernTab;

  /// No description provided for @noTemplatesFound.
  ///
  /// In en, this message translates to:
  /// **'No templates found'**
  String get noTemplatesFound;

  /// No description provided for @pdfLanguageWarning.
  ///
  /// In en, this message translates to:
  /// **'Note: PDF templates currently only support English characters. Other languages (like Khmer) may not display correctly.'**
  String get pdfLanguageWarning;

  /// No description provided for @createCvTitle.
  ///
  /// In en, this message translates to:
  /// **'Create CV'**
  String get createCvTitle;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @reachRecruiters.
  ///
  /// In en, this message translates to:
  /// **'Let recruiters know how to reach you'**
  String get reachRecruiters;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Jake sonner'**
  String get fullNameHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'jakesonner@gmail.com'**
  String get emailHint;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'Phnom Penh, Cambodia'**
  String get locationHint;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'0964516334'**
  String get phoneHint;

  /// No description provided for @personalSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal Summary'**
  String get personalSummaryLabel;

  /// No description provided for @personalSummaryHint.
  ///
  /// In en, this message translates to:
  /// **'Write a brief summary about yourself...'**
  String get personalSummaryHint;

  /// No description provided for @workExperience.
  ///
  /// In en, this message translates to:
  /// **'Work Experience'**
  String get workExperience;

  /// No description provided for @workExperienceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter details about your previous jobs'**
  String get workExperienceSubtitle;

  /// No description provided for @addExperience.
  ///
  /// In en, this message translates to:
  /// **'Add Experience'**
  String get addExperience;

  /// No description provided for @educationTitle.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get educationTitle;

  /// No description provided for @educationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'List your educational background'**
  String get educationSubtitle;

  /// No description provided for @addEducation.
  ///
  /// In en, this message translates to:
  /// **'Add Education'**
  String get addEducation;

  /// No description provided for @skillsLanguages.
  ///
  /// In en, this message translates to:
  /// **'Skills & Languages'**
  String get skillsLanguages;

  /// No description provided for @skillsLanguagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Highlight your key competencies'**
  String get skillsLanguagesSubtitle;

  /// No description provided for @skillsLabel.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skillsLabel;

  /// No description provided for @skillsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Flutter, Dart, UI/UX (comma separated)'**
  String get skillsHint;

  /// No description provided for @languagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languagesLabel;

  /// No description provided for @languagesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Khmer, English (comma separated)'**
  String get languagesHint;

  /// No description provided for @referencesTitle.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get referencesTitle;

  /// No description provided for @referencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add people who can vouch for you'**
  String get referencesSubtitle;

  /// No description provided for @addReference.
  ///
  /// In en, this message translates to:
  /// **'Add Reference'**
  String get addReference;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @previewExport.
  ///
  /// In en, this message translates to:
  /// **'Preview & Export'**
  String get previewExport;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get nextStep;

  /// No description provided for @fixPersonalInfoError.
  ///
  /// In en, this message translates to:
  /// **'Please fix errors in Personal Info'**
  String get fixPersonalInfoError;

  /// No description provided for @editEducation.
  ///
  /// In en, this message translates to:
  /// **'Edit Education'**
  String get editEducation;

  /// No description provided for @degreeLabel.
  ///
  /// In en, this message translates to:
  /// **'Degree'**
  String get degreeLabel;

  /// No description provided for @degreeHint.
  ///
  /// In en, this message translates to:
  /// **'Bachelor of Computer Science'**
  String get degreeHint;

  /// No description provided for @institutionLabel.
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get institutionLabel;

  /// No description provided for @institutionHint.
  ///
  /// In en, this message translates to:
  /// **'Royal University of Phnom Penh'**
  String get institutionHint;

  /// No description provided for @startDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDateLabel;

  /// No description provided for @startDateHint.
  ///
  /// In en, this message translates to:
  /// **'2022'**
  String get startDateHint;

  /// No description provided for @endDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDateLabel;

  /// No description provided for @endDateHint.
  ///
  /// In en, this message translates to:
  /// **'2026'**
  String get endDateHint;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @editExperience.
  ///
  /// In en, this message translates to:
  /// **'Edit Experience'**
  String get editExperience;

  /// No description provided for @jobTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitleLabel;

  /// No description provided for @jobTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Software Engineer'**
  String get jobTitleHint;

  /// No description provided for @companyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyNameLabel;

  /// No description provided for @companyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get companyNameHint;

  /// No description provided for @jobDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Job Description'**
  String get jobDescriptionLabel;

  /// No description provided for @jobDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Type each point on a new line.\ne.g.\nDeveloped mobile apps\nFixed critical bugs'**
  String get jobDescriptionHint;

  /// No description provided for @editReference.
  ///
  /// In en, this message translates to:
  /// **'Edit Reference'**
  String get editReference;

  /// No description provided for @referenceHint.
  ///
  /// In en, this message translates to:
  /// **'Alex Johnson'**
  String get referenceHint;

  /// No description provided for @positionLabel.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get positionLabel;

  /// No description provided for @positionHint.
  ///
  /// In en, this message translates to:
  /// **'Senior Manager'**
  String get positionHint;

  /// No description provided for @companyOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Company (Optional)'**
  String get companyOptionalLabel;

  /// No description provided for @companyHint.
  ///
  /// In en, this message translates to:
  /// **'ABC Corporation'**
  String get companyHint;

  /// No description provided for @referenceEmailHint.
  ///
  /// In en, this message translates to:
  /// **'alex.johnson@example.com'**
  String get referenceEmailHint;

  /// No description provided for @referencePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'0964516334'**
  String get referencePhoneHint;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// No description provided for @saveJobLabel.
  ///
  /// In en, this message translates to:
  /// **'Save Job'**
  String get saveJobLabel;

  /// No description provided for @applicationLabel.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get applicationLabel;

  /// No description provided for @messageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageLabel;

  /// No description provided for @profileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileLabel;

  /// No description provided for @appliedLabel.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get appliedLabel;

  /// No description provided for @statsLabel.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsLabel;

  /// No description provided for @editJob.
  ///
  /// In en, this message translates to:
  /// **'Edit Job'**
  String get editJob;

  /// No description provided for @viewApplications.
  ///
  /// In en, this message translates to:
  /// **'View Applications'**
  String get viewApplications;

  /// No description provided for @deleteJob.
  ///
  /// In en, this message translates to:
  /// **'Delete Job'**
  String get deleteJob;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'ja',
    'km',
    'ko',
    'lo',
    'ms',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'km':
      return AppLocalizationsKm();
    case 'ko':
      return AppLocalizationsKo();
    case 'lo':
      return AppLocalizationsLo();
    case 'ms':
      return AppLocalizationsMs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
