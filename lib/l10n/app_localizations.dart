import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Driver App'**
  String get app_name;

  /// No description provided for @bank_account.
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get bank_account;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @language_already_selected.
  ///
  /// In en, this message translates to:
  /// **'This language is already selected'**
  String get language_already_selected;

  /// No description provided for @view_profile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get view_profile;

  /// No description provided for @my_cards.
  ///
  /// In en, this message translates to:
  /// **'My Cards'**
  String get my_cards;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @end_ride.
  ///
  /// In en, this message translates to:
  /// **'End Ride'**
  String get end_ride;

  /// No description provided for @field_required.
  ///
  /// In en, this message translates to:
  /// **'Field is required'**
  String get field_required;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @ssn_field_valid.
  ///
  /// In en, this message translates to:
  /// **'SSN must be exactly 9 digits'**
  String get ssn_field_valid;

  /// Validation message shown when name is too short
  ///
  /// In en, this message translates to:
  /// **'Name must be at least {min} characters'**
  String name_min_length(int min);

  /// No description provided for @todays_rides.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Rides'**
  String get todays_rides;

  /// No description provided for @your_car.
  ///
  /// In en, this message translates to:
  /// **'Your Car'**
  String get your_car;

  /// No description provided for @ratings.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratings;

  /// No description provided for @unabletosubmitfeedback.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit feedback'**
  String get unabletosubmitfeedback;

  /// No description provided for @rideDetails.
  ///
  /// In en, this message translates to:
  /// **'Ride Details'**
  String get rideDetails;

  /// No description provided for @noSpecialRequest.
  ///
  /// In en, this message translates to:
  /// **'No special request'**
  String get noSpecialRequest;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @addReviewHere.
  ///
  /// In en, this message translates to:
  /// **'Add your review here...'**
  String get addReviewHere;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @carpool.
  ///
  /// In en, this message translates to:
  /// **'Carpool'**
  String get carpool;

  /// No description provided for @nocompleteridesfound.
  ///
  /// In en, this message translates to:
  /// **'No completed rides found'**
  String get nocompleteridesfound;

  /// No description provided for @pleaseselectrating.
  ///
  /// In en, this message translates to:
  /// **'Please select rating'**
  String get pleaseselectrating;

  /// No description provided for @noPassengerfound.
  ///
  /// In en, this message translates to:
  /// **'No passengers found'**
  String get noPassengerfound;

  /// No description provided for @noCarpoolridesfound.
  ///
  /// In en, this message translates to:
  /// **'No carpool rides found'**
  String get noCarpoolridesfound;

  /// No description provided for @seatBooked.
  ///
  /// In en, this message translates to:
  /// **'No. of Seats Booked'**
  String get seatBooked;

  /// No description provided for @cancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Reason'**
  String get cancellationReason;

  /// No description provided for @noReasonProvided.
  ///
  /// In en, this message translates to:
  /// **'No reason provided'**
  String get noReasonProvided;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @your_complete_finished_trip.
  ///
  /// In en, this message translates to:
  /// **'Your finished trips will appear here'**
  String get your_complete_finished_trip;

  /// No description provided for @your_have_not_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Your haven\'t cancelled any rides'**
  String get your_have_not_cancelled;

  /// No description provided for @no_rides_cancelled_by_driver.
  ///
  /// In en, this message translates to:
  /// **'No rides cancelled by driver'**
  String get no_rides_cancelled_by_driver;

  /// No description provided for @carpool_text.
  ///
  /// In en, this message translates to:
  /// **'No carpool rides yet'**
  String get carpool_text;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get transactions;

  /// No description provided for @type_amount.
  ///
  /// In en, this message translates to:
  /// **'Type amount'**
  String get type_amount;

  /// No description provided for @bank_acc.
  ///
  /// In en, this message translates to:
  /// **'Add an account for quick withdrawals'**
  String get bank_acc;

  /// No description provided for @notification_center.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get notification_center;

  /// No description provided for @complete_rides_rating.
  ///
  /// In en, this message translates to:
  /// **'Complete rides to start getting rated'**
  String get complete_rides_rating;

  /// No description provided for @invite_friends.
  ///
  /// In en, this message translates to:
  /// **'Your referral history will appear here once you start inviting'**
  String get invite_friends;

  /// No description provided for @account_status_complete_title.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Submission'**
  String get account_status_complete_title;

  /// No description provided for @account_status_complete_message.
  ///
  /// In en, this message translates to:
  /// **'You’ve entered some information, but your account is not under review yet.\nPlease submit your details to proceed with the verification process.'**
  String get account_status_complete_message;

  /// No description provided for @profile_review_notice.
  ///
  /// In en, this message translates to:
  /// **'*Once vehicle or document information is updated, the driver profile will move into a review state. During this review period, the driver may have restricted or no access to accept new rides until the information is approved.'**
  String get profile_review_notice;

  /// Shown when vehicle year is older than allowed range
  ///
  /// In en, this message translates to:
  /// **'Year cannot be older than {year}'**
  String profileYearTooOld(Object year);

  /// No description provided for @profileYearFuture.
  ///
  /// In en, this message translates to:
  /// **'Year cannot be in the future'**
  String get profileYearFuture;

  /// No description provided for @no_changes.
  ///
  /// In en, this message translates to:
  /// **'No changes to update.'**
  String get no_changes;

  /// No description provided for @name_no_numbers.
  ///
  /// In en, this message translates to:
  /// **'Name cannot contain numbers'**
  String get name_no_numbers;

  /// No description provided for @name_invalid_characters.
  ///
  /// In en, this message translates to:
  /// **'Name contains invalid characters'**
  String get name_invalid_characters;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @delete_notification.
  ///
  /// In en, this message translates to:
  /// **'Delete Notification'**
  String get delete_notification;

  /// No description provided for @delete_notification_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this notification?'**
  String get delete_notification_confirmation;

  /// No description provided for @delete_all_notifications.
  ///
  /// In en, this message translates to:
  /// **'Delete All Notifications'**
  String get delete_all_notifications;

  /// No description provided for @delete_all_notifications_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all notifications?'**
  String get delete_all_notifications_confirmation;

  /// No description provided for @notification_deleted_success.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted successfully.'**
  String get notification_deleted_success;

  /// No description provided for @notifications_deleted_success.
  ///
  /// In en, this message translates to:
  /// **'All notifications deleted successfully.'**
  String get notifications_deleted_success;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @onboarding_title_1.
  ///
  /// In en, this message translates to:
  /// **'Book a Ride Easily'**
  String get onboarding_title_1;

  /// No description provided for @onboarding_subtitle_1.
  ///
  /// In en, this message translates to:
  /// **'Find and book rides near you in seconds.'**
  String get onboarding_subtitle_1;

  /// No description provided for @onboarding_title_2.
  ///
  /// In en, this message translates to:
  /// **'Track Your Driver'**
  String get onboarding_title_2;

  /// No description provided for @onboarding_subtitle_2.
  ///
  /// In en, this message translates to:
  /// **'Real-time tracking from pickup to drop-off.'**
  String get onboarding_subtitle_2;

  /// No description provided for @onboarding_title_3.
  ///
  /// In en, this message translates to:
  /// **'Safe & Secure'**
  String get onboarding_title_3;

  /// No description provided for @onboarding_subtitle_3.
  ///
  /// In en, this message translates to:
  /// **'Your safety is our top priority.'**
  String get onboarding_subtitle_3;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get get_started;

  /// No description provided for @start_ride.
  ///
  /// In en, this message translates to:
  /// **'Start Ride'**
  String get start_ride;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome_back;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number to log in.'**
  String get login_subtitle;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @enter_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enter_phone_number;

  /// No description provided for @add_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Add phone number'**
  String get add_phone_number;

  /// No description provided for @continue_with_phone.
  ///
  /// In en, this message translates to:
  /// **'Continue With Phone Number'**
  String get continue_with_phone;

  /// No description provided for @no_account_prompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get no_account_prompt;

  /// No description provided for @phone_required.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phone_required;

  /// No description provided for @phone_invalid.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be valid'**
  String get phone_invalid;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// OTP subtitle with dynamic phone number
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP code sent to {number}'**
  String otp_subtitle(Object number);

  /// No description provided for @enter_otp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enter_otp;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @view_detail.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get view_detail;

  /// No description provided for @otp_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter the OTP to proceed'**
  String get otp_required;

  /// No description provided for @did_not_receive_code.
  ///
  /// In en, this message translates to:
  /// **'Didn’t receive the code?'**
  String get did_not_receive_code;

  /// No description provided for @resend_now.
  ///
  /// In en, this message translates to:
  /// **'Resend Now'**
  String get resend_now;

  /// No description provided for @number_verified.
  ///
  /// In en, this message translates to:
  /// **'Number Verified'**
  String get number_verified;

  /// No description provided for @number_verified_message.
  ///
  /// In en, this message translates to:
  /// **'Your phone number has been verified successfully!'**
  String get number_verified_message;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @account_under_review_title.
  ///
  /// In en, this message translates to:
  /// **'Account Under Review'**
  String get account_under_review_title;

  /// No description provided for @account_under_review_message.
  ///
  /// In en, this message translates to:
  /// **'Your driver account is currently under review. You\'ll be able to access the app once your profile is approved.'**
  String get account_under_review_message;

  /// No description provided for @account_review_notify_message.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be notified after the review is completed.'**
  String get account_review_notify_message;

  /// No description provided for @updates_visit_label.
  ///
  /// In en, this message translates to:
  /// **'For updates, visit:'**
  String get updates_visit_label;

  /// No description provided for @account_not_approved_title.
  ///
  /// In en, this message translates to:
  /// **'Account Not Approved'**
  String get account_not_approved_title;

  /// No description provided for @subscription_status.
  ///
  /// In en, this message translates to:
  /// **''**
  String get subscription_status;

  /// No description provided for @account_not_approved_message.
  ///
  /// In en, this message translates to:
  /// **'Your driver account was not approved at this time. To reapply, please complete the onboarding process again via the web portal.'**
  String get account_not_approved_message;

  /// No description provided for @reapply_at_label.
  ///
  /// In en, this message translates to:
  /// **'Reapply at:'**
  String get reapply_at_label;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgot_password;

  /// No description provided for @forgot_password_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to reset your password.'**
  String get forgot_password_subtitle;

  /// No description provided for @back_to_login.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get back_to_login;

  /// No description provided for @create_profile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get create_profile;

  /// No description provided for @signup_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your details to sign up.'**
  String get signup_subtitle;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get already_have_account;

  /// No description provided for @by_registering.
  ///
  /// In en, this message translates to:
  /// **'By registering, you accept our'**
  String get by_registering;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// No description provided for @enter_full_name.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enter_full_name;

  /// No description provided for @full_name_required.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get full_name_required;

  /// No description provided for @email_address.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email_address;

  /// No description provided for @in_app.
  ///
  /// In en, this message translates to:
  /// **'In-app'**
  String get in_app;

  /// No description provided for @enter_email.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enter_email;

  /// No description provided for @upload_profile_picture.
  ///
  /// In en, this message translates to:
  /// **'Upload Profile Picture'**
  String get upload_profile_picture;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get optional;

  /// No description provided for @my_profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get my_profile;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @total_time.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get total_time;

  /// No description provided for @total_distance.
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get total_distance;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'mins'**
  String get min;

  /// No description provided for @sec.
  ///
  /// In en, this message translates to:
  /// **'sec.'**
  String get sec;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @passenger.
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get passenger;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @avg_time.
  ///
  /// In en, this message translates to:
  /// **'Avg Time'**
  String get avg_time;

  /// No description provided for @total_amount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get total_amount;

  /// No description provided for @pickup_location.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickup_location;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @dropoff_location.
  ///
  /// In en, this message translates to:
  /// **'Drop-off Location'**
  String get dropoff_location;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @subtitle_logout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout your account?'**
  String get subtitle_logout;

  /// No description provided for @where_to.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get where_to;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get logoutDialogTitle;

  /// No description provided for @profileEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile Edit Successfully'**
  String get profileEditSuccess;

  /// No description provided for @profile_update_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Profile has been updated successfully'**
  String get profile_update_subtitle;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @current_location.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get current_location;

  /// No description provided for @pickup_details.
  ///
  /// In en, this message translates to:
  /// **'Pickup Details'**
  String get pickup_details;

  /// No description provided for @special_request.
  ///
  /// In en, this message translates to:
  /// **'Special Request'**
  String get special_request;

  /// No description provided for @set_pickup_location.
  ///
  /// In en, this message translates to:
  /// **'Set Pickup Location'**
  String get set_pickup_location;

  /// No description provided for @set_dropoff_location.
  ///
  /// In en, this message translates to:
  /// **'Set Drop-off Location'**
  String get set_dropoff_location;

  /// No description provided for @confirm_location.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirm_location;

  /// No description provided for @luxury.
  ///
  /// In en, this message translates to:
  /// **'Luxury'**
  String get luxury;

  /// No description provided for @economy.
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get economy;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @select_ride.
  ///
  /// In en, this message translates to:
  /// **'Select Ride'**
  String get select_ride;

  /// No description provided for @estimated_time.
  ///
  /// In en, this message translates to:
  /// **'Estimated Time'**
  String get estimated_time;

  /// No description provided for @estimated_fare.
  ///
  /// In en, this message translates to:
  /// **'Estimated Fare'**
  String get estimated_fare;

  /// No description provided for @finding_driver.
  ///
  /// In en, this message translates to:
  /// **'Finding your driver...'**
  String get finding_driver;

  /// No description provided for @driver_on_the_way.
  ///
  /// In en, this message translates to:
  /// **'Driver is on the way'**
  String get driver_on_the_way;

  /// No description provided for @arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// No description provided for @driver_arrived.
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived'**
  String get driver_arrived;

  /// No description provided for @ride_started.
  ///
  /// In en, this message translates to:
  /// **'Ride Started'**
  String get ride_started;

  /// No description provided for @ride_in_progress.
  ///
  /// In en, this message translates to:
  /// **'Ride in Progress!'**
  String get ride_in_progress;

  /// No description provided for @reached_destination.
  ///
  /// In en, this message translates to:
  /// **'You have reached your destination!'**
  String get reached_destination;

  /// No description provided for @reached_pickup_point.
  ///
  /// In en, this message translates to:
  /// **'You have reached the\npickup point!'**
  String get reached_pickup_point;

  /// No description provided for @ride_completed.
  ///
  /// In en, this message translates to:
  /// **'Ride Completed'**
  String get ride_completed;

  /// No description provided for @session_expired.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get session_expired;

  /// No description provided for @cancel_ride.
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride'**
  String get cancel_ride;

  /// No description provided for @cancel_carpool.
  ///
  /// In en, this message translates to:
  /// **'Cancel Carpool'**
  String get cancel_carpool;

  /// No description provided for @cancel_ride_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this ride?'**
  String get cancel_ride_confirmation;

  /// No description provided for @driver_profile.
  ///
  /// In en, this message translates to:
  /// **'Driver Profile'**
  String get driver_profile;

  /// No description provided for @call_driver.
  ///
  /// In en, this message translates to:
  /// **'Call Driver'**
  String get call_driver;

  /// No description provided for @chat_with_driver.
  ///
  /// In en, this message translates to:
  /// **'Chat with Driver'**
  String get chat_with_driver;

  /// No description provided for @payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get payment_method;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @add_payment_method.
  ///
  /// In en, this message translates to:
  /// **'Add Payment Method'**
  String get add_payment_method;

  /// No description provided for @add_card.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get add_card;

  /// No description provided for @card_number.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get card_number;

  /// No description provided for @expiry_date.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiry_date;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @card_holder_name.
  ///
  /// In en, this message translates to:
  /// **'Card Holder Name'**
  String get card_holder_name;

  /// No description provided for @add_account.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get add_account;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account;

  /// No description provided for @ride_history.
  ///
  /// In en, this message translates to:
  /// **'Ride History'**
  String get ride_history;

  /// No description provided for @no_rides_found.
  ///
  /// In en, this message translates to:
  /// **'No rides found'**
  String get no_rides_found;

  /// No description provided for @rate_your_ride.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Ride'**
  String get rate_your_ride;

  /// No description provided for @leave_feedback.
  ///
  /// In en, this message translates to:
  /// **'Leave Feedback'**
  String get leave_feedback;

  /// No description provided for @add_tip.
  ///
  /// In en, this message translates to:
  /// **'Add Tip'**
  String get add_tip;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @terms_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms_conditions;

  /// No description provided for @continue_label.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_label;

  /// No description provided for @service_region_title.
  ///
  /// In en, this message translates to:
  /// **'Outside Service Region'**
  String get service_region_title;

  /// No description provided for @service_region_message.
  ///
  /// In en, this message translates to:
  /// **'You are not in {regionName} right now. Please choose a location within {regionName} to continue.'**
  String service_region_message(Object regionName);

  /// No description provided for @service_region_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get service_region_logout;

  /// No description provided for @no_vehicle_types_available.
  ///
  /// In en, this message translates to:
  /// **'No vehicle types available.'**
  String get no_vehicle_types_available;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @help_center.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get help_center;

  /// No description provided for @something_went_wrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get something_went_wrong;

  /// No description provided for @no_internet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get no_internet;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get try_again;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @ride_request.
  ///
  /// In en, this message translates to:
  /// **'Ride Request'**
  String get ride_request;

  /// No description provided for @ride_request_unavailable.
  ///
  /// In en, this message translates to:
  /// **'This ride request is no longer available.'**
  String get ride_request_unavailable;

  /// No description provided for @ride_request_taken_toast.
  ///
  /// In en, this message translates to:
  /// **'That ride was already taken by another driver.'**
  String get ride_request_taken_toast;

  /// No description provided for @ride_request_expired_toast.
  ///
  /// In en, this message translates to:
  /// **'That ride request expired.'**
  String get ride_request_expired_toast;

  /// No description provided for @ride_request_dispatch_radius.
  ///
  /// In en, this message translates to:
  /// **'{radius} {unit} away'**
  String ride_request_dispatch_radius(Object radius, Object unit);

  /// No description provided for @ride_request_offline_toast.
  ///
  /// In en, this message translates to:
  /// **'You are offline right now. Please go online again to view ride requests.'**
  String get ride_request_offline_toast;

  /// No description provided for @ride_request_refreshing_queue_label.
  ///
  /// In en, this message translates to:
  /// **'Refreshing live queue'**
  String get ride_request_refreshing_queue_label;

  /// No description provided for @ride_request_syncing_queue_label.
  ///
  /// In en, this message translates to:
  /// **'Syncing queue'**
  String get ride_request_syncing_queue_label;

  /// No description provided for @ride_request_updated_label.
  ///
  /// In en, this message translates to:
  /// **'Updated {timeAgo}'**
  String ride_request_updated_label(Object timeAgo);

  /// No description provided for @ride_request_live_title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {Queue is clear} one {# live request} other {# live requests}}'**
  String ride_request_live_title(num count);

  /// No description provided for @ride_request_live_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Newest requests stay pinned at the top so the latest ride is always first.'**
  String get ride_request_live_subtitle;

  /// No description provided for @ride_request_ready_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You are online and ready. We will keep refreshing this queue every few seconds.'**
  String get ride_request_ready_subtitle;

  /// No description provided for @ride_request_go_online_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Go online from the dashboard to start receiving ride requests.'**
  String get ride_request_go_online_subtitle;

  /// No description provided for @ride_request_status_live_sync.
  ///
  /// In en, this message translates to:
  /// **'Live sync'**
  String get ride_request_status_live_sync;

  /// No description provided for @ride_request_status_newest_first.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get ride_request_status_newest_first;

  /// No description provided for @ride_request_driver_online.
  ///
  /// In en, this message translates to:
  /// **'Driver is online'**
  String get ride_request_driver_online;

  /// No description provided for @ride_request_driver_offline.
  ///
  /// In en, this message translates to:
  /// **'Driver is offline'**
  String get ride_request_driver_offline;

  /// No description provided for @ride_request_empty_title_online.
  ///
  /// In en, this message translates to:
  /// **'No pending requests right now'**
  String get ride_request_empty_title_online;

  /// No description provided for @ride_request_empty_title_offline.
  ///
  /// In en, this message translates to:
  /// **'You are offline right now'**
  String get ride_request_empty_title_offline;

  /// No description provided for @ride_request_empty_subtitle_online.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh or keep this screen open. New ride requests will slide in here automatically.'**
  String get ride_request_empty_subtitle_online;

  /// No description provided for @ride_request_empty_subtitle_offline.
  ///
  /// In en, this message translates to:
  /// **'Go back to the dashboard and switch yourself online to start receiving new requests.'**
  String get ride_request_empty_subtitle_offline;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get on;

  /// No description provided for @wait_timer.
  ///
  /// In en, this message translates to:
  /// **'Wait timer'**
  String get wait_timer;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @account_name.
  ///
  /// In en, this message translates to:
  /// **'Account Info'**
  String get account_name;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @available_balance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get available_balance;

  /// No description provided for @no_transactions_found.
  ///
  /// In en, this message translates to:
  /// **'No transaction found'**
  String get no_transactions_found;

  /// No description provided for @withdraw_funds.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Funds'**
  String get withdraw_funds;

  /// No description provided for @total_earnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get total_earnings;

  /// No description provided for @enter_amount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enter_amount;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @saved_locations.
  ///
  /// In en, this message translates to:
  /// **'Saved Locations'**
  String get saved_locations;

  /// No description provided for @add_location.
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get add_location;

  /// No description provided for @office.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get office;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @gym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get gym;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @withdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get withdrawn;

  /// No description provided for @location_permission_title.
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get location_permission_title;

  /// No description provided for @permission_denied_mesg.
  ///
  /// In en, this message translates to:
  /// **'This app needs your location to show nearby rides and provide accurate pickup/dropoff services. Please grant location permission to continue.'**
  String get permission_denied_mesg;

  /// No description provided for @location_permission_required_title.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get location_permission_required_title;

  /// No description provided for @permanently_denied_mesg.
  ///
  /// In en, this message translates to:
  /// **'Location permission has been permanently denied. Please enable it in your device settings to use location-based features.'**
  String get permanently_denied_mesg;

  /// No description provided for @location_services_disabled_title.
  ///
  /// In en, this message translates to:
  /// **'Location Services Disabled'**
  String get location_services_disabled_title;

  /// No description provided for @location_services_disabled_mesg.
  ///
  /// In en, this message translates to:
  /// **'Location services are currently disabled on your device. Please enable them in your device settings to continue.'**
  String get location_services_disabled_mesg;

  /// No description provided for @ride_location_required_title.
  ///
  /// In en, this message translates to:
  /// **'Turn On GPS to Continue the Ride'**
  String get ride_location_required_title;

  /// No description provided for @ride_location_required_message.
  ///
  /// In en, this message translates to:
  /// **'Location services must stay enabled during an active ride. Turn GPS back on to continue using the app and complete the trip.'**
  String get ride_location_required_message;

  /// No description provided for @failed_to_request.
  ///
  /// In en, this message translates to:
  /// **'Failed to request location permission'**
  String get failed_to_request;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get error_occurred;

  /// No description provided for @open_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get open_settings;

  /// No description provided for @withdrawal_now.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdrawal_now;

  /// No description provided for @themePreferences.
  ///
  /// In en, this message translates to:
  /// **'Theme Preferences'**
  String get themePreferences;

  /// No description provided for @themeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic (Day & Night Mode)'**
  String get themeAutomatic;

  /// No description provided for @themeAutomaticSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light theme during the day and dark theme at night.'**
  String get themeAutomaticSubtitle;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeDarkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always use dark mode'**
  String get themeDarkSubtitle;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeLightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always use light mode'**
  String get themeLightSubtitle;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @customer_reviews.
  ///
  /// In en, this message translates to:
  /// **'Customer reviews'**
  String get customer_reviews;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @cancelling.
  ///
  /// In en, this message translates to:
  /// **'Cancelling...'**
  String get cancelling;

  /// No description provided for @see_less.
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get see_less;

  /// No description provided for @see_more.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get see_more;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @invite_drawer.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get invite_drawer;

  /// No description provided for @start_chat_fallback.
  ///
  /// In en, this message translates to:
  /// **'There are no new messages yet'**
  String get start_chat_fallback;

  /// No description provided for @copy_link.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copy_link;

  /// No description provided for @your_ride_has_been.
  ///
  /// In en, this message translates to:
  /// **'Your ride has been completed successfully'**
  String get your_ride_has_been;

  /// No description provided for @whenStartRide.
  ///
  /// In en, this message translates to:
  /// **'When will you start this ride?'**
  String get whenStartRide;

  /// No description provided for @chooseStartTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a specific time to start the ride.'**
  String get chooseStartTime;

  /// No description provided for @invitation_link.
  ///
  /// In en, this message translates to:
  /// **'Invitation Link'**
  String get invitation_link;

  /// No description provided for @rideStartTimeSeats.
  ///
  /// In en, this message translates to:
  /// **'Ride Start Time & Seats'**
  String get rideStartTimeSeats;

  /// star
  ///
  /// In en, this message translates to:
  /// **'{star}  ({count})'**
  String star_count(Object star, Object count);

  /// No description provided for @search_address.
  ///
  /// In en, this message translates to:
  /// **'Search Address'**
  String get search_address;

  /// No description provided for @we_couldnot_found.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any matching addresses'**
  String get we_couldnot_found;

  /// No description provided for @use_this_address.
  ///
  /// In en, this message translates to:
  /// **'Use this address'**
  String get use_this_address;

  /// No description provided for @language_updated_title.
  ///
  /// In en, this message translates to:
  /// **'Language Updated!'**
  String get language_updated_title;

  /// No description provided for @under_review_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Updating these details will put your account back under review. You won\'t be able to accept rides until you are re-approved. Do you want to continue?'**
  String get under_review_subtitle;

  /// No description provided for @passenger_detail.
  ///
  /// In en, this message translates to:
  /// **'Passenger Details'**
  String get passenger_detail;

  /// No description provided for @carpool_ride.
  ///
  /// In en, this message translates to:
  /// **'Carpool'**
  String get carpool_ride;

  /// No description provided for @enter_last_name.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get enter_last_name;

  /// No description provided for @enter_first_name.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get enter_first_name;

  /// No description provided for @first_name.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get first_name;

  /// No description provided for @last_name.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get last_name;

  /// No description provided for @enter_street.
  ///
  /// In en, this message translates to:
  /// **'Enter street'**
  String get enter_street;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @enter_city.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get enter_city;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @enter_state.
  ///
  /// In en, this message translates to:
  /// **'Enter state'**
  String get enter_state;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @going_back_under_review.
  ///
  /// In en, this message translates to:
  /// **'Going back will put you in under review. Are you sure you want to go back? You can update these details if you want.'**
  String get going_back_under_review;

  /// No description provided for @language_updated_message.
  ///
  /// In en, this message translates to:
  /// **'Tu idioma se ha actualizado correctamente.'**
  String get language_updated_message;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @invite_friend.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get invite_friend;

  /// No description provided for @driverAccountNotCreatedWeb.
  ///
  /// In en, this message translates to:
  /// **'Your driver account is not created yet. Please register on the website first.'**
  String get driverAccountNotCreatedWeb;

  /// No description provided for @driverAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Driver Account Not Found'**
  String get driverAccountNotFound;

  /// No description provided for @attach_bank_account.
  ///
  /// In en, this message translates to:
  /// **'Attach your bank account'**
  String get attach_bank_account;

  /// No description provided for @debit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get debit;

  /// No description provided for @viewPassenger.
  ///
  /// In en, this message translates to:
  /// **'View Passengers'**
  String get viewPassenger;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @no_rides.
  ///
  /// In en, this message translates to:
  /// **'No rides available'**
  String get no_rides;

  /// No description provided for @by_user.
  ///
  /// In en, this message translates to:
  /// **'By User'**
  String get by_user;

  /// No description provided for @by_driver.
  ///
  /// In en, this message translates to:
  /// **'By Driver'**
  String get by_driver;

  /// No description provided for @no_bank_accounts_found.
  ///
  /// In en, this message translates to:
  /// **'No bank accounts found'**
  String get no_bank_accounts_found;

  /// No description provided for @attached_bank_accounts.
  ///
  /// In en, this message translates to:
  /// **'Attached Bank Accounts'**
  String get attached_bank_accounts;

  /// No description provided for @select_bank.
  ///
  /// In en, this message translates to:
  /// **'Select Bank'**
  String get select_bank;

  /// No description provided for @platform_fee_deducted.
  ///
  /// In en, this message translates to:
  /// **'A 3% platform fee will be deducted from your withdrawal amount.'**
  String get platform_fee_deducted;

  /// No description provided for @delete_bank_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Bank Account'**
  String get delete_bank_account;

  /// Confirmation text before deleting a bank account
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {bankTitle} ending in {last4}?'**
  String bank_delete_confirmation(Object bankTitle, Object last4);

  /// No description provided for @bank_attach_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to attach bank account.'**
  String get bank_attach_failed;

  /// No description provided for @bank_account_attached_success.
  ///
  /// In en, this message translates to:
  /// **'Bank account attached successfully.'**
  String get bank_account_attached_success;

  /// No description provided for @bank_account_deleted_success.
  ///
  /// In en, this message translates to:
  /// **'Bank account deleted successfully.'**
  String get bank_account_deleted_success;

  /// No description provided for @attach_bank_account_description.
  ///
  /// In en, this message translates to:
  /// **'Add a US bank account. We create a Stripe bank token and send it to the backend.'**
  String get attach_bank_account_description;

  /// No description provided for @account_holder_name.
  ///
  /// In en, this message translates to:
  /// **'Account holder name'**
  String get account_holder_name;

  /// No description provided for @account_holder_name_required.
  ///
  /// In en, this message translates to:
  /// **'Account holder name is required'**
  String get account_holder_name_required;

  /// No description provided for @routing_number.
  ///
  /// In en, this message translates to:
  /// **'Routing number'**
  String get routing_number;

  /// No description provided for @routing_number_required.
  ///
  /// In en, this message translates to:
  /// **'Routing number is required'**
  String get routing_number_required;

  /// No description provided for @routing_number_must_be_9_digits.
  ///
  /// In en, this message translates to:
  /// **'Routing number must be 9 digits'**
  String get routing_number_must_be_9_digits;

  /// No description provided for @account_number.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get account_number;

  /// No description provided for @account_number_required.
  ///
  /// In en, this message translates to:
  /// **'Account number is required'**
  String get account_number_required;

  /// No description provided for @account_number_must_be_4_to_17_digits.
  ///
  /// In en, this message translates to:
  /// **'Account number must be 4 to 17 digits'**
  String get account_number_must_be_4_to_17_digits;

  /// No description provided for @country_us.
  ///
  /// In en, this message translates to:
  /// **'Country (US)'**
  String get country_us;

  /// No description provided for @country_required.
  ///
  /// In en, this message translates to:
  /// **'Country is required'**
  String get country_required;

  /// No description provided for @currency_usd.
  ///
  /// In en, this message translates to:
  /// **'Currency (usd)'**
  String get currency_usd;

  /// No description provided for @currency_required.
  ///
  /// In en, this message translates to:
  /// **'Currency is required'**
  String get currency_required;

  /// No description provided for @account_holder_type.
  ///
  /// In en, this message translates to:
  /// **'Account holder type'**
  String get account_holder_type;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @add_bank_account.
  ///
  /// In en, this message translates to:
  /// **'Attached Bank Account'**
  String get add_bank_account;

  /// No description provided for @driver_onboarding_title.
  ///
  /// In en, this message translates to:
  /// **'Drivers are onboarded via the web portal.'**
  String get driver_onboarding_title;

  /// No description provided for @driver_onboarding_message.
  ///
  /// In en, this message translates to:
  /// **'If your number is already registered, you\'ll receive an OTP to continue.'**
  String get driver_onboarding_message;

  /// No description provided for @driver_onboarding_visit_label.
  ///
  /// In en, this message translates to:
  /// **'Registration is Available Online'**
  String get driver_onboarding_visit_label;

  /// No description provided for @click_here.
  ///
  /// In en, this message translates to:
  /// **'Click Here'**
  String get click_here;

  /// No description provided for @account_approved_title.
  ///
  /// In en, this message translates to:
  /// **'Your account has been approved successfully!'**
  String get account_approved_title;

  /// No description provided for @manu_year.
  ///
  /// In en, this message translates to:
  /// **'Manufacture Year'**
  String get manu_year;

  /// No description provided for @account_approved_message.
  ///
  /// In en, this message translates to:
  /// **'To start using the services, please purchase a subscription plan. Once your subscription is active, you’ll be able to access all features.'**
  String get account_approved_message;

  /// No description provided for @subscription_note.
  ///
  /// In en, this message translates to:
  /// **'Note: To buy a subscription, please visit the website using the link below:'**
  String get subscription_note;

  /// No description provided for @subscription_status_title.
  ///
  /// In en, this message translates to:
  /// **'Subscription Status'**
  String get subscription_status_title;

  /// No description provided for @profileRegistrationMustBeUnique.
  ///
  /// In en, this message translates to:
  /// **'Registration number must be unique'**
  String get profileRegistrationMustBeUnique;

  /// No description provided for @subscription_status_message.
  ///
  /// In en, this message translates to:
  /// **'Your subscription {status}, please renew'**
  String subscription_status_message(Object status);

  /// No description provided for @subscription_renew_note.
  ///
  /// In en, this message translates to:
  /// **'To renew your subscription, please visit the website below:'**
  String get subscription_renew_note;

  /// No description provided for @profileVinMustBeUnique.
  ///
  /// In en, this message translates to:
  /// **'VIN must be unique'**
  String get profileVinMustBeUnique;

  /// No description provided for @delete_account_otp_prefix.
  ///
  /// In en, this message translates to:
  /// **'We will send a 6-digit code to'**
  String get delete_account_otp_prefix;

  /// No description provided for @delete_account_data_warning.
  ///
  /// In en, this message translates to:
  /// **'Your data will be removed from our database permanently.'**
  String get delete_account_data_warning;

  /// No description provided for @send_otp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get send_otp;

  /// No description provided for @valid_amount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get valid_amount;

  /// No description provided for @amount_must_be_greater_than_0.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amount_must_be_greater_than_0;

  /// No description provided for @insufficient_balance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get insufficient_balance;

  /// No description provided for @max_2_decimal_places_allowed.
  ///
  /// In en, this message translates to:
  /// **'Maximum 2 decimal places allowed'**
  String get max_2_decimal_places_allowed;

  /// No description provided for @profileMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileMyProfile;

  /// No description provided for @profilePersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInformation;

  /// No description provided for @profileVehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get profileVehicleDetails;

  /// No description provided for @profileDrivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get profileDrivingLicense;

  /// No description provided for @profileVehicleRegistration.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration'**
  String get profileVehicleRegistration;

  /// No description provided for @profileInsuranceInformation.
  ///
  /// In en, this message translates to:
  /// **'Insurance Information'**
  String get profileInsuranceInformation;

  /// No description provided for @profileUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile.'**
  String get profileUnableToLoad;

  /// No description provided for @profileRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get profileRetry;

  /// No description provided for @profileChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profileChooseFromGallery;

  /// No description provided for @profileTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get profileTakePhoto;

  /// No description provided for @profileEditPersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Edit Personal Information'**
  String get profileEditPersonalInformation;

  /// No description provided for @profileChangeProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Picture'**
  String get profileChangeProfilePicture;

  /// No description provided for @profilePictureRequired.
  ///
  /// In en, this message translates to:
  /// **'Profile picture is required'**
  String get profilePictureRequired;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileFullName;

  /// No description provided for @rideRequestsWaiting.
  ///
  /// In en, this message translates to:
  /// **'Ride requests are waiting'**
  String get rideRequestsWaiting;

  /// No description provided for @driverOnlineActive.
  ///
  /// In en, this message translates to:
  /// **'You are live and listening for the next ride'**
  String get driverOnlineActive;

  /// No description provided for @driverGoOnline.
  ///
  /// In en, this message translates to:
  /// **'Go online to start receiving ride requests'**
  String get driverGoOnline;

  /// No description provided for @vehicleMake.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get vehicleMake;

  /// No description provided for @vehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get vehicleModel;

  /// No description provided for @vehicleRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get vehicleRegistration;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @camera_permission_title.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission'**
  String get camera_permission_title;

  /// No description provided for @camera_permission_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to continue'**
  String get camera_permission_subtitle;

  /// No description provided for @profileEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get profileEnterFullName;

  /// No description provided for @profileEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get profileEmailAddress;

  /// No description provided for @profileEnterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get profileEnterEmailAddress;

  /// No description provided for @profileAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profileAddress;

  /// No description provided for @profileEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter address'**
  String get profileEnterAddress;

  /// No description provided for @profileStreet.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get profileStreet;

  /// No description provided for @profileEnterStreet.
  ///
  /// In en, this message translates to:
  /// **'Enter street address'**
  String get profileEnterStreet;

  /// No description provided for @profileCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get profileCity;

  /// No description provided for @profileEnterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get profileEnterCity;

  /// No description provided for @profileState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get profileState;

  /// No description provided for @profileEnterState.
  ///
  /// In en, this message translates to:
  /// **'Enter state'**
  String get profileEnterState;

  /// No description provided for @profilePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profilePhoneNumber;

  /// No description provided for @profilePhoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profilePhoneNumberHint;

  /// No description provided for @profileUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get profileUpdate;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @profileEditVehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle Details'**
  String get profileEditVehicleDetails;

  /// No description provided for @profileVehicleMake.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get profileVehicleMake;

  /// No description provided for @profileVehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get profileVehicleModel;

  /// No description provided for @profileVehicleColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get profileVehicleColor;

  /// No description provided for @profileYear.
  ///
  /// In en, this message translates to:
  /// **'Year Of Manufacture'**
  String get profileYear;

  /// No description provided for @profileVin.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Identification Number'**
  String get profileVin;

  /// No description provided for @profileLicensePlate.
  ///
  /// In en, this message translates to:
  /// **'Number Plate'**
  String get profileLicensePlate;

  /// No description provided for @profileRegistrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get profileRegistrationNumber;

  /// No description provided for @profileRegionOfRegistration.
  ///
  /// In en, this message translates to:
  /// **'State/Region Of Registration'**
  String get profileRegionOfRegistration;

  /// No description provided for @profileRegistrationExpiry.
  ///
  /// In en, this message translates to:
  /// **'Registration Expiry Date'**
  String get profileRegistrationExpiry;

  /// No description provided for @profileVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get profileVehicleType;

  /// No description provided for @profileVehicleUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Vehicle details submitted for approval'**
  String get profileVehicleUpdatedSuccessfully;

  /// No description provided for @unable_to_get.
  ///
  /// In en, this message translates to:
  /// **'Unable to get your current location'**
  String get unable_to_get;

  /// No description provided for @chat_no_messages_yet.
  ///
  /// In en, this message translates to:
  /// **'No new messages yet'**
  String get chat_no_messages_yet;

  /// No description provided for @profileDataNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Profile data is not loaded yet.'**
  String get profileDataNotLoaded;

  /// No description provided for @profileNoChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes to update.'**
  String get profileNoChanges;

  /// No description provided for @profileFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get profileFieldRequired;

  /// No description provided for @profileVinInvalidLength.
  ///
  /// In en, this message translates to:
  /// **'VIN must be exactly 17 characters'**
  String get profileVinInvalidLength;

  /// No description provided for @profileVinInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid VIN (letters and numbers, excluding I, O, and Q)'**
  String get profileVinInvalidFormat;

  /// No description provided for @profileNumberPlateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Number plate must be 1 to 7 uppercase letters or numbers'**
  String get profileNumberPlateInvalid;

  /// No description provided for @profileRegistrationNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Registration number must be 1 to 8 uppercase letters or numbers'**
  String get profileRegistrationNumberInvalid;

  /// No description provided for @profileEnterValidYear.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid year'**
  String get profileEnterValidYear;

  /// No description provided for @profileYearRange.
  ///
  /// In en, this message translates to:
  /// **'Year should be between 1900 and 2100'**
  String get profileYearRange;

  /// No description provided for @profileEditDriverLicense.
  ///
  /// In en, this message translates to:
  /// **'Edit Driver License'**
  String get profileEditDriverLicense;

  /// No description provided for @profileLicenseUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'License updated successfully'**
  String get profileLicenseUpdatedSuccessfully;

  /// No description provided for @profileEditInsurance.
  ///
  /// In en, this message translates to:
  /// **'Edit Insurance Information'**
  String get profileEditInsurance;

  /// No description provided for @profileInsuranceUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Insurance updated successfully'**
  String get profileInsuranceUpdatedSuccessfully;

  /// No description provided for @profileEditVehicleRegistration.
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle Registration'**
  String get profileEditVehicleRegistration;

  /// No description provided for @profileVehicleRegistrationUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Vehicle registration updated successfully'**
  String get profileVehicleRegistrationUpdatedSuccessfully;

  /// No description provided for @profileUploadFrontImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Front Image'**
  String get profileUploadFrontImage;

  /// No description provided for @profileUploadBackImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Back Image'**
  String get profileUploadBackImage;

  /// No description provided for @profileUploadDocumentHint.
  ///
  /// In en, this message translates to:
  /// **'Upload document (JPG/PNG up to 20MB)'**
  String get profileUploadDocumentHint;

  /// No description provided for @profileExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get profileExpiryDate;

  /// No description provided for @profileLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get profileLicenseNumber;

  /// No description provided for @profileEnterLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter license number'**
  String get profileEnterLicenseNumber;

  /// No description provided for @profileFrontImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Front image is required.'**
  String get profileFrontImageRequired;

  /// No description provided for @profileBackImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Back image is required.'**
  String get profileBackImageRequired;

  /// No description provided for @profileUnableToPrepareFrontBack.
  ///
  /// In en, this message translates to:
  /// **'Unable to prepare front and back images. Please reselect both images and try again.'**
  String get profileUnableToPrepareFrontBack;

  /// No description provided for @profileUnableToPrepareFront.
  ///
  /// In en, this message translates to:
  /// **'Unable to prepare front image. Please reselect and try again.'**
  String get profileUnableToPrepareFront;

  /// No description provided for @profileUnableToPrepareInsurance.
  ///
  /// In en, this message translates to:
  /// **'Unable to prepare insurance image. Please reselect and try again.'**
  String get profileUnableToPrepareInsurance;

  /// No description provided for @profileImageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image size exceeds {size} MB. Please select a smaller file.'**
  String profileImageTooLarge(Object size);

  /// No description provided for @profileImageInvalidType.
  ///
  /// In en, this message translates to:
  /// **'Invalid file type. Only JPG and PNG are allowed.'**
  String get profileImageInvalidType;

  /// No description provided for @image_selection_failed.
  ///
  /// In en, this message translates to:
  /// **'Image selection failed. Please try again.'**
  String get image_selection_failed;

  /// No description provided for @map_load_error.
  ///
  /// In en, this message translates to:
  /// **'Map load error: {error}'**
  String map_load_error(Object error);

  /// No description provided for @no_reviews_found.
  ///
  /// In en, this message translates to:
  /// **'No reviews available yet.'**
  String get no_reviews_found;

  /// No description provided for @profileNoInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get profileNoInternetConnection;

  /// No description provided for @give_rating.
  ///
  /// In en, this message translates to:
  /// **'Give Rating to User'**
  String get give_rating;

  /// No description provided for @subtitle_dialgue.
  ///
  /// In en, this message translates to:
  /// **'Your report has been submitted We\'ll investigate the issue!'**
  String get subtitle_dialgue;

  /// No description provided for @report_submitted.
  ///
  /// In en, this message translates to:
  /// **'Report Submitted'**
  String get report_submitted;

  /// No description provided for @recent_ride.
  ///
  /// In en, this message translates to:
  /// **'Recent rides'**
  String get recent_ride;

  /// No description provided for @rate_passenger.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Passenger'**
  String get rate_passenger;

  /// No description provided for @your_rating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get your_rating;

  /// No description provided for @hint_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get hint_description;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @report_user.
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get report_user;

  /// No description provided for @chat_message_hint.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chat_message_hint;

  /// No description provided for @chat_block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get chat_block;

  /// No description provided for @chat_report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get chat_report;

  /// No description provided for @report_reason_unprofessional.
  ///
  /// In en, this message translates to:
  /// **'Unprofessional Behavior'**
  String get report_reason_unprofessional;

  /// No description provided for @report_reason_poor_communication.
  ///
  /// In en, this message translates to:
  /// **'Poor Communication'**
  String get report_reason_poor_communication;

  /// No description provided for @report_reason_fake_account.
  ///
  /// In en, this message translates to:
  /// **'Fake or Impersonating Account'**
  String get report_reason_fake_account;

  /// No description provided for @report_reason_harassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment or Bullying'**
  String get report_reason_harassment;

  /// No description provided for @report_reason_abuse.
  ///
  /// In en, this message translates to:
  /// **'Abuse or Misconduct'**
  String get report_reason_abuse;

  /// No description provided for @report_reason_violation_policies.
  ///
  /// In en, this message translates to:
  /// **'Violation Policies'**
  String get report_reason_violation_policies;

  /// No description provided for @block_user.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get block_user;

  /// No description provided for @block_user_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user?'**
  String get block_user_confirmation;

  /// No description provided for @don_t_block.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Block'**
  String get don_t_block;

  /// No description provided for @block_now.
  ///
  /// In en, this message translates to:
  /// **'Block Now'**
  String get block_now;

  /// No description provided for @we_appreciate_issue.
  ///
  /// In en, this message translates to:
  /// **'We appreciate your feedback. Please provide details & We\'ll investigate the issue.'**
  String get we_appreciate_issue;

  /// No description provided for @your_passenger_feedback.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us maintain a safe and respectful community for everyone.'**
  String get your_passenger_feedback;

  /// No description provided for @miles.
  ///
  /// In en, this message translates to:
  /// **'miles'**
  String get miles;

  /// No description provided for @selectStartTime.
  ///
  /// In en, this message translates to:
  /// **'Select start time'**
  String get selectStartTime;

  /// No description provided for @ride_date_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get ride_date_yesterday;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Starts In'**
  String get selectTime;

  /// No description provided for @select_time_valid.
  ///
  /// In en, this message translates to:
  /// **'Please select a time before continuing'**
  String get select_time_valid;

  /// No description provided for @ride_date_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get ride_date_today;

  /// No description provided for @selectFutureTime.
  ///
  /// In en, this message translates to:
  /// **'Please select a future time'**
  String get selectFutureTime;

  /// No description provided for @howManyPassengers.
  ///
  /// In en, this message translates to:
  /// **'How many passengers can you take on this ride?'**
  String get howManyPassengers;

  /// No description provided for @numberPassengers.
  ///
  /// In en, this message translates to:
  /// **'Number of Passengers'**
  String get numberPassengers;

  /// No description provided for @vehicleSeatLimit.
  ///
  /// In en, this message translates to:
  /// **'* You can only select seats based on your registered vehicle capacity.'**
  String get vehicleSeatLimit;

  /// No description provided for @continueSearch.
  ///
  /// In en, this message translates to:
  /// **'Continue to Search'**
  String get continueSearch;

  /// No description provided for @minimumSeatRequired.
  ///
  /// In en, this message translates to:
  /// **'Seat should be minimum 1'**
  String get minimumSeatRequired;

  /// No description provided for @start_time.
  ///
  /// In en, this message translates to:
  /// **'Ride Start Time'**
  String get start_time;

  /// No description provided for @ride_time.
  ///
  /// In en, this message translates to:
  /// **'Ride Time'**
  String get ride_time;

  /// No description provided for @start_time_within_hour.
  ///
  /// In en, this message translates to:
  /// **'Please select a start time within 1 hour from now.'**
  String get start_time_within_hour;

  /// No description provided for @unable_to_create_carpool_route.
  ///
  /// In en, this message translates to:
  /// **'Unable to create carpool route.'**
  String get unable_to_create_carpool_route;

  /// No description provided for @ride_progress.
  ///
  /// In en, this message translates to:
  /// **'Ride Progress'**
  String get ride_progress;

  /// No description provided for @ride_progress_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop {index}'**
  String ride_progress_stop(int index);

  /// No description provided for @ride_progress_no_route.
  ///
  /// In en, this message translates to:
  /// **'No route data'**
  String get ride_progress_no_route;

  /// No description provided for @start_time_label.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get start_time_label;

  /// No description provided for @available_seats.
  ///
  /// In en, this message translates to:
  /// **'Available Seats'**
  String get available_seats;

  /// No description provided for @total_distance_label.
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get total_distance_label;

  /// No description provided for @accept_one_passenger_hint.
  ///
  /// In en, this message translates to:
  /// **'Accept at least one passenger to start the ride.'**
  String get accept_one_passenger_hint;

  /// No description provided for @arrive_at_stop.
  ///
  /// In en, this message translates to:
  /// **'Arrive at Stop {index}'**
  String arrive_at_stop(int index);

  /// No description provided for @drop_off_passengers.
  ///
  /// In en, this message translates to:
  /// **'Drop Off Passengers'**
  String get drop_off_passengers;

  /// No description provided for @ssn.
  ///
  /// In en, this message translates to:
  /// **'Social Security Number'**
  String get ssn;

  /// No description provided for @enter_destination.
  ///
  /// In en, this message translates to:
  /// **'Enter Destination'**
  String get enter_destination;

  /// No description provided for @select_both_locations.
  ///
  /// In en, this message translates to:
  /// **'Please select both locations'**
  String get select_both_locations;

  /// No description provided for @rate_all_passengers_or_skip.
  ///
  /// In en, this message translates to:
  /// **'Please rate all passengers or tap Skip.'**
  String get rate_all_passengers_or_skip;

  /// No description provided for @give_rating_users.
  ///
  /// In en, this message translates to:
  /// **'Give Rating to Users'**
  String get give_rating_users;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @rate_your_passengers.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Passengers'**
  String get rate_your_passengers;

  /// No description provided for @no_passengers_to_rate.
  ///
  /// In en, this message translates to:
  /// **'No passengers available to rate.'**
  String get no_passengers_to_rate;

  /// No description provided for @passenger_number.
  ///
  /// In en, this message translates to:
  /// **'Passenger {index}'**
  String passenger_number(int index);

  /// No description provided for @selected_location_label.
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get selected_location_label;

  /// No description provided for @search_place_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for a place...'**
  String get search_place_hint;

  /// No description provided for @no_new_notifications.
  ///
  /// In en, this message translates to:
  /// **'No new notifications!'**
  String get no_new_notifications;

  /// No description provided for @missing_carpool_id.
  ///
  /// In en, this message translates to:
  /// **'Missing carpool ID'**
  String get missing_carpool_id;

  /// No description provided for @unable_to_go_online_title.
  ///
  /// In en, this message translates to:
  /// **'Unable to Go Online'**
  String get unable_to_go_online_title;

  /// No description provided for @fetching_location.
  ///
  /// In en, this message translates to:
  /// **'Fetching location...'**
  String get fetching_location;

  /// No description provided for @current_location_available.
  ///
  /// In en, this message translates to:
  /// **'Current location available'**
  String get current_location_available;

  /// No description provided for @unable_to_fetch_location.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch location'**
  String get unable_to_fetch_location;

  /// No description provided for @carpool_promo_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Earn more by sharing your route with passengers heading your way'**
  String get carpool_promo_subtitle;

  /// No description provided for @carpool_start_button.
  ///
  /// In en, this message translates to:
  /// **'Start Carpool Ride'**
  String get carpool_start_button;

  /// No description provided for @carpool_online_before_start.
  ///
  /// In en, this message translates to:
  /// **'Go online before starting a carpool ride'**
  String get carpool_online_before_start;

  /// No description provided for @normal_online_before_start.
  ///
  /// In en, this message translates to:
  /// **'Go online before starting a ride'**
  String get normal_online_before_start;

  /// No description provided for @unable_to_submit.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit feedback'**
  String get unable_to_submit;

  /// No description provided for @link_copied.
  ///
  /// In en, this message translates to:
  /// **'Link copied!'**
  String get link_copied;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'stars'**
  String get stars;

  /// No description provided for @unable_to_submit_rating.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit rating'**
  String get unable_to_submit_rating;

  /// No description provided for @please_select_rating.
  ///
  /// In en, this message translates to:
  /// **'Please select rating'**
  String get please_select_rating;

  /// No description provided for @add_stops_title.
  ///
  /// In en, this message translates to:
  /// **'Add Stops for Carpool Ride'**
  String get add_stops_title;

  /// No description provided for @ride_start_time.
  ///
  /// In en, this message translates to:
  /// **'Ride Start Time and Seats'**
  String get ride_start_time;

  /// No description provided for @list_of_request.
  ///
  /// In en, this message translates to:
  /// **'List of Requests'**
  String get list_of_request;

  /// No description provided for @search_carpool_ride.
  ///
  /// In en, this message translates to:
  /// **'Search Carpool Ride'**
  String get search_carpool_ride;

  /// No description provided for @add_stops_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Add stops along your route to accept carpool passengers easily.'**
  String get add_stops_subtitle;

  /// No description provided for @stop_title.
  ///
  /// In en, this message translates to:
  /// **'Stop {index}'**
  String stop_title(int index);

  /// No description provided for @starting_point_suffix.
  ///
  /// In en, this message translates to:
  /// **' (Starting Point)'**
  String get starting_point_suffix;

  /// No description provided for @final_destination_suffix.
  ///
  /// In en, this message translates to:
  /// **' (Final Destination)'**
  String get final_destination_suffix;

  /// No description provided for @tap_to_select_location.
  ///
  /// In en, this message translates to:
  /// **'Tap to select location'**
  String get tap_to_select_location;

  /// No description provided for @add_stops.
  ///
  /// In en, this message translates to:
  /// **'Add Stops'**
  String get add_stops;

  /// No description provided for @save_stops_continue.
  ///
  /// In en, this message translates to:
  /// **'Save Stops & Continue'**
  String get save_stops_continue;

  /// No description provided for @add_stop_warning.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one stop before continuing.'**
  String get add_stop_warning;

  /// No description provided for @carpool_requests_title.
  ///
  /// In en, this message translates to:
  /// **'Carpool Requests'**
  String get carpool_requests_title;

  /// No description provided for @carpool_requests_counts.
  ///
  /// In en, this message translates to:
  /// **'Pending: {pending} | Accepted: {accepted}'**
  String carpool_requests_counts(int pending, int accepted);

  /// No description provided for @carpool_missing_id.
  ///
  /// In en, this message translates to:
  /// **'Missing carpool ID. Go back and create a route again.'**
  String get carpool_missing_id;

  /// No description provided for @carpool_pending_requests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get carpool_pending_requests;

  /// No description provided for @carpool_no_pending.
  ///
  /// In en, this message translates to:
  /// **'No pending requests right now.'**
  String get carpool_no_pending;

  /// No description provided for @carpool_accepted_passengers.
  ///
  /// In en, this message translates to:
  /// **'Accepted Passengers'**
  String get carpool_accepted_passengers;

  /// No description provided for @carpool_no_accepted.
  ///
  /// In en, this message translates to:
  /// **'No accepted passengers yet.'**
  String get carpool_no_accepted;

  /// No description provided for @carpool_continue_progress.
  ///
  /// In en, this message translates to:
  /// **'Continue to Ride Progress'**
  String get carpool_continue_progress;

  /// No description provided for @carpool_back_to_search.
  ///
  /// In en, this message translates to:
  /// **'Back to Search'**
  String get carpool_back_to_search;

  /// No description provided for @no_of_passengers.
  ///
  /// In en, this message translates to:
  /// **'No of Passengers'**
  String get no_of_passengers;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @otp_verified.
  ///
  /// In en, this message translates to:
  /// **'OTP Verified'**
  String get otp_verified;

  /// No description provided for @booking_id_missing.
  ///
  /// In en, this message translates to:
  /// **'Missing booking ID for this request.'**
  String get booking_id_missing;

  /// No description provided for @request_action_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to {action} request.'**
  String request_action_failed(Object action);

  /// No description provided for @request_accept_success.
  ///
  /// In en, this message translates to:
  /// **'Passenger accepted successfully.'**
  String get request_accept_success;

  /// No description provided for @request_reject_success.
  ///
  /// In en, this message translates to:
  /// **'Passenger rejected successfully.'**
  String get request_reject_success;

  /// No description provided for @search_carpool_title.
  ///
  /// In en, this message translates to:
  /// **'Searching Carpool Requests'**
  String get search_carpool_title;

  /// No description provided for @starting_point.
  ///
  /// In en, this message translates to:
  /// **'Starting Point'**
  String get starting_point;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @stop_label.
  ///
  /// In en, this message translates to:
  /// **'Stop {index}'**
  String stop_label(int index);

  /// No description provided for @ride_start_time_label.
  ///
  /// In en, this message translates to:
  /// **'Ride Start Time'**
  String get ride_start_time_label;

  /// No description provided for @available_seats_label.
  ///
  /// In en, this message translates to:
  /// **'Available Seats'**
  String get available_seats_label;

  /// No description provided for @requests_found.
  ///
  /// In en, this message translates to:
  /// **'{count} Requests Found'**
  String requests_found(int count);

  /// No description provided for @view_requests.
  ///
  /// In en, this message translates to:
  /// **'View Requests ({count})'**
  String view_requests(int count);

  /// No description provided for @go_to_ride_progress.
  ///
  /// In en, this message translates to:
  /// **'Go to Ride Progress'**
  String get go_to_ride_progress;

  /// No description provided for @unable_cancel_carpool.
  ///
  /// In en, this message translates to:
  /// **'Unable to cancel carpool.'**
  String get unable_cancel_carpool;

  /// No description provided for @pickup_verification_title.
  ///
  /// In en, this message translates to:
  /// **'Pickup Verification'**
  String get pickup_verification_title;

  /// No description provided for @enter_otp_to_verify.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP code to verify your ride'**
  String get enter_otp_to_verify;

  /// No description provided for @otp_length_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid {length}-digit OTP.'**
  String otp_length_error(int length);

  /// No description provided for @otp_invalid_message.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please check and try again.'**
  String get otp_invalid_message;

  /// No description provided for @today_label.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today_label;

  /// No description provided for @no_incoming.
  ///
  /// In en, this message translates to:
  /// **'No incoming rides at the moment'**
  String get no_incoming;

  /// No description provided for @yesterday_label.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday_label;

  /// No description provided for @passenger_pick_success.
  ///
  /// In en, this message translates to:
  /// **'Passenger picked successfully.'**
  String get passenger_pick_success;

  /// No description provided for @passenger_pick_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to pick passenger.'**
  String get passenger_pick_failed;

  /// No description provided for @ride_end_success.
  ///
  /// In en, this message translates to:
  /// **'Ride ended successfully.'**
  String get ride_end_success;

  /// No description provided for @ride_end_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to end ride.'**
  String get ride_end_failed;

  /// No description provided for @passenger_removed_success.
  ///
  /// In en, this message translates to:
  /// **'Passenger removed successfully.'**
  String get passenger_removed_success;

  /// No description provided for @passenger_removed_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to remove passenger.'**
  String get passenger_removed_failed;

  /// No description provided for @removing.
  ///
  /// In en, this message translates to:
  /// **'Removing...'**
  String get removing;

  /// No description provided for @remove_passenger.
  ///
  /// In en, this message translates to:
  /// **'Remove Passenger'**
  String get remove_passenger;

  /// No description provided for @passenger_dropped.
  ///
  /// In en, this message translates to:
  /// **'Passenger Dropped'**
  String get passenger_dropped;

  /// No description provided for @dropping.
  ///
  /// In en, this message translates to:
  /// **'Dropping...'**
  String get dropping;

  /// No description provided for @picking.
  ///
  /// In en, this message translates to:
  /// **'Picking...'**
  String get picking;

  /// No description provided for @drop_passenger.
  ///
  /// In en, this message translates to:
  /// **'Drop Passenger'**
  String get drop_passenger;

  /// No description provided for @pick_passenger.
  ///
  /// In en, this message translates to:
  /// **'Pick Passenger'**
  String get pick_passenger;

  /// No description provided for @success_profile_approved_title.
  ///
  /// In en, this message translates to:
  /// **'Profile Approved'**
  String get success_profile_approved_title;

  /// No description provided for @success_profile_approved_message.
  ///
  /// In en, this message translates to:
  /// **'Your profile has been approved successfully.'**
  String get success_profile_approved_message;

  /// No description provided for @success_account_deleted_title.
  ///
  /// In en, this message translates to:
  /// **'Account Deleted!'**
  String get success_account_deleted_title;

  /// No description provided for @success_account_deleted_message.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted successfully.'**
  String get success_account_deleted_message;

  /// No description provided for @success_funds_added_title.
  ///
  /// In en, this message translates to:
  /// **'Funds Added!'**
  String get success_funds_added_title;

  /// No description provided for @success_funds_added_message.
  ///
  /// In en, this message translates to:
  /// **'Your funds have been added successfully.'**
  String get success_funds_added_message;

  /// No description provided for @success_feedback_title.
  ///
  /// In en, this message translates to:
  /// **'We appreciate your Feedback!'**
  String get success_feedback_title;

  /// No description provided for @success_feedback_message.
  ///
  /// In en, this message translates to:
  /// **'Your review has been submitted.'**
  String get success_feedback_message;

  /// No description provided for @invalid_otp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code. Please try again.'**
  String get invalid_otp;

  /// No description provided for @verify_delete_account.
  ///
  /// In en, this message translates to:
  /// **'Verify & Delete Account'**
  String get verify_delete_account;

  /// No description provided for @feedback_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us maintain a safe and respectful community for everyone.'**
  String get feedback_subtitle;

  /// No description provided for @no_internet_title.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get no_internet_title;

  /// No description provided for @no_internet_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please check your network settings and try again to continue using the app.'**
  String get no_internet_subtitle;

  /// No description provided for @slow_connection_title.
  ///
  /// In en, this message translates to:
  /// **'Connection Too Slow'**
  String get slow_connection_title;

  /// No description provided for @slow_connection_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your internet connection is too slow to use the app right now. Please check your network and try again.'**
  String get slow_connection_subtitle;

  /// No description provided for @slow_connection_banner.
  ///
  /// In en, this message translates to:
  /// **'Unstable connection. Some actions may be delayed.'**
  String get slow_connection_banner;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @notification_fallback_title.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification_fallback_title;

  /// No description provided for @end_ride_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to end this ride?'**
  String get end_ride_confirmation;

  /// No description provided for @drop_passenger_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to drop off this passenger?'**
  String get drop_passenger_confirmation;

  /// No description provided for @cancel_ride_question.
  ///
  /// In en, this message translates to:
  /// **'Why are you cancelling this ride?'**
  String get cancel_ride_question;

  /// No description provided for @reason_harassment.
  ///
  /// In en, this message translates to:
  /// **'Passenger is harassing me'**
  String get reason_harassment;

  /// No description provided for @reason_not_responding.
  ///
  /// In en, this message translates to:
  /// **'Passenger is not responding'**
  String get reason_not_responding;

  /// No description provided for @reason_asked_to_cancel.
  ///
  /// In en, this message translates to:
  /// **'Passenger asked me to cancel'**
  String get reason_asked_to_cancel;

  /// No description provided for @reason_unsafe_location.
  ///
  /// In en, this message translates to:
  /// **'Unsafe pickup location'**
  String get reason_unsafe_location;

  /// No description provided for @reason_vehicle_issue.
  ///
  /// In en, this message translates to:
  /// **'Vehicle issue'**
  String get reason_vehicle_issue;

  /// No description provided for @reason_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reason_other;

  /// No description provided for @navigate_in_google_maps.
  ///
  /// In en, this message translates to:
  /// **'Start Navigation'**
  String get navigate_in_google_maps;

  /// No description provided for @unable_to_open_google_maps.
  ///
  /// In en, this message translates to:
  /// **'Unable to start navigation'**
  String get unable_to_open_google_maps;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @recommend_google_maps.
  ///
  /// In en, this message translates to:
  /// **'Tap to start in-app turn-by-turn navigation'**
  String get recommend_google_maps;

  /// No description provided for @minimum_5_characters_required.
  ///
  /// In en, this message translates to:
  /// **'Minimum 5 characters required'**
  String get minimum_5_characters_required;

  /// No description provided for @address_cannot_be_only_numbers.
  ///
  /// In en, this message translates to:
  /// **'Address cannot be only numbers'**
  String get address_cannot_be_only_numbers;

  /// No description provided for @address_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid address'**
  String get address_invalid;

  /// No description provided for @confirm_stop.
  ///
  /// In en, this message translates to:
  /// **'Confirm Stop'**
  String get confirm_stop;

  /// No description provided for @confirm_pickup.
  ///
  /// In en, this message translates to:
  /// **'Confirm Pickup'**
  String get confirm_pickup;

  /// No description provided for @confirm_dropoff.
  ///
  /// In en, this message translates to:
  /// **'Confirm Dropoff'**
  String get confirm_dropoff;

  /// No description provided for @search_stop.
  ///
  /// In en, this message translates to:
  /// **'Search for a Stop...'**
  String get search_stop;

  /// No description provided for @search_pickup.
  ///
  /// In en, this message translates to:
  /// **'Search for a Pickup...'**
  String get search_pickup;

  /// No description provided for @search_dropoff.
  ///
  /// In en, this message translates to:
  /// **'Search for a Drop-off...'**
  String get search_dropoff;

  /// No description provided for @navigate_to_destination.
  ///
  /// In en, this message translates to:
  /// **'Start Navigation'**
  String get navigate_to_destination;

  /// No description provided for @navigation_route_calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating route...'**
  String get navigation_route_calculating;

  /// No description provided for @navigation_arrived.
  ///
  /// In en, this message translates to:
  /// **'You have arrived at your destination!'**
  String get navigation_arrived;

  /// No description provided for @navigation_route_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to calculate route. Please try again.'**
  String get navigation_route_failed;

  /// No description provided for @only_florida_addresses_supported.
  ///
  /// In en, this message translates to:
  /// **'Only Florida (FL) addresses are supported'**
  String get only_florida_addresses_supported;

  /// No description provided for @regular_balance.
  ///
  /// In en, this message translates to:
  /// **'Cash Balance'**
  String get regular_balance;

  /// No description provided for @rewarded_balance.
  ///
  /// In en, this message translates to:
  /// **'Rewarded Balance'**
  String get rewarded_balance;

  /// No description provided for @regular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get regular;

  /// No description provided for @rewarded.
  ///
  /// In en, this message translates to:
  /// **'Rewarded'**
  String get rewarded;

  /// No description provided for @referral_drawer.
  ///
  /// In en, this message translates to:
  /// **'My Driver Code'**
  String get referral_drawer;

  /// No description provided for @referral_title.
  ///
  /// In en, this message translates to:
  /// **'My Driver Code'**
  String get referral_title;

  /// Subtitle on the driver referral screen. {bonus} is the formatted amount returned by the API.
  ///
  /// In en, this message translates to:
  /// **'Show this code to new riders to claim a {bonus} reward bonus.'**
  String referral_explainer(Object bonus);

  /// No description provided for @referral_paused.
  ///
  /// In en, this message translates to:
  /// **'Referral codes are paused right now.'**
  String get referral_paused;

  /// No description provided for @referral_history.
  ///
  /// In en, this message translates to:
  /// **'Referral history'**
  String get referral_history;

  /// No description provided for @referral_rider_fallback.
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get referral_rider_fallback;

  /// No description provided for @referral_status_saved.
  ///
  /// In en, this message translates to:
  /// **'Waiting for first ride'**
  String get referral_status_saved;

  /// No description provided for @referral_status_applied.
  ///
  /// In en, this message translates to:
  /// **'Ride in progress'**
  String get referral_status_applied;

  /// No description provided for @referral_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Bonus earned'**
  String get referral_status_completed;

  /// No description provided for @referral_status_voided.
  ///
  /// In en, this message translates to:
  /// **'Ride cancelled, no bonus'**
  String get referral_status_voided;

  /// No description provided for @referral_copy_code.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get referral_copy_code;

  /// No description provided for @referral_code_copied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get referral_code_copied;

  /// No description provided for @referral_share.
  ///
  /// In en, this message translates to:
  /// **'Share code'**
  String get referral_share;

  /// Text shared from the driver referral screen. {discount} is the formatted rider discount returned by the API.
  ///
  /// In en, this message translates to:
  /// **'Ride with us and get {discount} off your first trip. Use my code {code} when you sign up.'**
  String referral_share_message(Object code, Object discount);

  /// No description provided for @referral_stat_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved your code'**
  String get referral_stat_saved;

  /// No description provided for @referral_stat_applied.
  ///
  /// In en, this message translates to:
  /// **'Ride in progress'**
  String get referral_stat_applied;

  /// No description provided for @referral_stat_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get referral_stat_completed;

  /// No description provided for @referral_stat_earned.
  ///
  /// In en, this message translates to:
  /// **'Total earned'**
  String get referral_stat_earned;

  /// No description provided for @referral_stat_voided.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get referral_stat_voided;

  /// No description provided for @transaction_referral_bonus.
  ///
  /// In en, this message translates to:
  /// **'Referral bonus'**
  String get transaction_referral_bonus;

  /// No description provided for @transaction_reward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get transaction_reward;

  /// No description provided for @address_search_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to look up this address. You can try again or enter it manually.'**
  String get address_search_failed;

  /// No description provided for @address_search_outside_region.
  ///
  /// In en, this message translates to:
  /// **'Choose an address within the service area.'**
  String get address_search_outside_region;

  /// No description provided for @address_search_retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get address_search_retry;

  /// No description provided for @address_search_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Address search is unavailable. Enter the address manually.'**
  String get address_search_unavailable;

  /// No description provided for @address_search_incomplete.
  ///
  /// In en, this message translates to:
  /// **'This address could not be confirmed. Enter the address manually.'**
  String get address_search_incomplete;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
