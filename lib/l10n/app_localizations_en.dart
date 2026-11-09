// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Driver App';

  @override
  String get bank_account => 'Bank Account';

  @override
  String get select_language => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get language_already_selected => 'This language is already selected';

  @override
  String get view_profile => 'View Profile';

  @override
  String get my_cards => 'My Cards';

  @override
  String get ok => 'OK';

  @override
  String get spanish => 'Spanish';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get end_ride => 'End Ride';

  @override
  String get field_required => 'Field is required';

  @override
  String get private => 'Private';

  @override
  String get ssn_field_valid => 'SSN must be exactly 9 digits';

  @override
  String name_min_length(int min) {
    return 'Name must be at least $min characters';
  }

  @override
  String get todays_rides => 'Today\'s Rides';

  @override
  String get your_car => 'Your Car';

  @override
  String get ratings => 'Ratings';

  @override
  String get unabletosubmitfeedback => 'Unable to submit feedback';

  @override
  String get rideDetails => 'Ride Details';

  @override
  String get noSpecialRequest => 'No special request';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get addReviewHere => 'Add your review here...';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get carpool => 'Carpool';

  @override
  String get nocompleteridesfound => 'No completed rides found';

  @override
  String get pleaseselectrating => 'Please select rating';

  @override
  String get noPassengerfound => 'No passengers found';

  @override
  String get noCarpoolridesfound => 'No carpool rides found';

  @override
  String get seatBooked => 'No. of Seats Booked';

  @override
  String get cancellationReason => 'Cancellation Reason';

  @override
  String get noReasonProvided => 'No reason provided';

  @override
  String get review => 'Review';

  @override
  String get your_complete_finished_trip =>
      'Your finished trips will appear here';

  @override
  String get your_have_not_cancelled => 'Your haven\'t cancelled any rides';

  @override
  String get no_rides_cancelled_by_driver => 'No rides cancelled by driver';

  @override
  String get carpool_text => 'No carpool rides yet';

  @override
  String get transactions => 'No transactions yet';

  @override
  String get type_amount => 'Type amount';

  @override
  String get bank_acc => 'Add an account for quick withdrawals';

  @override
  String get notification_center => 'You\'re all caught up';

  @override
  String get complete_rides_rating => 'Complete rides to start getting rated';

  @override
  String get invite_friends =>
      'Your referral history will appear here once you start inviting';

  @override
  String get account_status_complete_title => 'Complete Your Submission';

  @override
  String get account_status_complete_message =>
      'You’ve entered some information, but your account is not under review yet.\nPlease submit your details to proceed with the verification process.';

  @override
  String get profile_review_notice =>
      '*Once vehicle or document information is updated, the driver profile will move into a review state. During this review period, the driver may have restricted or no access to accept new rides until the information is approved.';

  @override
  String profileYearTooOld(Object year) {
    return 'Year cannot be older than $year';
  }

  @override
  String get profileYearFuture => 'Year cannot be in the future';

  @override
  String get no_changes => 'No changes to update.';

  @override
  String get name_no_numbers => 'Name cannot contain numbers';

  @override
  String get name_invalid_characters => 'Name contains invalid characters';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get delete_notification => 'Delete Notification';

  @override
  String get delete_notification_confirmation =>
      'Are you sure you want to delete this notification?';

  @override
  String get delete_all_notifications => 'Delete All Notifications';

  @override
  String get delete_all_notifications_confirmation =>
      'Are you sure you want to delete all notifications?';

  @override
  String get notification_deleted_success =>
      'Notification deleted successfully.';

  @override
  String get notifications_deleted_success =>
      'All notifications deleted successfully.';

  @override
  String get confirm => 'Confirm';

  @override
  String get and => 'and';

  @override
  String get search => 'Search';

  @override
  String get onboarding_title_1 => 'Book a Ride Easily';

  @override
  String get onboarding_subtitle_1 =>
      'Find and book rides near you in seconds.';

  @override
  String get onboarding_title_2 => 'Track Your Driver';

  @override
  String get onboarding_subtitle_2 =>
      'Real-time tracking from pickup to drop-off.';

  @override
  String get onboarding_title_3 => 'Safe & Secure';

  @override
  String get onboarding_subtitle_3 => 'Your safety is our top priority.';

  @override
  String get get_started => 'Get Started';

  @override
  String get start_ride => 'Start Ride';

  @override
  String get welcome_back => 'Welcome!';

  @override
  String get login_subtitle => 'Please enter your phone number to log in.';

  @override
  String get phone_number => 'Phone Number';

  @override
  String get enter_phone_number => 'Enter your phone number';

  @override
  String get add_phone_number => 'Add phone number';

  @override
  String get continue_with_phone => 'Continue With Phone Number';

  @override
  String get no_account_prompt => 'Don\'t have an account? Sign Up';

  @override
  String get phone_required => 'Phone number is required';

  @override
  String get phone_invalid => 'Phone number must be valid';

  @override
  String get verification => 'Verification';

  @override
  String otp_subtitle(Object number) {
    return 'Enter the OTP code sent to $number';
  }

  @override
  String get enter_otp => 'Enter OTP';

  @override
  String get accept => 'Accept';

  @override
  String get view_detail => 'View Details';

  @override
  String get otp_required => 'Please enter the OTP to proceed';

  @override
  String get did_not_receive_code => 'Didn’t receive the code?';

  @override
  String get resend_now => 'Resend Now';

  @override
  String get number_verified => 'Number Verified';

  @override
  String get number_verified_message =>
      'Your phone number has been verified successfully!';

  @override
  String get verify => 'Verify';

  @override
  String get accepted => 'Accepted';

  @override
  String get account_under_review_title => 'Account Under Review';

  @override
  String get account_under_review_message =>
      'Your driver account is currently under review. You\'ll be able to access the app once your profile is approved.';

  @override
  String get account_review_notify_message =>
      'You\'ll be notified after the review is completed.';

  @override
  String get updates_visit_label => 'For updates, visit:';

  @override
  String get account_not_approved_title => 'Account Not Approved';

  @override
  String get subscription_status => '';

  @override
  String get account_not_approved_message =>
      'Your driver account was not approved at this time. To reapply, please complete the onboarding process again via the web portal.';

  @override
  String get reapply_at_label => 'Reapply at:';

  @override
  String get forgot_password => 'Forgot Password';

  @override
  String get forgot_password_subtitle =>
      'Enter your email address to reset your password.';

  @override
  String get back_to_login => 'Back to Login';

  @override
  String get create_profile => 'Create Profile';

  @override
  String get signup_subtitle => 'Please enter your details to sign up.';

  @override
  String get sign_up => 'Sign Up';

  @override
  String get already_have_account => 'Already have an account? Sign In';

  @override
  String get by_registering => 'By registering, you accept our';

  @override
  String get full_name => 'Full Name';

  @override
  String get enter_full_name => 'Enter your full name';

  @override
  String get full_name_required => 'Full name is required';

  @override
  String get email_address => 'Email Address';

  @override
  String get in_app => 'In-app';

  @override
  String get enter_email => 'Enter your email address';

  @override
  String get upload_profile_picture => 'Upload Profile Picture';

  @override
  String get optional => '(Optional)';

  @override
  String get my_profile => 'My Profile';

  @override
  String get edit_profile => 'Edit Profile';

  @override
  String get logout => 'Logout';

  @override
  String get total_time => 'Total Time';

  @override
  String get total_distance => 'Total Distance';

  @override
  String get min => 'mins';

  @override
  String get sec => 'sec.';

  @override
  String get hour => 'hour';

  @override
  String get passenger => 'Passenger';

  @override
  String get detail => 'Detail';

  @override
  String get avg_time => 'Avg Time';

  @override
  String get total_amount => 'Total Amount';

  @override
  String get pickup_location => 'Pickup Location';

  @override
  String get stop => 'Stop';

  @override
  String get dropoff_location => 'Drop-off Location';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get subtitle_logout => 'Are you sure you want to logout your account?';

  @override
  String get where_to => 'Where to?';

  @override
  String get logoutDialogTitle => 'Confirm Logout';

  @override
  String get profileEditSuccess => 'Profile Edit Successfully';

  @override
  String get profile_update_subtitle => 'Profile has been updated successfully';

  @override
  String get location => 'Location';

  @override
  String get current_location => 'Current Location';

  @override
  String get pickup_details => 'Pickup Details';

  @override
  String get special_request => 'Special Request';

  @override
  String get set_pickup_location => 'Set Pickup Location';

  @override
  String get set_dropoff_location => 'Set Drop-off Location';

  @override
  String get confirm_location => 'Confirm Location';

  @override
  String get luxury => 'Luxury';

  @override
  String get economy => 'Economy';

  @override
  String get premium => 'Premium';

  @override
  String get select_ride => 'Select Ride';

  @override
  String get estimated_time => 'Estimated Time';

  @override
  String get estimated_fare => 'Estimated Fare';

  @override
  String get finding_driver => 'Finding your driver...';

  @override
  String get driver_on_the_way => 'Driver is on the way';

  @override
  String get arrived => 'Arrived';

  @override
  String get driver_arrived => 'Driver has arrived';

  @override
  String get ride_started => 'Ride Started';

  @override
  String get ride_in_progress => 'Ride in Progress!';

  @override
  String get reached_destination => 'You have reached your destination!';

  @override
  String get reached_pickup_point => 'You have reached the\npickup point!';

  @override
  String get ride_completed => 'Ride Completed';

  @override
  String get session_expired => 'Session Expired';

  @override
  String get cancel_ride => 'Cancel Ride';

  @override
  String get cancel_carpool => 'Cancel Carpool';

  @override
  String get cancel_ride_confirmation =>
      'Are you sure you want to cancel this ride?';

  @override
  String get driver_profile => 'Driver Profile';

  @override
  String get call_driver => 'Call Driver';

  @override
  String get chat_with_driver => 'Chat with Driver';

  @override
  String get payment_method => 'Payment Method';

  @override
  String get wallet => 'Wallet';

  @override
  String get add_payment_method => 'Add Payment Method';

  @override
  String get add_card => 'Add Card';

  @override
  String get card_number => 'Card Number';

  @override
  String get expiry_date => 'Expiry Date';

  @override
  String get cvv => 'CVV';

  @override
  String get card_holder_name => 'Card Holder Name';

  @override
  String get add_account => 'Add Account';

  @override
  String get delete_account => 'Delete Account';

  @override
  String get ride_history => 'Ride History';

  @override
  String get no_rides_found => 'No rides found';

  @override
  String get rate_your_ride => 'Rate Your Ride';

  @override
  String get leave_feedback => 'Leave Feedback';

  @override
  String get add_tip => 'Add Tip';

  @override
  String get submit => 'Submit';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy_policy => 'Privacy Policy';

  @override
  String get terms_conditions => 'Terms & Conditions';

  @override
  String get continue_label => 'Continue';

  @override
  String get service_region_title => 'Outside Service Region';

  @override
  String service_region_message(Object regionName) {
    return 'You are not in $regionName right now. Please choose a location within $regionName to continue.';
  }

  @override
  String get service_region_logout => 'Logout';

  @override
  String get no_vehicle_types_available => 'No vehicle types available.';

  @override
  String get support => 'Support';

  @override
  String get help_center => 'Help Center';

  @override
  String get something_went_wrong => 'Something went wrong. Please try again.';

  @override
  String get no_internet => 'No internet connection';

  @override
  String get try_again => 'Try Again';

  @override
  String get home => 'Home';

  @override
  String get ride_request => 'Ride Request';

  @override
  String get ride_request_unavailable =>
      'This ride request is no longer available.';

  @override
  String get ride_request_taken_toast =>
      'That ride was already taken by another driver.';

  @override
  String get ride_request_expired_toast => 'That ride request expired.';

  @override
  String ride_request_dispatch_radius(Object radius, Object unit) {
    return '$radius $unit away';
  }

  @override
  String get ride_request_offline_toast =>
      'You are offline right now. Please go online again to view ride requests.';

  @override
  String get ride_request_refreshing_queue_label => 'Refreshing live queue';

  @override
  String get ride_request_syncing_queue_label => 'Syncing queue';

  @override
  String ride_request_updated_label(Object timeAgo) {
    return 'Updated $timeAgo';
  }

  @override
  String ride_request_live_title(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# live requests',
      one: '# live request',
      zero: 'Queue is clear',
    );
    return '$_temp0';
  }

  @override
  String get ride_request_live_subtitle =>
      'Newest requests stay pinned at the top so the latest ride is always first.';

  @override
  String get ride_request_ready_subtitle =>
      'You are online and ready. We will keep refreshing this queue every few seconds.';

  @override
  String get ride_request_go_online_subtitle =>
      'Go online from the dashboard to start receiving ride requests.';

  @override
  String get ride_request_status_live_sync => 'Live sync';

  @override
  String get ride_request_status_newest_first => 'Newest first';

  @override
  String get ride_request_driver_online => 'Driver is online';

  @override
  String get ride_request_driver_offline => 'Driver is offline';

  @override
  String get ride_request_empty_title_online => 'No pending requests right now';

  @override
  String get ride_request_empty_title_offline => 'You are offline right now';

  @override
  String get ride_request_empty_subtitle_online =>
      'Pull to refresh or keep this screen open. New ride requests will slide in here automatically.';

  @override
  String get ride_request_empty_subtitle_offline =>
      'Go back to the dashboard and switch yourself online to start receiving new requests.';

  @override
  String get date => 'Date';

  @override
  String get on => 'ON';

  @override
  String get wait_timer => 'Wait timer';

  @override
  String get off => 'OFF';

  @override
  String get hello => 'Hello';

  @override
  String get account_name => 'Account Info';

  @override
  String get type => 'Type';

  @override
  String get status => 'Status';

  @override
  String get amount => 'Amount';

  @override
  String get available_balance => 'Available Balance';

  @override
  String get no_transactions_found => 'No transaction found';

  @override
  String get withdraw_funds => 'Withdraw Funds';

  @override
  String get total_earnings => 'Total Earnings';

  @override
  String get enter_amount => 'Enter Amount';

  @override
  String get language => 'Language';

  @override
  String get saved_locations => 'Saved Locations';

  @override
  String get add_location => 'Add Location';

  @override
  String get office => 'Office';

  @override
  String get work => 'Work';

  @override
  String get gym => 'Gym';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get all => 'All';

  @override
  String get paid => 'Paid';

  @override
  String get withdrawn => 'Withdrawn';

  @override
  String get location_permission_title => 'Location Permission';

  @override
  String get permission_denied_mesg =>
      'This app needs your location to show nearby rides and provide accurate pickup/dropoff services. Please grant location permission to continue.';

  @override
  String get location_permission_required_title =>
      'Location Permission Required';

  @override
  String get permanently_denied_mesg =>
      'Location permission has been permanently denied. Please enable it in your device settings to use location-based features.';

  @override
  String get location_services_disabled_title => 'Location Services Disabled';

  @override
  String get location_services_disabled_mesg =>
      'Location services are currently disabled on your device. Please enable them in your device settings to continue.';

  @override
  String get ride_location_required_title => 'Turn On GPS to Continue the Ride';

  @override
  String get ride_location_required_message =>
      'Location services must stay enabled during an active ride. Turn GPS back on to continue using the app and complete the trip.';

  @override
  String get failed_to_request => 'Failed to request location permission';

  @override
  String get error_occurred => 'An error occurred. Please try again.';

  @override
  String get open_settings => 'Settings';

  @override
  String get withdrawal_now => 'Withdraw';

  @override
  String get themePreferences => 'Theme Preferences';

  @override
  String get themeAutomatic => 'Automatic (Day & Night Mode)';

  @override
  String get themeAutomaticSubtitle =>
      'Light theme during the day and dark theme at night.';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDarkSubtitle => 'Always use dark mode';

  @override
  String get themeLight => 'Light';

  @override
  String get themeLightSubtitle => 'Always use light mode';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get customer_reviews => 'Customer reviews';

  @override
  String get reviews => 'Reviews';

  @override
  String get cancelling => 'Cancelling...';

  @override
  String get see_less => 'See Less';

  @override
  String get see_more => 'See More';

  @override
  String get id => 'ID';

  @override
  String get invite_drawer => 'Invite Friends';

  @override
  String get start_chat_fallback => 'There are no new messages yet';

  @override
  String get copy_link => 'Copy Link';

  @override
  String get your_ride_has_been => 'Your ride has been completed successfully';

  @override
  String get whenStartRide => 'When will you start this ride?';

  @override
  String get chooseStartTime => 'Choose a specific time to start the ride.';

  @override
  String get invitation_link => 'Invitation Link';

  @override
  String get rideStartTimeSeats => 'Ride Start Time & Seats';

  @override
  String star_count(Object star, Object count) {
    return '$star  ($count)';
  }

  @override
  String get search_address => 'Search Address';

  @override
  String get we_couldnot_found => 'We couldn\'t find any matching addresses';

  @override
  String get use_this_address => 'Use this address';

  @override
  String get language_updated_title => 'Language Updated!';

  @override
  String get under_review_subtitle =>
      'Updating these details will put your account back under review. You won\'t be able to accept rides until you are re-approved. Do you want to continue?';

  @override
  String get passenger_detail => 'Passenger Details';

  @override
  String get carpool_ride => 'Carpool';

  @override
  String get enter_last_name => 'Enter last name';

  @override
  String get enter_first_name => 'Enter first name';

  @override
  String get first_name => 'First name';

  @override
  String get last_name => 'Last name';

  @override
  String get enter_street => 'Enter street';

  @override
  String get street => 'Street';

  @override
  String get enter_city => 'Enter city';

  @override
  String get city => 'City';

  @override
  String get enter_state => 'Enter state';

  @override
  String get state => 'State';

  @override
  String get going_back_under_review =>
      'Going back will put you in under review. Are you sure you want to go back? You can update these details if you want.';

  @override
  String get language_updated_message =>
      'Tu idioma se ha actualizado correctamente.';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get invite_friend => 'Invite Friends';

  @override
  String get driverAccountNotCreatedWeb =>
      'Your driver account is not created yet. Please register on the website first.';

  @override
  String get driverAccountNotFound => 'Driver Account Not Found';

  @override
  String get attach_bank_account => 'Attach your bank account';

  @override
  String get debit => 'Debit';

  @override
  String get viewPassenger => 'View Passengers';

  @override
  String get credit => 'Credit';

  @override
  String get no_rides => 'No rides available';

  @override
  String get by_user => 'By User';

  @override
  String get by_driver => 'By Driver';

  @override
  String get no_bank_accounts_found => 'No bank accounts found';

  @override
  String get attached_bank_accounts => 'Attached Bank Accounts';

  @override
  String get select_bank => 'Select Bank';

  @override
  String get platform_fee_deducted =>
      'A 3% platform fee will be deducted from your withdrawal amount.';

  @override
  String get delete_bank_account => 'Delete Bank Account';

  @override
  String bank_delete_confirmation(Object bankTitle, Object last4) {
    return 'Are you sure you want to delete $bankTitle ending in $last4?';
  }

  @override
  String get bank_attach_failed => 'Failed to attach bank account.';

  @override
  String get bank_account_attached_success =>
      'Bank account attached successfully.';

  @override
  String get bank_account_deleted_success =>
      'Bank account deleted successfully.';

  @override
  String get attach_bank_account_description =>
      'Add a US bank account. We create a Stripe bank token and send it to the backend.';

  @override
  String get account_holder_name => 'Account holder name';

  @override
  String get account_holder_name_required => 'Account holder name is required';

  @override
  String get routing_number => 'Routing number';

  @override
  String get routing_number_required => 'Routing number is required';

  @override
  String get routing_number_must_be_9_digits =>
      'Routing number must be 9 digits';

  @override
  String get account_number => 'Account number';

  @override
  String get account_number_required => 'Account number is required';

  @override
  String get account_number_must_be_4_to_17_digits =>
      'Account number must be 4 to 17 digits';

  @override
  String get country_us => 'Country (US)';

  @override
  String get country_required => 'Country is required';

  @override
  String get currency_usd => 'Currency (usd)';

  @override
  String get currency_required => 'Currency is required';

  @override
  String get account_holder_type => 'Account holder type';

  @override
  String get individual => 'Individual';

  @override
  String get company => 'Company';

  @override
  String get add_bank_account => 'Attached Bank Account';

  @override
  String get driver_onboarding_title =>
      'Drivers are onboarded via the web portal.';

  @override
  String get driver_onboarding_message =>
      'If your number is already registered, you\'ll receive an OTP to continue.';

  @override
  String get driver_onboarding_visit_label =>
      'Registration is Available Online';

  @override
  String get click_here => 'Click Here';

  @override
  String get account_approved_title =>
      'Your account has been approved successfully!';

  @override
  String get manu_year => 'Manufacture Year';

  @override
  String get account_approved_message =>
      'To start using the services, please purchase a subscription plan. Once your subscription is active, you’ll be able to access all features.';

  @override
  String get subscription_note =>
      'Note: To buy a subscription, please visit the website using the link below:';

  @override
  String get subscription_status_title => 'Subscription Status';

  @override
  String get profileRegistrationMustBeUnique =>
      'Registration number must be unique';

  @override
  String subscription_status_message(Object status) {
    return 'Your subscription $status, please renew';
  }

  @override
  String get subscription_renew_note =>
      'To renew your subscription, please visit the website below:';

  @override
  String get profileVinMustBeUnique => 'VIN must be unique';

  @override
  String get delete_account_otp_prefix => 'We will send a 6-digit code to';

  @override
  String get delete_account_data_warning =>
      'Your data will be removed from our database permanently.';

  @override
  String get send_otp => 'Send OTP';

  @override
  String get valid_amount => 'Please enter a valid amount';

  @override
  String get amount_must_be_greater_than_0 => 'Amount must be greater than 0';

  @override
  String get insufficient_balance => 'Insufficient balance';

  @override
  String get max_2_decimal_places_allowed => 'Maximum 2 decimal places allowed';

  @override
  String get profileMyProfile => 'My Profile';

  @override
  String get profilePersonalInformation => 'Personal Information';

  @override
  String get profileVehicleDetails => 'Vehicle Details';

  @override
  String get profileDrivingLicense => 'Driving License';

  @override
  String get profileVehicleRegistration => 'Vehicle Registration';

  @override
  String get profileInsuranceInformation => 'Insurance Information';

  @override
  String get profileUnableToLoad => 'Unable to load profile.';

  @override
  String get profileRetry => 'Retry';

  @override
  String get profileChooseFromGallery => 'Choose from gallery';

  @override
  String get profileTakePhoto => 'Take photo';

  @override
  String get profileEditPersonalInformation => 'Edit Personal Information';

  @override
  String get profileChangeProfilePicture => 'Change Profile Picture';

  @override
  String get profilePictureRequired => 'Profile picture is required';

  @override
  String get profileFullName => 'Full Name';

  @override
  String get rideRequestsWaiting => 'Ride requests are waiting';

  @override
  String get driverOnlineActive =>
      'You are live and listening for the next ride';

  @override
  String get driverGoOnline => 'Go online to start receiving ride requests';

  @override
  String get vehicleMake => 'Make';

  @override
  String get vehicleModel => 'Model';

  @override
  String get vehicleRegistration => 'Registration';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get camera_permission_title => 'Camera Permission';

  @override
  String get camera_permission_subtitle =>
      'Camera permission is required to continue';

  @override
  String get profileEnterFullName => 'Enter full name';

  @override
  String get profileEmailAddress => 'Email Address';

  @override
  String get profileEnterEmailAddress => 'Enter email address';

  @override
  String get profileAddress => 'Address';

  @override
  String get profileEnterAddress => 'Enter address';

  @override
  String get profileStreet => 'Street';

  @override
  String get profileEnterStreet => 'Enter street address';

  @override
  String get profileCity => 'City';

  @override
  String get profileEnterCity => 'Enter city';

  @override
  String get profileState => 'State';

  @override
  String get profileEnterState => 'Enter state';

  @override
  String get profilePhoneNumber => 'Phone Number';

  @override
  String get profilePhoneNumberHint => 'Phone number';

  @override
  String get profileUpdate => 'Update';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get profileEditVehicleDetails => 'Edit Vehicle Details';

  @override
  String get profileVehicleMake => 'Make';

  @override
  String get profileVehicleModel => 'Model';

  @override
  String get profileVehicleColor => 'Color';

  @override
  String get profileYear => 'Year Of Manufacture';

  @override
  String get profileVin => 'Vehicle Identification Number';

  @override
  String get profileLicensePlate => 'Number Plate';

  @override
  String get profileRegistrationNumber => 'Registration Number';

  @override
  String get profileRegionOfRegistration => 'State/Region Of Registration';

  @override
  String get profileRegistrationExpiry => 'Registration Expiry Date';

  @override
  String get profileVehicleType => 'Vehicle Type';

  @override
  String get profileVehicleUpdatedSuccessfully =>
      'Vehicle details submitted for approval';

  @override
  String get unable_to_get => 'Unable to get your current location';

  @override
  String get chat_no_messages_yet => 'No new messages yet';

  @override
  String get profileDataNotLoaded => 'Profile data is not loaded yet.';

  @override
  String get profileNoChanges => 'No changes to update.';

  @override
  String get profileFieldRequired => 'This field is required';

  @override
  String get profileVinInvalidLength => 'VIN must be exactly 17 characters';

  @override
  String get profileVinInvalidFormat =>
      'Enter a valid VIN (letters and numbers, excluding I, O, and Q)';

  @override
  String get profileNumberPlateInvalid =>
      'Number plate must be 1 to 7 uppercase letters or numbers';

  @override
  String get profileRegistrationNumberInvalid =>
      'Registration number must be 1 to 8 uppercase letters or numbers';

  @override
  String get profileEnterValidYear => 'Enter a valid year';

  @override
  String get profileYearRange => 'Year should be between 1900 and 2100';

  @override
  String get profileEditDriverLicense => 'Edit Driver License';

  @override
  String get profileLicenseUpdatedSuccessfully =>
      'License updated successfully';

  @override
  String get profileEditInsurance => 'Edit Insurance Information';

  @override
  String get profileInsuranceUpdatedSuccessfully =>
      'Insurance updated successfully';

  @override
  String get profileEditVehicleRegistration => 'Edit Vehicle Registration';

  @override
  String get profileVehicleRegistrationUpdatedSuccessfully =>
      'Vehicle registration updated successfully';

  @override
  String get profileUploadFrontImage => 'Upload Front Image';

  @override
  String get profileUploadBackImage => 'Upload Back Image';

  @override
  String get profileUploadDocumentHint =>
      'Upload document (JPG/PNG up to 20MB)';

  @override
  String get profileExpiryDate => 'Expiry Date';

  @override
  String get profileLicenseNumber => 'License Number';

  @override
  String get profileEnterLicenseNumber => 'Enter license number';

  @override
  String get profileFrontImageRequired => 'Front image is required.';

  @override
  String get profileBackImageRequired => 'Back image is required.';

  @override
  String get profileUnableToPrepareFrontBack =>
      'Unable to prepare front and back images. Please reselect both images and try again.';

  @override
  String get profileUnableToPrepareFront =>
      'Unable to prepare front image. Please reselect and try again.';

  @override
  String get profileUnableToPrepareInsurance =>
      'Unable to prepare insurance image. Please reselect and try again.';

  @override
  String profileImageTooLarge(Object size) {
    return 'Image size exceeds $size MB. Please select a smaller file.';
  }

  @override
  String get profileImageInvalidType =>
      'Invalid file type. Only JPG and PNG are allowed.';

  @override
  String get image_selection_failed =>
      'Image selection failed. Please try again.';

  @override
  String map_load_error(Object error) {
    return 'Map load error: $error';
  }

  @override
  String get no_reviews_found => 'No reviews available yet.';

  @override
  String get profileNoInternetConnection =>
      'No internet connection. Please check your network and try again.';

  @override
  String get give_rating => 'Give Rating to User';

  @override
  String get subtitle_dialgue =>
      'Your report has been submitted We\'ll investigate the issue!';

  @override
  String get report_submitted => 'Report Submitted';

  @override
  String get recent_ride => 'Recent rides';

  @override
  String get rate_passenger => 'Rate Your Passenger';

  @override
  String get your_rating => 'Your Rating';

  @override
  String get hint_description => 'Description';

  @override
  String get reason => 'Reason';

  @override
  String get report_user => 'Report User';

  @override
  String get chat_message_hint => 'Message';

  @override
  String get chat_block => 'Block';

  @override
  String get chat_report => 'Report';

  @override
  String get report_reason_unprofessional => 'Unprofessional Behavior';

  @override
  String get report_reason_poor_communication => 'Poor Communication';

  @override
  String get report_reason_fake_account => 'Fake or Impersonating Account';

  @override
  String get report_reason_harassment => 'Harassment or Bullying';

  @override
  String get report_reason_abuse => 'Abuse or Misconduct';

  @override
  String get report_reason_violation_policies => 'Violation Policies';

  @override
  String get block_user => 'Block User';

  @override
  String get block_user_confirmation =>
      'Are you sure you want to block this user?';

  @override
  String get don_t_block => 'Don\'t Block';

  @override
  String get block_now => 'Block Now';

  @override
  String get we_appreciate_issue =>
      'We appreciate your feedback. Please provide details & We\'ll investigate the issue.';

  @override
  String get your_passenger_feedback =>
      'Your feedback helps us maintain a safe and respectful community for everyone.';

  @override
  String get miles => 'miles';

  @override
  String get selectStartTime => 'Select start time';

  @override
  String get ride_date_yesterday => 'Yesterday';

  @override
  String get selectTime => 'Starts In';

  @override
  String get select_time_valid => 'Please select a time before continuing';

  @override
  String get ride_date_today => 'Today';

  @override
  String get selectFutureTime => 'Please select a future time';

  @override
  String get howManyPassengers =>
      'How many passengers can you take on this ride?';

  @override
  String get numberPassengers => 'Number of Passengers';

  @override
  String get vehicleSeatLimit =>
      '* You can only select seats based on your registered vehicle capacity.';

  @override
  String get continueSearch => 'Continue to Search';

  @override
  String get minimumSeatRequired => 'Seat should be minimum 1';

  @override
  String get start_time => 'Ride Start Time';

  @override
  String get ride_time => 'Ride Time';

  @override
  String get start_time_within_hour =>
      'Please select a start time within 1 hour from now.';

  @override
  String get unable_to_create_carpool_route =>
      'Unable to create carpool route.';

  @override
  String get ride_progress => 'Ride Progress';

  @override
  String ride_progress_stop(int index) {
    return 'Stop $index';
  }

  @override
  String get ride_progress_no_route => 'No route data';

  @override
  String get start_time_label => 'Start Time';

  @override
  String get available_seats => 'Available Seats';

  @override
  String get total_distance_label => 'Total Distance';

  @override
  String get accept_one_passenger_hint =>
      'Accept at least one passenger to start the ride.';

  @override
  String arrive_at_stop(int index) {
    return 'Arrive at Stop $index';
  }

  @override
  String get drop_off_passengers => 'Drop Off Passengers';

  @override
  String get ssn => 'Social Security Number';

  @override
  String get enter_destination => 'Enter Destination';

  @override
  String get select_both_locations => 'Please select both locations';

  @override
  String get rate_all_passengers_or_skip =>
      'Please rate all passengers or tap Skip.';

  @override
  String get give_rating_users => 'Give Rating to Users';

  @override
  String get submitting => 'Submitting...';

  @override
  String get rate_your_passengers => 'Rate Your Passengers';

  @override
  String get no_passengers_to_rate => 'No passengers available to rate.';

  @override
  String passenger_number(int index) {
    return 'Passenger $index';
  }

  @override
  String get selected_location_label => 'Selected Location';

  @override
  String get search_place_hint => 'Search for a place...';

  @override
  String get no_new_notifications => 'No new notifications!';

  @override
  String get missing_carpool_id => 'Missing carpool ID';

  @override
  String get unable_to_go_online_title => 'Unable to Go Online';

  @override
  String get fetching_location => 'Fetching location...';

  @override
  String get current_location_available => 'Current location available';

  @override
  String get unable_to_fetch_location => 'Unable to fetch location';

  @override
  String get carpool_promo_subtitle =>
      'Earn more by sharing your route with passengers heading your way';

  @override
  String get carpool_start_button => 'Start Carpool Ride';

  @override
  String get carpool_online_before_start =>
      'Go online before starting a carpool ride';

  @override
  String get normal_online_before_start => 'Go online before starting a ride';

  @override
  String get unable_to_submit => 'Unable to submit feedback';

  @override
  String get link_copied => 'Link copied!';

  @override
  String get stars => 'stars';

  @override
  String get unable_to_submit_rating => 'Unable to submit rating';

  @override
  String get please_select_rating => 'Please select rating';

  @override
  String get add_stops_title => 'Add Stops for Carpool Ride';

  @override
  String get ride_start_time => 'Ride Start Time and Seats';

  @override
  String get list_of_request => 'List of Requests';

  @override
  String get search_carpool_ride => 'Search Carpool Ride';

  @override
  String get add_stops_subtitle =>
      'Add stops along your route to accept carpool passengers easily.';

  @override
  String stop_title(int index) {
    return 'Stop $index';
  }

  @override
  String get starting_point_suffix => ' (Starting Point)';

  @override
  String get final_destination_suffix => ' (Final Destination)';

  @override
  String get tap_to_select_location => 'Tap to select location';

  @override
  String get add_stops => 'Add Stops';

  @override
  String get save_stops_continue => 'Save Stops & Continue';

  @override
  String get add_stop_warning =>
      'Please add at least one stop before continuing.';

  @override
  String get carpool_requests_title => 'Carpool Requests';

  @override
  String carpool_requests_counts(int pending, int accepted) {
    return 'Pending: $pending | Accepted: $accepted';
  }

  @override
  String get carpool_missing_id =>
      'Missing carpool ID. Go back and create a route again.';

  @override
  String get carpool_pending_requests => 'Pending Requests';

  @override
  String get carpool_no_pending => 'No pending requests right now.';

  @override
  String get carpool_accepted_passengers => 'Accepted Passengers';

  @override
  String get carpool_no_accepted => 'No accepted passengers yet.';

  @override
  String get carpool_continue_progress => 'Continue to Ride Progress';

  @override
  String get carpool_back_to_search => 'Back to Search';

  @override
  String get no_of_passengers => 'No of Passengers';

  @override
  String get reject => 'Reject';

  @override
  String get otp_verified => 'OTP Verified';

  @override
  String get booking_id_missing => 'Missing booking ID for this request.';

  @override
  String request_action_failed(Object action) {
    return 'Unable to $action request.';
  }

  @override
  String get request_accept_success => 'Passenger accepted successfully.';

  @override
  String get request_reject_success => 'Passenger rejected successfully.';

  @override
  String get search_carpool_title => 'Searching Carpool Requests';

  @override
  String get starting_point => 'Starting Point';

  @override
  String get destination => 'Destination';

  @override
  String stop_label(int index) {
    return 'Stop $index';
  }

  @override
  String get ride_start_time_label => 'Ride Start Time';

  @override
  String get available_seats_label => 'Available Seats';

  @override
  String requests_found(int count) {
    return '$count Requests Found';
  }

  @override
  String view_requests(int count) {
    return 'View Requests ($count)';
  }

  @override
  String get go_to_ride_progress => 'Go to Ride Progress';

  @override
  String get unable_cancel_carpool => 'Unable to cancel carpool.';

  @override
  String get pickup_verification_title => 'Pickup Verification';

  @override
  String get enter_otp_to_verify => 'Enter the OTP code to verify your ride';

  @override
  String otp_length_error(int length) {
    return 'Please enter a valid $length-digit OTP.';
  }

  @override
  String get otp_invalid_message => 'Invalid OTP. Please check and try again.';

  @override
  String get today_label => 'Today';

  @override
  String get no_incoming => 'No incoming rides at the moment';

  @override
  String get yesterday_label => 'Yesterday';

  @override
  String get passenger_pick_success => 'Passenger picked successfully.';

  @override
  String get passenger_pick_failed => 'Unable to pick passenger.';

  @override
  String get ride_end_success => 'Ride ended successfully.';

  @override
  String get ride_end_failed => 'Unable to end ride.';

  @override
  String get passenger_removed_success => 'Passenger removed successfully.';

  @override
  String get passenger_removed_failed => 'Unable to remove passenger.';

  @override
  String get removing => 'Removing...';

  @override
  String get remove_passenger => 'Remove Passenger';

  @override
  String get passenger_dropped => 'Passenger Dropped';

  @override
  String get dropping => 'Dropping...';

  @override
  String get picking => 'Picking...';

  @override
  String get drop_passenger => 'Drop Passenger';

  @override
  String get pick_passenger => 'Pick Passenger';

  @override
  String get success_profile_approved_title => 'Profile Approved';

  @override
  String get success_profile_approved_message =>
      'Your profile has been approved successfully.';

  @override
  String get success_account_deleted_title => 'Account Deleted!';

  @override
  String get success_account_deleted_message =>
      'Your account has been deleted successfully.';

  @override
  String get success_funds_added_title => 'Funds Added!';

  @override
  String get success_funds_added_message =>
      'Your funds have been added successfully.';

  @override
  String get success_feedback_title => 'We appreciate your Feedback!';

  @override
  String get success_feedback_message => 'Your review has been submitted.';

  @override
  String get invalid_otp => 'Invalid OTP code. Please try again.';

  @override
  String get verify_delete_account => 'Verify & Delete Account';

  @override
  String get feedback_subtitle =>
      'Your feedback helps us maintain a safe and respectful community for everyone.';

  @override
  String get no_internet_title => 'No Internet Connection';

  @override
  String get no_internet_subtitle =>
      'Please check your network settings and try again to continue using the app.';

  @override
  String get slow_connection_title => 'Connection Too Slow';

  @override
  String get slow_connection_subtitle =>
      'Your internet connection is too slow to use the app right now. Please check your network and try again.';

  @override
  String get slow_connection_banner =>
      'Unstable connection. Some actions may be delayed.';

  @override
  String get retry => 'Retry';

  @override
  String get notification_fallback_title => 'Notification';

  @override
  String get end_ride_confirmation => 'Are you sure you want to end this ride?';

  @override
  String get drop_passenger_confirmation =>
      'Are you sure you want to drop off this passenger?';

  @override
  String get cancel_ride_question => 'Why are you cancelling this ride?';

  @override
  String get reason_harassment => 'Passenger is harassing me';

  @override
  String get reason_not_responding => 'Passenger is not responding';

  @override
  String get reason_asked_to_cancel => 'Passenger asked me to cancel';

  @override
  String get reason_unsafe_location => 'Unsafe pickup location';

  @override
  String get reason_vehicle_issue => 'Vehicle issue';

  @override
  String get reason_other => 'Other';

  @override
  String get navigate_in_google_maps => 'Start Navigation';

  @override
  String get unable_to_open_google_maps => 'Unable to start navigation';

  @override
  String get warning => 'Warning';

  @override
  String get recommend_google_maps =>
      'Tap to start in-app turn-by-turn navigation';

  @override
  String get minimum_5_characters_required => 'Minimum 5 characters required';

  @override
  String get address_cannot_be_only_numbers => 'Address cannot be only numbers';

  @override
  String get address_invalid => 'Invalid address';

  @override
  String get confirm_stop => 'Confirm Stop';

  @override
  String get confirm_pickup => 'Confirm Pickup';

  @override
  String get confirm_dropoff => 'Confirm Dropoff';

  @override
  String get search_stop => 'Search for a Stop...';

  @override
  String get search_pickup => 'Search for a Pickup...';

  @override
  String get search_dropoff => 'Search for a Drop-off...';

  @override
  String get navigate_to_destination => 'Start Navigation';

  @override
  String get navigation_route_calculating => 'Calculating route...';

  @override
  String get navigation_arrived => 'You have arrived at your destination!';

  @override
  String get navigation_route_failed =>
      'Failed to calculate route. Please try again.';

  @override
  String get only_florida_addresses_supported =>
      'Only Florida (FL) addresses are supported';

  @override
  String get regular_balance => 'Cash Balance';

  @override
  String get rewarded_balance => 'Rewarded Balance';

  @override
  String get regular => 'Regular';

  @override
  String get rewarded => 'Rewarded';

  @override
  String get referral_drawer => 'My Driver Code';

  @override
  String get referral_title => 'My Driver Code';

  @override
  String referral_explainer(Object bonus) {
    return 'Show this code to new riders to claim a $bonus reward bonus.';
  }

  @override
  String get referral_paused => 'Referral codes are paused right now.';

  @override
  String get referral_history => 'Referral history';

  @override
  String get referral_rider_fallback => 'Rider';

  @override
  String get referral_status_saved => 'Waiting for first ride';

  @override
  String get referral_status_applied => 'Ride in progress';

  @override
  String get referral_status_completed => 'Bonus earned';

  @override
  String get referral_status_voided => 'Ride cancelled, no bonus';

  @override
  String get referral_copy_code => 'Copy code';

  @override
  String get referral_code_copied => 'Code copied';

  @override
  String get referral_share => 'Share code';

  @override
  String referral_share_message(Object code, Object discount) {
    return 'Ride with us and get $discount off your first trip. Use my code $code when you sign up.';
  }

  @override
  String get referral_stat_saved => 'Saved your code';

  @override
  String get referral_stat_applied => 'Ride in progress';

  @override
  String get referral_stat_completed => 'Completed';

  @override
  String get referral_stat_earned => 'Total earned';

  @override
  String get referral_stat_voided => 'Cancelled';

  @override
  String get transaction_referral_bonus => 'Referral bonus';

  @override
  String get transaction_reward => 'Reward';

  @override
  String get address_search_failed =>
      'Unable to look up this address. You can try again or enter it manually.';

  @override
  String get address_search_outside_region =>
      'Choose an address within the service area.';

  @override
  String get address_search_retry => 'Try again';

  @override
  String get address_search_unavailable =>
      'Address search is unavailable. Enter the address manually.';

  @override
  String get address_search_incomplete =>
      'This address could not be confirmed. Enter the address manually.';
}
