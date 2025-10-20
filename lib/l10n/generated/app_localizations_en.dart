// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SafeDests - Driver';

  @override
  String get settings => 'Settings';

  @override
  String get appSettings => 'App Settings';

  @override
  String get language => 'App Language';

  @override
  String get chooseLanguage => 'Choose app interface language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get theme => 'App Theme';

  @override
  String get chooseTheme => 'Choose between light and dark mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemMode => 'System Default';

  @override
  String get notifications => 'Notifications';

  @override
  String get taskNotifications => 'Task Notifications';

  @override
  String get taskNotificationsDesc =>
      'Receive notifications when new tasks arrive';

  @override
  String get walletNotifications => 'Wallet Notifications';

  @override
  String get walletNotificationsDesc =>
      'Receive notifications when wallet is updated';

  @override
  String get systemNotifications => 'System Notifications';

  @override
  String get systemNotificationsDesc =>
      'Receive system notifications and updates';

  @override
  String get about => 'About App';

  @override
  String get version => 'Version';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceDesc => 'Read app terms of service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyDesc => 'Read privacy policy';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get helpSupportDesc => 'Get help and support';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsDesc => 'Reset all settings to default values';

  @override
  String get reset => 'Reset';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get resetConfirmTitle => 'Reset Settings';

  @override
  String get resetConfirmMessage =>
      'Are you sure you want to reset all settings to default values?\n\nThis action cannot be undone.';

  @override
  String get resetSuccess => 'Settings reset successfully';

  @override
  String get home => 'Home';

  @override
  String get tasks => 'Tasks';

  @override
  String get wallet => 'Wallet';

  @override
  String get profile => 'Profile';

  @override
  String welcomeDriver(String driverName) {
    return 'Welcome $driverName';
  }

  @override
  String get driver => 'Driver';

  @override
  String get dataRefreshSuccess => 'Data refreshed successfully';

  @override
  String get dataRefreshFailed => 'Failed to refresh data';

  @override
  String get taskAds => 'Task Ads';

  @override
  String get taskAdsDescription =>
      'Browse available ads and submit your offers';

  @override
  String get availableAds => 'Available Ads';

  @override
  String get myOffers => 'My Offers';

  @override
  String get acceptedOffers => 'Accepted Offers';

  @override
  String get browseAds => 'Browse Ads';

  @override
  String get notificationsComingSoon => 'Notifications screen coming soon';

  @override
  String get exitConfirmation => 'Exit Confirmation';

  @override
  String get exitConfirmMessage => 'Are you sure you want to exit the app?';

  @override
  String get exitConfirmDescription => 'The app will be closed completely.';

  @override
  String get exit => 'Exit';

  @override
  String get refreshTasks => 'Refresh Tasks';

  @override
  String get availableTasks => 'Available';

  @override
  String get currentTasks => 'Current';

  @override
  String get completedTasks => 'Completed';

  @override
  String get loadingTasks => 'Loading tasks...';

  @override
  String unexpectedError(String error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get noAvailableTasks => 'No available tasks';

  @override
  String get noAvailableTasksDescription =>
      'There are no tasks available to accept at the moment';

  @override
  String get noCurrentTasks => 'No current tasks';

  @override
  String get noCompletedTasks => 'No completed tasks';

  @override
  String get taskAcceptedSuccess => 'Task accepted successfully';

  @override
  String get taskRejected => 'Task rejected';

  @override
  String get taskStatusUpdated => 'Task status updated';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get cashWithdrawal => 'Cash Withdrawal';

  @override
  String get accountStatement => 'Account Statement';

  @override
  String get support => 'Support';

  @override
  String get withdrawalComingSoon => 'Cash withdrawal feature coming soon';

  @override
  String get statementComingSoon => 'Account statement coming soon';

  @override
  String get supportComingSoon => 'Technical support coming soon';

  @override
  String get noDriverData => 'No driver data available';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get accountInfo => 'Account Information';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get team => 'Team';

  @override
  String get vehicleSize => 'Vehicle Size';

  @override
  String get additionalData => 'Additional Data';

  @override
  String get additionalDataDescription => 'View supplementary information';

  @override
  String get systemDiagnostics => 'System Diagnostics';

  @override
  String get systemDiagnosticsDescription => 'Check app status and connections';

  @override
  String get logout => 'Logout';

  @override
  String get loggingOut => 'Logging out...';

  @override
  String get logoutConfirmation => 'Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get safeDriveApp => 'SafeDests Driver App';

  @override
  String get appDescription =>
      'An app dedicated to task management and delivery for drivers';

  @override
  String get driverStatus => 'Driver Status';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get availableForTasks => 'Available for Tasks';

  @override
  String get busy => 'Busy';

  @override
  String get setBusy => 'Set as Busy';

  @override
  String get setAvailable => 'Set as Available';

  @override
  String get name => 'Name';

  @override
  String get status => 'Status';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get notSpecified => 'Not Specified';

  @override
  String get earningsStatistics => 'Earnings Statistics';

  @override
  String get today => 'Today';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String periodSelected(String period) {
    return 'Period selected: $period';
  }

  @override
  String get earningsChart => 'Earnings Chart';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get highestEarning => 'Highest Earning';

  @override
  String get dailyAverage => 'Daily Average';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get noTransactionsYet => 'No financial transactions yet';

  @override
  String get earningsSummary => 'Earnings Summary';

  @override
  String get details => 'Details';

  @override
  String get earningsDetailsComingSoon => 'Earnings details coming soon';

  @override
  String get noEarningsData => 'No earnings data currently';

  @override
  String get thisMonth => 'This Month';

  @override
  String get totalTasks => 'Total Tasks';

  @override
  String get averageEarningPerTask => 'Average Earning Per Task';

  @override
  String get totalPeriod => 'Total Period';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get quickStats => 'Quick Stats';

  @override
  String get activeTasks => 'Active Tasks';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get recentTasks => 'Recent Tasks';

  @override
  String get viewAll => 'View All';

  @override
  String get viewAllTasks => 'View All Tasks';

  @override
  String get noTasksCurrently => 'No tasks currently';

  @override
  String taskNumber(String taskId) {
    return 'Task #$taskId';
  }

  @override
  String get pending => 'Pending';

  @override
  String get accepted => 'Accepted';

  @override
  String get pickedUp => 'Picked Up';

  @override
  String get inTransit => 'In Transit';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get days => 'day';

  @override
  String get hours => 'hour';

  @override
  String get minutes => 'minute';

  @override
  String get now => 'Now';

  @override
  String get pickupPoint => 'Pickup Point';

  @override
  String get deliveryPoint => 'Delivery Point';

  @override
  String get items => 'Items';

  @override
  String get yourEarnings => 'Your Earnings';

  @override
  String get viewDetails => 'View Details';

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String get arrivedAtPickup => 'Arrived at Pickup';

  @override
  String get startLoading => 'Start Loading';

  @override
  String get onTheWay => 'On the Way';

  @override
  String get arrivedAtDelivery => 'Arrived at Delivery';

  @override
  String get startUnloading => 'Start Unloading';

  @override
  String get completeTask => 'Complete Task';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get allTransactionsComingSoon => 'All transactions coming soon';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get noTransactionsRecorded => 'No financial transactions recorded yet';

  @override
  String get loadingTransactions => 'Loading transactions...';

  @override
  String get noTransactionsCurrently => 'No transactions currently';

  @override
  String get deposit => 'Deposit';

  @override
  String get withdrawal => 'Withdrawal';

  @override
  String get commission => 'Commission';

  @override
  String get cashDeposit => 'Cash Deposit';

  @override
  String get completed => 'Completed';

  @override
  String get failed => 'Failed';

  @override
  String get walletBalance => 'Wallet Balance';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get withdrawals => 'Withdrawals';

  @override
  String get income => 'Income';

  @override
  String get newTask => 'New Task!';

  @override
  String respondWithin(String time) {
    return 'Respond within: $time';
  }

  @override
  String get responseTimeExpired =>
      'Response time expired, task transferred to another driver';

  @override
  String from(String address) {
    return 'From: $address';
  }

  @override
  String to(String address) {
    return 'To: $address';
  }

  @override
  String get amount => 'Amount';

  @override
  String get taskAcceptedSuccessfully => 'Task accepted successfully';

  @override
  String get taskDetails => 'Task Details';

  @override
  String get taskId => 'Task ID';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get pickupAddress => 'Pickup Address';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get creationDate => 'Creation Date';

  @override
  String get notes => 'Notes';

  @override
  String get myOffer => 'My Offer';

  @override
  String get myOfferPending => 'My offer pending';

  @override
  String get myOfferAccepted => 'My offer accepted';

  @override
  String get myOfferRejected => 'My offer rejected';

  @override
  String suggestedPrice(String price) {
    return 'Suggested price: $price SAR';
  }

  @override
  String get offerDescription => 'Offer description:';

  @override
  String get netEarningsCalculation => 'Net Earnings Calculation';

  @override
  String get offerPrice => 'Offer Price';

  @override
  String get serviceCommission => 'Service Commission';

  @override
  String get vat => 'VAT';

  @override
  String get netEarnings => 'Net Earnings';

  @override
  String submittedOn(String date) {
    return 'Submitted on: $date';
  }

  @override
  String lastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String adNumber(String adId) {
    return 'Ad #$adId';
  }

  @override
  String get running => 'Running';

  @override
  String get closed => 'Closed';

  @override
  String get pickup => 'Pickup';

  @override
  String get delivery => 'Delivery';

  @override
  String get priceRange => 'Price Range';

  @override
  String get offersCount => 'Offers Count';

  @override
  String get offerAccepted => 'Offer accepted';

  @override
  String get submitOffer => 'Submit Offer';

  @override
  String get acceptTask => 'Accept Task';

  @override
  String get acceptTaskConfirm => 'Are you sure you want to accept this task?';

  @override
  String get taskAcceptFailed => 'Failed to accept task';

  @override
  String get taskHistory => 'Task History';

  @override
  String get noTaskHistory => 'No task history';

  @override
  String get addNote => 'Add Note';

  @override
  String get writeNoteHere => 'Write your note here...';

  @override
  String get attachFile => 'Attach File';

  @override
  String get adding => 'Adding...';

  @override
  String get add => 'Add';

  @override
  String get pleaseWriteNote => 'Please write a note';

  @override
  String get noteAddedSuccess => 'Note added successfully';

  @override
  String get noteAddFailed => 'Failed to add note';

  @override
  String errorAddingNote(String error) {
    return 'Error adding note: $error';
  }

  @override
  String errorSelectingFile(String error) {
    return 'Error selecting file: $error';
  }

  @override
  String errorOpeningAttachment(String error) {
    return 'Error opening attachment: $error';
  }

  @override
  String errorLoadingImage(String error) {
    return 'Error loading image: $error';
  }

  @override
  String get clickOpenToView => 'Click \"Open\" to view file';

  @override
  String get download => 'Download';

  @override
  String get open => 'Open';

  @override
  String errorDownloadingFile(String error) {
    return 'Error downloading file: $error';
  }

  @override
  String errorOpeningFile(String error) {
    return 'Error opening file: $error';
  }

  @override
  String get taskStages => 'Task Stages';

  @override
  String get assigned => 'Assigned';

  @override
  String get assignedDescription => 'Task assigned to driver';

  @override
  String get started => 'Started';

  @override
  String get startedDescription => 'Driver started executing the task';

  @override
  String get inPickupPoint => 'At Pickup Point';

  @override
  String get inPickupPointDescription => 'Driver arrived at pickup point';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingDescription => 'Loading goods';

  @override
  String get inTheWay => 'On the Way';

  @override
  String get inTheWayDescription => 'Driver on the way to delivery point';

  @override
  String get inDeliveryPoint => 'At Delivery Point';

  @override
  String get inDeliveryPointDescription => 'Driver arrived at delivery point';

  @override
  String get unloading => 'Unloading';

  @override
  String get unloadingDescription => 'Unloading goods';

  @override
  String get taskCompleted => 'Completed';

  @override
  String get taskCompletedDescription => 'Task completed successfully';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get whatsappNumber => 'WhatsApp Number';

  @override
  String get averagePerTask => 'Average Per Task';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get newNotificationsWillAppearHere =>
      'New notifications will appear here';

  @override
  String get newBadge => 'New';

  @override
  String get closeDialog => 'Close';

  @override
  String get allNotificationsMarkedAsRead => 'All notifications marked as read';

  @override
  String get failedToUpdateNotifications => 'Failed to update notifications';

  @override
  String get dayAgo => '1 day ago';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get hourAgo => '1 hour ago';

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String get minuteAgo => '1 minute ago';

  @override
  String minutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String get justNow => 'now';

  @override
  String get ago => 'ago';

  @override
  String get since => 'since';

  @override
  String get taskDetailError => 'Error fetching task details';

  @override
  String get errorTitle => 'Error';

  @override
  String get taskNotFound => 'Task not found';

  @override
  String get quickNavigation => 'Quick Navigation';

  @override
  String get pickupLocation => 'Pickup Location';

  @override
  String get deliveryLocation => 'Delivery Location';

  @override
  String get contactPersonName => 'Contact Person';

  @override
  String get openInGoogleMaps => 'Open in Google Maps';

  @override
  String get unspecifiedItem => 'Unspecified item';

  @override
  String get quantity => 'Quantity';

  @override
  String get awaitingApproval => 'Awaiting Approval';

  @override
  String get startTask => 'Start Task';

  @override
  String get arrivedAtPickupPoint => 'Arrived at Pickup Point';

  @override
  String get startLoadingGoods => 'Start Loading';

  @override
  String get onTheWayToDelivery => 'On the Way';

  @override
  String get arrivedAtDeliveryPoint => 'Arrived at Delivery Point';

  @override
  String get startUnloadingGoods => 'Start Unloading';

  @override
  String get completeTaskButton => 'Complete Task';

  @override
  String get cannotOpenGoogleMaps => 'Cannot open Google Maps';

  @override
  String get mapOpenError => 'Error opening map';

  @override
  String get confirmStatusUpdate => 'Confirm Status Update';

  @override
  String get confirmStatusUpdateMessage =>
      'Are you sure you want to update the task status to:';

  @override
  String get cannotUndoAction => 'This action cannot be undone.';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get updatingTaskStatus => 'Updating task status...';

  @override
  String get unexpectedErrorOccurred =>
      'An unexpected error occurred. Please try again.';

  @override
  String get updateSuccessful => 'Update Successful';

  @override
  String taskStatusUpdatedTo(String status) {
    return 'Task status updated to: $status';
  }

  @override
  String get okButton => 'OK';

  @override
  String get updateFailed => 'Update Failed';

  @override
  String get failedToLoadAdDetails => 'Failed to load ad details';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get adDetailsTab => 'Ad Details';

  @override
  String get submittedOffersTab => 'Submitted Offers';

  @override
  String get loadingDetails => 'Loading details...';

  @override
  String get retryButton => 'Retry';

  @override
  String get noDataToDisplay => 'No data to display';

  @override
  String get cannotViewSubmittedOffers => 'Cannot view submitted offers';

  @override
  String get mustSubmitOfferFirst =>
      'You must submit an offer first to view other offers';

  @override
  String get noOffersSubmitted => 'No offers submitted';

  @override
  String get noOffersSubmittedYet =>
      'No offers have been submitted for this ad yet';

  @override
  String get editOffer => 'Edit Offer';

  @override
  String get acceptTaskConfirmTitle => 'Accept Task';

  @override
  String get acceptTaskConfirmMessage =>
      'Are you sure you want to accept this task?';

  @override
  String get acceptButton => 'Accept';

  @override
  String get failedToAcceptTask => 'Failed to accept task';

  @override
  String get statusRunning => 'Running';

  @override
  String get statusClosed => 'Closed';

  @override
  String get taskDescription => 'Task Description';

  @override
  String fromPrice(String price) {
    return 'From $price SAR';
  }

  @override
  String toPrice(String price) {
    return 'To $price SAR';
  }

  @override
  String get commissionAndTaxInfo => 'Commission and Tax Information';

  @override
  String get vatTax => 'VAT Tax';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get proposedPrice => 'Proposed Price';

  @override
  String get description => 'Description';

  @override
  String get failedToLoadAds => 'Failed to load ads';

  @override
  String get taskAdsTitle => 'Task Ads';

  @override
  String get filterTooltip => 'Filter';

  @override
  String get availableAdsTab => 'Available Ads';

  @override
  String get myOffersTab => 'My Offers';

  @override
  String get searchInAds => 'Search in ads...';

  @override
  String get totalAds => 'Total Ads';

  @override
  String get averagePrice => 'Average Price';

  @override
  String get loadingAds => 'Loading ads...';

  @override
  String get noAvailableAds => 'No available ads';

  @override
  String get noAvailableAdsDescription =>
      'No task ads are available at the moment';

  @override
  String get filterAds => 'Filter Ads';

  @override
  String get minPrice => 'Min Price';

  @override
  String get maxPrice => 'Max Price';

  @override
  String get sortBy => 'Sort By';

  @override
  String get sortByCreationDate => 'Creation Date';

  @override
  String get sortByLowestPrice => 'Lowest Price';

  @override
  String get sortByHighestPrice => 'Highest Price';

  @override
  String get sortByOffersCount => 'Offers Count';

  @override
  String get sortOrder => 'Sort Order';

  @override
  String get descending => 'Descending';

  @override
  String get ascending => 'Ascending';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get applyFilters => 'Apply';

  @override
  String get offerUpdatedSuccessfully => 'Offer updated successfully';

  @override
  String get offerSubmittedSuccessfully => 'Offer submitted successfully';

  @override
  String get failedToSubmitOffer => 'Failed to submit offer';

  @override
  String get editOfferTitle => 'Edit Offer';

  @override
  String get submitOfferTitle => 'Submit Offer';

  @override
  String get adSummary => 'Ad Summary';

  @override
  String get priceRangeLabel => 'Price Range';

  @override
  String get proposedPriceRequired => 'Proposed Price *';

  @override
  String get enterProposedPrice => 'Enter proposed price';

  @override
  String get pleaseEnterProposedPrice => 'Please enter proposed price';

  @override
  String get pleaseEnterValidPrice => 'Please enter a valid price';

  @override
  String get priceMustBeGreaterThanZero => 'Price must be greater than zero';

  @override
  String get priceBelowMinimum => 'Price is below minimum';

  @override
  String get priceAboveMaximum => 'Price is above maximum';

  @override
  String get allowedRange => 'Allowed Range';

  @override
  String get offerDescriptionOptional => 'Offer Description (Optional)';

  @override
  String get addOfferDescription =>
      'Add a description for your offer (optional)';

  @override
  String get updateOfferButton => 'Update Offer';

  @override
  String get submitOfferButton => 'Submit Offer';

  @override
  String get unexpectedErrorTryAgain =>
      'An unexpected error occurred. Please try again.';

  @override
  String get loginError => 'Login Error';

  @override
  String get agreeButton => 'OK';

  @override
  String get welcomeToDriverApp => 'Welcome to the Driver App';

  @override
  String get emailOrUsername => 'Email or Username';

  @override
  String get enterEmailOrUsername => 'Enter your email or username';

  @override
  String get pleaseEnterEmail => 'Please enter your email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get loginButton => 'Login';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get createNewAccount => 'Create New Account';

  @override
  String get byLoggingInYouAgree => 'By logging in, you agree to';

  @override
  String get and => ' and ';

  @override
  String versionNumber(String version) {
    return 'Version $version';
  }

  @override
  String get loginErrorTitle => 'Login Error';

  @override
  String get emailOrUsernameLabel => 'Email or Username';

  @override
  String get enterEmailOrUsernameHint => 'Enter your email or username';

  @override
  String get pleaseEnterEmailError => 'Please enter email';

  @override
  String get passwordFieldLabel => 'Password';

  @override
  String get enterPasswordHint => 'Enter password';

  @override
  String get pleaseEnterPasswordError => 'Please enter password';

  @override
  String get passwordMinLengthError => 'Password must be at least 6 characters';

  @override
  String get loginButtonText => 'Login';

  @override
  String get rememberMeText => 'Remember Me';

  @override
  String get forgotPasswordText => 'Forgot Password?';

  @override
  String get dontHaveAccountText => 'Don\'t have an account?';

  @override
  String get createNewAccountText => 'Create New Account';

  @override
  String get byLoggingInYouAgreeText => 'By logging in, you agree to';

  @override
  String get termsOfServiceText => 'Terms of Service';

  @override
  String get andText => ' and ';

  @override
  String get privacyPolicyText => 'Privacy Policy';

  @override
  String get allText => 'All';

  @override
  String get supportContact => 'Contact Us';

  @override
  String get contactEmail => 'Email';

  @override
  String get contactWebsite => 'Website';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get accountInactive => 'Account Inactive';

  @override
  String get accountInactiveMessage =>
      'Your account has been deactivated. Please contact administration for more information.';

  @override
  String get accountBlocked => 'Account Blocked';

  @override
  String get accountBlockedMessage =>
      'Your account has been blocked. Please contact administration.';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountWarning => 'Warning: Delete Account';

  @override
  String get deleteAccountMessage =>
      'Are you sure you want to delete your account? This action cannot be undone and all your data will be deleted.';

  @override
  String get enterPasswordToDelete =>
      'Enter your password to confirm account deletion';

  @override
  String get typeDeleteConfirmation => 'Type \'DELETE_MY_ACCOUNT\' to confirm';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get accountDeletedSuccessfully => 'Account deleted successfully';

  @override
  String get cannotDeleteAccountWithActiveTasks =>
      'Cannot delete account with active tasks';

  @override
  String get invalidPasswordForDelete => 'Invalid password';

  @override
  String get failedToDeleteAccount => 'Failed to delete account';

  @override
  String get failedToLoadRegistrationData => 'Failed to load registration data';

  @override
  String get registrationError => 'Registration error occurred';

  @override
  String get registrationSuccess => 'Registration successful!';

  @override
  String get verificationLinkSent => 'Verification link sent to your email.';

  @override
  String get login => 'Login';

  @override
  String get previous => 'Previous';

  @override
  String get taskExpiredTransferred =>
      'Response time expired, task transferred to another driver';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get lowestPrice => 'Lowest Price';

  @override
  String get highestPrice => 'Highest Price';

  @override
  String get sort => 'Sort';

  @override
  String get apply => 'Apply';

  @override
  String get confirmAcceptTask => 'Are you sure you want to accept this task?';

  @override
  String get close => 'Close';

  @override
  String get allNotificationsMarkedRead => 'All notifications marked as read';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get updateLocationGPS => 'Update GPS Location';

  @override
  String get view => 'View';

  @override
  String get filterTransactions => 'Filter Transactions';

  @override
  String get appInitializationError =>
      'An error occurred during app initialization. Please try again.';

  @override
  String get loadingOffers => 'Loading offers...';

  @override
  String get loadingRegistrationData => 'Loading registration data...';

  @override
  String get sendingLocation => 'Sending location...';

  @override
  String get failedToLoadImage => 'Failed to load image';

  @override
  String get failedToSelectImage => 'Failed to select image';

  @override
  String get failedToSelectFile => 'Failed to select file';

  @override
  String get undefinedItem => 'Undefined item';

  @override
  String get cannotAccessAdDetails => 'Cannot access ad details';

  @override
  String fileSelectedSuccessfully(String fileName) {
    return 'File selected: $fileName';
  }

  @override
  String get phoneIsWhatsApp => 'My phone number is the same as WhatsApp';

  @override
  String get correctBasicDataErrors => 'Please correct errors in basic data';

  @override
  String get selectVehicleTypeSize => 'Please select vehicle type and size';

  @override
  String get fillAllAdditionalFields =>
      'Please fill all required additional information fields';

  @override
  String taskDetailsError(String error) {
    return 'Error fetching task details: $error';
  }

  @override
  String get registrationErrorOccurred =>
      'An error occurred during registration';

  @override
  String get profileUpdateError => 'An error occurred while updating profile';

  @override
  String get passwordChangeError => 'An error occurred while changing password';

  @override
  String locationSendError(String error) {
    return 'Location send error';
  }

  @override
  String get sentLocationDetails => 'Sent location details';

  @override
  String taskHistoryError(String error) {
    return 'Error fetching task history: $error';
  }

  @override
  String fileSelectionError(String error) {
    return 'Error selecting file: $error';
  }

  @override
  String get noteAddedSuccessfully => 'Note added successfully';

  @override
  String noteAddError(String error) {
    return 'Error adding note: $error';
  }

  @override
  String attachmentOpenError(String error) {
    return 'Error opening attachment: $error';
  }

  @override
  String get imageLoadError => 'Image load error';

  @override
  String get fileDownloadError => 'File download error';

  @override
  String get fileOpenError => 'File open error';

  @override
  String get fileOpenedForDownload => 'File opened for download';

  @override
  String get passwordRequirements =>
      '• At least 8 characters\n• At least one uppercase letter (A-Z)\n• At least one lowercase letter (a-z)\n• At least one number (0-9)';

  @override
  String get passwordSecurityTips =>
      '• Don\'t share your password with anyone\n• Use a strong and unique password\n• Change your password regularly\n• Don\'t use personal information in your password';

  @override
  String get fileViewerComingSoon => 'File viewer coming soon';

  @override
  String get linkOpenComingSoon => 'Link opening coming soon';

  @override
  String get taskOfferAccepted =>
      'Your offer for this task has been accepted!\n\nDo you want to accept the task and start executing it?\n\nAfter acceptance, the task will be officially assigned to you and will appear in your current tasks list.';

  @override
  String get basicData => 'Basic Data';

  @override
  String get additionalInfo => 'Additional Information';

  @override
  String get reviewAndConfirm => 'Review and Confirm';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get username => 'Username';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength8 => 'Password must be at least 8 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordRequired => 'Confirm password is required';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get addressRequired => 'Address is required';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get selectVehicle => 'Select Vehicle';

  @override
  String get vehicleRequired => 'Vehicle selection is required';

  @override
  String get selectVehicleType => 'Select Vehicle Type';

  @override
  String get vehicleTypeRequired => 'Vehicle type selection is required';

  @override
  String get selectVehicleSize => 'Select Vehicle Size';

  @override
  String get vehicleSizeRequired => 'Vehicle size selection is required';

  @override
  String get selectTeamOptional => 'Select Team (Optional)';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get phoneIsWhatsAppNumber => 'My phone number is the same as WhatsApp';

  @override
  String get enterWhatsAppOrSelectPhone =>
      'Please enter WhatsApp number or select that phone is WhatsApp';

  @override
  String get requiredAdditionalInfo => 'Required Additional Information';

  @override
  String fieldRequired(String fieldName) {
    return '$fieldName is required';
  }

  @override
  String get mustBeValidNumber => 'Must be a valid number';

  @override
  String get invalidUrl => 'Invalid URL';

  @override
  String selectOption(String fieldName) {
    return 'Select $fieldName';
  }

  @override
  String get fileSelected => 'File selected';

  @override
  String get selectFile => 'Tap to select file';

  @override
  String get dataReview => 'Data Review';

  @override
  String get additionalFields => 'Additional Fields';

  @override
  String get agreeToTerms =>
      'By clicking \"Create Account\" you agree to the Terms of Service and Privacy Policy';

  @override
  String get verificationEmailSent =>
      'A verification link will be sent to your email to activate your account';

  @override
  String get createAccount => 'Create Account';

  @override
  String get next => 'Next';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get checkEmailAndActivate =>
      'Please check your email and activate your account, then return to login.';

  @override
  String get loginText => 'Login';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get selectVehicleRequired => 'Vehicle selection is required';

  @override
  String get selectVehicleTypeRequired => 'Vehicle type selection is required';

  @override
  String get selectVehicleSizeRequired => 'Vehicle size selection is required';

  @override
  String get selectTeam => 'Select Team';

  @override
  String get selectTeamRequired => 'Team selection is required';

  @override
  String get whatsappNumberOptional =>
      'WhatsApp number for communication (Optional)';

  @override
  String get phoneIsWhatsapp => 'My phone number is the same as WhatsApp';

  @override
  String get whatsappRequired =>
      'Please enter WhatsApp number or select that phone is WhatsApp';

  @override
  String get additionalInfoRequired => 'Additional Information Required';

  @override
  String get phoneNumberPlaceholder => 'Phone Number';

  @override
  String get whatsappNumberPlaceholder => 'WhatsApp Number';

  @override
  String get sentSuccessfully => 'Sent Successfully';

  @override
  String get resetLinkSentTo => 'Password reset link has been sent to:';

  @override
  String get enterEmailForReset =>
      'Enter your email address and we\'ll send you a password reset link';

  @override
  String get enterYourEmail => 'Enter your email address';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get termsAndPrivacyAgreement =>
      'By clicking \"Create Account\" you agree to the Terms of Use and Privacy Policy';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get verificationLinkWillBeSent =>
      'A verification link will be sent to your email to activate your account';

  @override
  String get all => 'All';

  @override
  String get deposits => 'Deposits';

  @override
  String get withAttachments => 'With Attachments';

  @override
  String get type => 'Type';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get referenceNumber => 'Reference Number';

  @override
  String get maturityDate => 'Maturity Date';

  @override
  String get attachment => 'Attachment';

  @override
  String get tapToView => 'Tap to View';

  @override
  String get noTransactionsWithAttachments =>
      'No transactions with attachments';

  @override
  String get tapOpenToViewFile => 'Tap \"Open\" to view the file';

  @override
  String get searchInTransactions => 'Search in transactions...';

  @override
  String get noTransactionsFound => 'No transactions found matching the search';

  @override
  String get noTransactionsOfType => 'No transactions of type';

  @override
  String get noTransactionsWithAttachmentsDescription =>
      'No transactions found containing images or files';

  @override
  String get attachmentLabel => 'Attachment';

  @override
  String get referenceNumberLabel => 'Reference Number';

  @override
  String get filter => 'Filter';

  @override
  String get refresh => 'Refresh';

  @override
  String get noAdsAvailable => 'No ads available';

  @override
  String get noAdsAvailableDescription =>
      'No task ads are available at the moment';

  @override
  String get adDetails => 'Ad Details';

  @override
  String get submittedOffers => 'Submitted Offers';

  @override
  String get cannotViewOffers => 'You cannot view submitted offers';

  @override
  String get noOffersSubmittedDescription =>
      'No offers have been submitted for this ad yet';

  @override
  String get acceptTaskConfirmation =>
      'Are you sure you want to accept this task?';

  @override
  String get contactName => 'Contact Name';

  @override
  String get contactPerson => 'Contact Person';

  @override
  String get pendingApproval => 'Pending Approval';

  @override
  String get cannotUndo => 'This action cannot be undone.';

  @override
  String get updatedSuccessfully => 'Updated Successfully';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get internetConnectionRequired =>
      'The app requires an internet connection to work properly. Please check your internet connection and try again.';

  @override
  String get initializationError => 'Initialization Error';

  @override
  String get initializationErrorMessage =>
      'An error occurred while initializing the app. Please try again.';

  @override
  String get driversApp => 'Drivers App';

  @override
  String get rejected => 'Rejected';

  @override
  String get failedToLoadOffers => 'Failed to load offers';

  @override
  String get updateOffer => 'Update Offer';

  @override
  String taskHistoryTitle(String taskId) {
    return 'Task History #$taskId';
  }

  @override
  String errorLoadingTaskHistory(String error) {
    return 'Error loading task history: $error';
  }

  @override
  String get failedToAddNote => 'Failed to add note';

  @override
  String get clickOpenToViewFile => 'Click \"Open\" to view the file';

  @override
  String get taskStatusAssign => 'Assigned';

  @override
  String get taskStatusStarted => 'Started';

  @override
  String get taskStatusInPickupPoint => 'At Pickup Point';

  @override
  String get taskStatusLoading => 'Loading';

  @override
  String get taskStatusInTheWay => 'On the Way';

  @override
  String get taskStatusInDeliveryPoint => 'At Delivery Point';

  @override
  String get taskStatusUnloading => 'Unloading';

  @override
  String get taskStatusCompleted => 'Completed';

  @override
  String get taskStatusCancelled => 'Cancelled';

  @override
  String get updateLocation => 'Update Location';

  @override
  String get locationSent => 'Location sent';

  @override
  String get importantNotes => 'Important Notes:';

  @override
  String get checkInboxAndSpam => '• Check your inbox and spam folder';

  @override
  String get linkValidOneHour => '• The link is valid for one hour only';

  @override
  String get noEmailRetry =>
      '• If you don\'t receive the email within 5 minutes, you can try again';

  @override
  String get taskAssignedToDriver => 'Task assigned to driver';

  @override
  String get driverStartedTask => 'Driver started the task';

  @override
  String get driverArrivedPickup => 'Driver arrived at pickup point';

  @override
  String get loadingGoods => 'Loading goods';

  @override
  String get driverOnWayDelivery => 'Driver on the way to delivery point';

  @override
  String get driverArrivedDelivery => 'Driver arrived at delivery point';

  @override
  String get unloadingGoods => 'Unloading goods';

  @override
  String get taskCompletedSuccessfully => 'Task completed successfully';

  @override
  String get newLabel => 'New';

  @override
  String get daysAgoPlural => 'days ago';

  @override
  String get hoursAgoPlural => 'hours ago';

  @override
  String get minutesAgoPlural => 'minutes ago';
}
