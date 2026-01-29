import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '/views/splash_view/splash_view.dart';
import './main.dart';
import 'customization.dart';
import 'helper/constant_helper.dart';
import 'helper/providers.dart';
import 'helper/routes.dart';
import 'services/dynamics/dynamics_service.dart';
import 'services/theme_service.dart';
import 'themes/default_themes.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: Providers.providers,
      child: Consumer<DynamicsService>(
        builder: (context, dProvider, child) {
          coreInit(context);
          debugPrint(dProvider.appLocal.toString());
          print("auto Building");
          coreInit(context);
          return FutureBuilder(
              future: dProvider.onceRebuilt ? null : dProvider.getColors(),
              builder: (context, sn) {
                return Consumer<ThemeService>(builder: (context, ts, _) {
                  return MaterialApp(
                    navigatorKey: navigatorKey,
                    themeMode: ts.darkTheme ? ThemeMode.dark : ThemeMode.light,
                    debugShowCheckedModeBanner: false,
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: [
                      const Locale('en', "US"),
                      dProvider.appLocal
                    ],
                    builder: (context, rtlChild) {
                      return Directionality(
                        textDirection: dProvider.textDirectionRight
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: rtlChild!,
                      );
                    },
                    title: appLabel,
                    theme: DefaultThemes()
                        .themeData(context, ts.selectedTheme, ts),
                    home: child,
                    routes: Routes.routes,
                  );
                });
              });
        },
        child: const SplashView(),
      ),
    );
  }
}
