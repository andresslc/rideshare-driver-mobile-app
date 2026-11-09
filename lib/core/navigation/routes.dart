/// Centralised route definitions.
///
/// Each enum value defines its [name] (used with `goNamed`)
/// and its URL [path].
enum Routes {
  root(name: 'root', path: '/'),
  login(name: 'login', path: '/login'),
  signUp(name: 'sign_up', path: '/sign-up'),
  forgotPassword(name: 'forgot_password', path: '/forgot-password'),
  verification(name: 'verification', path: '/verification'),
  accountReviewStatus(
    name: 'account_review_status',
    path: '/account-review-status',
  ),
  accountStatus(name: 'account_status', path: '/account-status'),
  success(name: 'auth_success', path: '/auth-success'),
  invitefriends(name: 'invitefriends', path: '/invitefriends'),
  driverReferral(name: 'driver_referral', path: '/driver-referral'),

  home(name: 'home', path: '/home'),
  profile(name: 'profile', path: '/profile'),
  editPersonalInformation(
    name: 'edit_personal_information',
    path: '/profile/edit-personal-information',
  ),
  editDriverLicense(
    name: 'edit_driver_license',
    path: '/profile/edit-driver-license',
  ),
  ridedetailcarpool(name: 'ride_detail_carpool', path: '/ride-detail-carpool'),

  editInsurance(name: 'edit_insurance', path: '/profile/edit-insurance'),
  editVehicleRegistration(
    name: 'edit_vehicle_registration',
    path: '/profile/edit-vehicle-registration',
  ),

  editVehicleDetails(
    name: 'edit_vehicle_details',
    path: '/profile/edit-vehicle-details',
  ),
  settings(name: 'settings', path: '/settings'),
  wallet(name: 'wallet', path: '/wallet'),
  bankAccount(name: 'bank_account', path: '/bank-account'),
  addBankAccount(name: 'add_bank_account', path: '/add-bank-account'),
  carpool(name: 'carpool', path: '/carpool'),
  passengerList(name: 'passengerList', path: '/passengerList'),
  carpoolCreate(name: 'carpool_create', path: '/carpool-create'),
  carpoolFeedback(name: 'carpool_feedback', path: '/carpool-feedback'),
  rideMap(name: 'ride_map', path: '/ride-map'),
  cards(name: 'cards', path: '/cards'),
  themePreferences(name: 'theme_preferences', path: '/theme-preferences'),
  language(name: 'language', path: '/language'),
  savedLocations(name: 'saved_locations', path: '/saved-locations'),
  //ride history
  ridehistory(name: 'ride_history', path: '/ride-history'),
  passengerdetail(name: 'passenger_detail', path: '/passenger_detail'),

  ridehistorydetail(name: 'ride_history_detail', path: '/ride-history-detail'),
  placePicker(name: 'place_picker', path: '/place-picker'),
  subscriptionStatus(
    name: 'subscription_status',
    path: '/subscriptions-status',
  ),
  rideRoom(name: 'ride_room', path: '/ride-room'),
  rideRequest(name: 'ride_request', path: '/ride-request'),
  chat(name: 'chat', path: '/chat'),
  //reviews
  reviews(name: 'reviews', path: '/reviews'),
  feedback(name: 'feedback', path: '/feedback'),
  //Delete Account

  deleteAccountOTP(name: 'delete_account_otp', path: '/delete-account-otp'),
  notificationsScreen(name: 'notifications_screen', path: '/notifications_screen'),
  deleteAccountVerify(
    name: 'delete_account_verify',
    path: '/delete-account-verify',
  );

  const Routes({required this.name, required this.path});

  final String name;
  final String path;
}
