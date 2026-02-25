import '/customization.dart';

class AppUrls {
  static String get statesUrl => '$baseEndPoint/states';
  static String get areaUrl => '$baseEndPoint/areas';
  static String get translationUrl => '$baseEndPoint/translate-string-slug';
  static String get defaultTranslationUrl => '$baseEndPoint/translate-string';
  static String get cityUrl => '$baseEndPoint/cities';
  static String get fcmTokenUrl => '$baseEndPoint/auth/firebase-token';
  static String get currencyLanguageUrl => '$baseEndPoint/currency';
  static String get languageListUrl => '$baseEndPoint/language';
  static String get sendOtpUrl => '$baseEndPoint/auth/forgot-password';
  static String get resetPasswordUrl => '$baseEndPoint/auth/reset-password';

  // ✅ UPDATED: Now uses /categories (supports status, is_featured, search params)
  static String get categoryListUrl => '$baseEndPoint/categories';

  // ✅ UPDATED: Primary offer now under general namespace
  static String get primaryOfferUrl => '$baseEndPoint/general/primary-offer';

  static String get myBrandsListUrl => '$baseEndPoint/all-brands';
  static String get outletListUrl => '$baseEndPoint/all-outlet';
  static String get carModelsListUrl => '$baseEndPoint/all-cars';
  static String get myRefundListUrl =>
      '$baseEndPoint/client/orders/all-refund-list';
  static String get myRefundDetailsUrl =>
      '$baseEndPoint/client/orders/refund-details';
  static String get refundPaymentMethodsUrl =>
      '$baseEndPoint/client/refund/all';
  static String get updateRefundPaymentInfoUrl =>
      '$baseEndPoint/client/service/refund-info-update';
  static String get serviceListByOfferUrl => '$baseEndPoint/offer-services';

  // ✅ UPDATED: Categories with services now uses /categories endpoint
  static String get homeCategoryListUrl => '$baseEndPoint/categories';

  // ✅ UPDATED: Product categories now uses /categories endpoint with type param
  static String get homeProductCategoryListUrl => '$baseEndPoint/categories';

  // ✅ UPDATED: Sliders now under general namespace
  static String get homeSliderListUrl => '$baseEndPoint/general/sliders';

  static String get homeProvidersListUrl => '$baseEndPoint/provider-lists';
  static String termsAndConditions = '$baseEndPoint/terms-and-conditions';
  static String privacyPolicy = '$baseEndPoint/privacy-policy';
  static String contact = '$baseEndPoint/contact';
  static String get paymentGatewayUrl => '$baseEndPoint/payment-gateway-list';
  static String get conversationUrl => '$baseEndPoint/client/chat/fetch-record';
  static String get messageSendUrl => '$baseEndPoint/client/chat/message-send';
  static String get signInUrl => '$baseEndPoint/auth/login';
  static String get otpSignInUrl => "$baseEndPoint/login-otp/verification";
  static String get emailSignUpUrl => '$baseEndPoint/auth/register';
  static String get socialSignInUrl => '$baseEndPoint/auth/social/login';

  // ✅ NEW: Franchise login endpoint
  static String get franchiseLoginUrl => '$baseEndPoint/auth/admin/login';

  static String get myOrdersListUrl => '$baseEndPoint/client/orders/all';
  static String get orderDetailsUrl => '$baseEndPoint/client/orders/details';
  static String get orderCancelUrl =>
      '$baseEndPoint/client/service/order-cancel';
  static String get refundInfoUpdateUrl =>
      '$baseEndPoint/client/service/refund-info-update';
  static String get chatListUrl => '$baseEndPoint/client/chat/provider-list';
  static String get jobList => '$baseEndPoint/privacy-policy';
  static String get offerListUrl => '$baseEndPoint/client/job/offers/lists';
  static String get jobDetailsUrl => '$baseEndPoint/client/job/details';
  static String get cancellationPolicyUrl =>
      '$baseEndPoint/order/cancel-policy-details';
  static String get taxInfoUrl =>
      '$baseEndPoint/client/tax-delivery-charge-info';
  static String get couponInfoUrl => '$baseEndPoint/client/coupon-info';
  static String get jobOfferDetailsUrl =>
      '$baseEndPoint/client/job/offers/details';
  static String get offerRejectUrl => '$baseEndPoint/client/job/offers/reject';
  static String get providerDetailsUrl =>
      '$baseEndPoint/provider/profile/details';
  static String get favoriteServicesUrl => '$baseEndPoint/privacy-policy';
  static String get changePasswordUrl => '$baseEndPoint/user/change-password';
  static String get signOutUrl => '$baseEndPoint/auth/logout';
  static String get ratingAndReviewsUrl => '$baseEndPoint/client/reviews/all';
  static String get submitReviewsUrl => '$baseEndPoint/user/review-add';
  static String get jobListUrl => '$baseEndPoint/client/job/lists';
  static String get postJobUrl => '$baseEndPoint/client/job/add';
  static String get addressListUrl => '$baseEndPoint/client/location/all';
  static String get addAddressUrl => '$baseEndPoint/client/location/create';
  static String get editAddressUrl => '$baseEndPoint/client/location/edit/';
  static String get deleteAddressUrl => '$baseEndPoint/client/location/delete/';
  static String get acceptOrderCompeteRequestUrl =>
      '$baseEndPoint/client/orders/complete-request/status-approve';
  static String get declineOrderCompeteRequestUrl =>
      '$baseEndPoint/client/orders/complete-request/status-decline';

  // ✅ UPDATED: Featured services now uses /services/featured
  static String get homeFeaturedServicesUrl => '$baseEndPoint/services/featured';

  // ✅ UPDATED: All services now uses /services
  static String get serviceListUrl => '$baseEndPoint/services';

  // ✅ UPDATED: Service details now uses /services/:id
  static String get serviceDetailsUrl => '$baseEndPoint/services';

  static String get staffListUrl => '$baseEndPoint/service/staff-lists';
  static String get providerScheduleListUrl =>
      '$baseEndPoint/service/schedule-lists';
  static String get placeOrderUrl =>
      '$baseEndPoint/client/service/order-create';
  static String get orderPaymentUpdateUrl =>
      '$baseEndPoint/client/service/order-payment-status-update';
  static String get ticketListListUrl =>
      '$baseEndPoint/user/support-ticket/all';
  static String get stDepartmentsUrl => '$baseEndPoint/user/all-departments';
  static String get createTicketUrl =>
      '$baseEndPoint/user/support-ticket/create';
  static String get fetchTicketConversationUrl =>
      '$baseEndPoint/user/support-ticket/view-ticket';
  static String get sendTicketMessageUrl =>
      '$baseEndPoint/user/support-ticket/message-send';
  static String get myNotificationsListUrl =>
      '$baseEndPoint/user/notifications/all';
  static String get notificationReadUrl =>
      '$baseEndPoint/user/notifications/clear';
  static String get sentOtpToMailUrl => '$baseEndPoint/auth/resend-otp';
  static String get verifyEmailUrl => '$baseEndPoint/auth/verify-email';
  static String get profileInfoUpdateUrl => '$baseEndPoint/user/profile/update';
  static String get profileInfoUrl => '$baseEndPoint/user/profile';
  static String get reasonListUrl => '$baseEndPoint/reasons';
  static String get deleteAccountUrl =>
      '$baseEndPoint/user/settings/account-delete';
  static String get changeEmailUrl => '$baseEndPoint/user/change-email';
  static String get sentOtpToPhoneUrl => '$baseEndPoint/login-otp/send';
  static String get verifyPhoneUrl => '$baseEndPoint/login-otp/verification';
  static String get changePhoneUrl => '$baseEndPoint/user/change-phone-number';
  static String get completeRequestHistoryUrl =>
      '$baseEndPoint/provider/orders/complete-request/history?';
  static String get invoiceUrl => '$baseEndPoint/client/order/invoice-details';
  static String get hireProviderUrl => '$baseEndPoint/client/job/hire';
  static String get changeJobPublishStatusUrl =>
      '$baseEndPoint/client/job/published-status';

  // ✅ UPDATED: Popular services now uses /services with query params
  static String get homePopularServicesUrl => '$baseEndPoint/services';

  static String get unreadCountUrl =>
      '$baseEndPoint/client/chat/unseen-message/count';
  static String get chatCredentialUrl => '$baseEndPoint/live-chat/credentials';
  static String get editJobUrl => '$baseEndPoint/client/job/edit';

  // ✅ NEW: Active offers endpoint
  static String get activeOffersUrl => '$baseEndPoint/general/offers';

  // Wallet URLs
  static String get walletBalanceUrl =>
      '$baseEndPoint/client/wallet/current-balance/info';
  static String get walletTransactionsUrl =>
      '$baseEndPoint/client/wallet/all-transactions';
  static String get walletDepositCreateUrl =>
      '$baseEndPoint/client/wallet/deposit/create';
  static String get walletDepositPaymentUpdateUrl =>
      '$baseEndPoint/client/wallet/deposit/payment-update';

  // Franchise Dashboard URLs
  static String get franchiseDashboardStatisticsUrl =>
      '$baseEndPoint/franchise/dashboard/statistics';
  static String get franchiseDashboardOrderCountsUrl =>
      '$baseEndPoint/franchise/dashboard/order-counts';
  static String get franchiseDashboardEarningsUrl =>
      '$baseEndPoint/franchise/dashboard/earnings';
  static String get franchiseDashboardRecentActivityUrl =>
      '$baseEndPoint/franchise/dashboard/recent-activity';

  static String get franchiseOrdersUrl => '$baseEndPoint/franchise/orders/all';
  static String get franchiseOrderDetailUrl => '$baseEndPoint/franchise/orders';
  static String get franchiseTicketsUrl =>
      '$baseEndPoint/franchise/support-ticket/all';
  static String get franchiseTicketStatisticsUrl =>
      '$baseEndPoint/franchise/support-ticket/statistics';
  static String get franchiseTicketDetailUrl =>
      '$baseEndPoint/franchise/support-ticket';
}