import 'package:car_service/services/Franchise_dashboard_Services/franchise_orders_service.dart';
import 'package:car_service/services/Franchise_dashboard_Services/franchise_tickets_service.dart';
import 'package:car_service/services/address_services/area_service.dart';
import 'package:car_service/services/address_services/city_service.dart';
import 'package:car_service/services/address_services/states_service.dart';
import 'package:car_service/services/home_services/home_popular_products_service.dart';
import 'package:car_service/services/order_services/order_complete_request_history_service.dart';
import 'package:car_service/services/order_services/refund_settings_service.dart';
import 'package:car_service/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../services/address_services/address_list_service.dart';
import '../services/app_string_service.dart';
import '../services/auth_services/email_otp_service.dart';
import '../services/auth_services/phone_manage_service.dart';
import '../services/auth_services/sign_in_service.dart';
import '../services/auth_services/sign_up_service.dart';
import '../services/auth_services/FranchiseLoginService.dart';
// ✅ ADD THIS IMPORT
import '../services/Franchise_dashboard_Services/franchise_dashboard_service.dart';
import '../services/booking_services/booking_addons_service.dart';
import '../services/booking_services/booking_schedule_service.dart';
import '../services/booking_services/hire_provider_from_offer_service.dart';
import '../services/booking_services/place_order_service.dart';
import '../services/car_services/brand_list_service.dart';
import '../services/car_services/model_list_service.dart';
import '../services/category_service.dart';
import '../services/chat_services/chat_credential_service.dart';
import '../services/chat_services/chat_list_service.dart';
import '../services/conversation_service.dart';
import '../services/dynamics/dynamics_service.dart';
import '../services/google_location_search_service.dart';
import '../services/home_services/admin_staff_list_service.dart';
import '../services/home_services/home_category_service.dart';
import '../services/home_services/home_featured_services_service.dart';
import '../services/home_services/home_popular_services_service.dart';
import '../services/home_services/home_product_category_service.dart';
import '../services/home_services/home_slider_service.dart';
import '../services/home_services/service_details_service.dart';
import '../services/intro_service.dart';
import '../services/notification_services/notification_list_service.dart';
import '../services/order_services/order_details_service.dart';
import '../services/order_services/order_list_service.dart';
import '../services/order_services/refund_list_service.dart';
import '../services/order_services/refund_manage_service.dart';
import '../services/outlet_service.dart';
import '../services/profile_services/delete_account_service.dart';
import '../services/profile_services/profile_info_service.dart';
import '../services/rating_and_reviews_service.dart';
import '../services/reset_password_service.dart';
import '../services/service/cart_service.dart';
import '../services/service/favorite_services_service.dart';
import '../services/service/product_list_service.dart';
import '../services/service/service_by_category_service.dart';
import '../services/service/service_by_offer_service.dart';
import '../services/service/services_search_service.dart';
import '../services/support_services/ticket_conversation_service.dart';
import '../services/support_services/ticket_list_service.dart';
import '../services/wallet_services/wallet_service.dart';

class Providers {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (context) => DynamicsService()),
    ChangeNotifierProvider(create: (context) => AppStringService()),
    ChangeNotifierProvider(create: (context) => ThemeService()),
    ChangeNotifierProvider(create: (context) => IntroService()),
    ChangeNotifierProvider(create: (context) => StatesService()),
    ChangeNotifierProvider(create: (context) => CityService()),
    ChangeNotifierProvider(create: (context) => AreaService()),
    ChangeNotifierProvider(create: (context) => ServicesSearchService()),
    ChangeNotifierProvider(create: (context) => ConversationService()),
    ChangeNotifierProvider(create: (context) => OrderListService()),
    ChangeNotifierProvider(create: (context) => ChatListService()),
    ChangeNotifierProvider(create: (context) => SignInService()),
    ChangeNotifierProvider(create: (context) => SignUpService()),
    ChangeNotifierProvider(create: (context) => FranchiseLoginService()),
    // ✅ ADD THIS LINE
    ChangeNotifierProvider(create: (context) => FranchiseDashboardService()),
    ChangeNotifierProvider(create: (context) => RatingAndReviewsService()),
    ChangeNotifierProvider(create: (context) => ProfileInfoService()),
    ChangeNotifierProvider(create: (context) => AddressListService()),
    ChangeNotifierProvider(create: (context) => GoogleLocationSearch()),
    ChangeNotifierProvider(create: (context) => CategoryService()),
    ChangeNotifierProvider(create: (context) => FavoriteServicesService()),
    ChangeNotifierProvider(create: (context) => ServiceDetailsService()),
    ChangeNotifierProvider(create: (context) => HomeFeaturedServicesService()),
    ChangeNotifierProvider(create: (context) => BookingAddonsService()),
    ChangeNotifierProvider(create: (context) => BookingScheduleService()),
    ChangeNotifierProvider(create: (context) => CartService()),
    ChangeNotifierProvider(create: (context) => PlaceOrderService()),
    ChangeNotifierProvider(create: (context) => TicketListService()),
    ChangeNotifierProvider(create: (context) => TicketConversationService()),
    ChangeNotifierProvider(create: (context) => NotificationListService()),
    ChangeNotifierProvider(create: (context) => EmailManageService()),
    ChangeNotifierProvider(create: (context) => DeleteAccountService()),
    ChangeNotifierProvider(create: (context) => PhoneManageService()),
    ChangeNotifierProvider(create: (context) => HomeSliderService()),
    ChangeNotifierProvider(create: (context) => HomeCategoryService()),
    ChangeNotifierProvider(create: (context) => ResetPasswordService()),
    ChangeNotifierProvider(create: (context) => OrderDetailsService()),
    ChangeNotifierProvider(
      create: (context) => OrderCompleteRequestHistoryService(),
    ),
    ChangeNotifierProvider(create: (context) => HireProviderFromOfferService()),
    ChangeNotifierProvider(create: (context) => HomePopularServicesService()),
    ChangeNotifierProvider(create: (context) => ServiceByCategoryService()),
    ChangeNotifierProvider(create: (context) => ChatCredentialService()),
    ChangeNotifierProvider(create: (context) => ServiceByOfferService()),
    ChangeNotifierProvider(create: (context) => AdminStaffListService()),
    ChangeNotifierProvider(create: (context) => ProductListService()),
    ChangeNotifierProvider(create: (context) => BrandListService()),
    ChangeNotifierProvider(create: (context) => ModelListService()),
    ChangeNotifierProvider(create: (context) => OutletService()),
    ChangeNotifierProvider(create: (context) => RefundSettingsService()),
    ChangeNotifierProvider(create: (context) => RefundManageService()),
    ChangeNotifierProvider(create: (context) => RefundListService()),
    ChangeNotifierProvider(create: (context) => HomePopularProductsService()),
    ChangeNotifierProvider(create: (context) => HomeProductCategoryService()),
    ChangeNotifierProvider(create: (context) => WalletService()),
    ChangeNotifierProvider(create: (context) => FranchiseOrdersService()),
    ChangeNotifierProvider(create: (context) => FranchiseTicketsService()),
    
  ];
}