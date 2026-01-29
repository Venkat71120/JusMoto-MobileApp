import 'package:car_service/views/conversation_view/conversation_view.dart';
import 'package:car_service/views/intro_view/intro_view.dart';
import 'package:car_service/views/service_result_view/service_result_view.dart';
import 'package:car_service/views/splash_view/splash_view.dart';

class Routes {
  static var routes = {
    IntroView.routeName: (_) => const SplashView(),
    ServiceResultView.routeName: (_) => const ServiceResultView(),
    ConversationView.routeName: (_) => const ConversationView(),
  };
}
