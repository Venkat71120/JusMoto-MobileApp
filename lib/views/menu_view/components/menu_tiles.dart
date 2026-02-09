import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/services/profile_services/profile_info_service.dart';
import 'package:car_service/view_models/sign_in_view_model/sign_in_view_model.dart';
import 'package:car_service/view_models/sign_in_view_model/social_sign_in_view_model.dart';
import 'package:car_service/view_models/wallet_view_model/wallet_view_model.dart';
import 'package:car_service/views/address_list_view/address_list_view.dart';
import 'package:car_service/views/delete_account_view/delete_account_view.dart';
import 'package:car_service/views/favorite_services_view/favorite_services_view.dart';
import 'package:car_service/views/menu_view/components/menu_tile.dart';
import 'package:car_service/views/menu_view/components/theme_setting_tile.dart';
import 'package:car_service/views/notification_list_view/notification_list_view.dart';
import 'package:car_service/views/sign_in_view/sign_in_view.dart';
import 'package:car_service/views/support_ticket_view/support_ticket_view.dart';
import 'package:car_service/views/tac_pp_view/tac_pp_view.dart';
import 'package:car_service/views/wallet_view/wallet_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/auth_services/sign_out_service.dart';
import '../../../utils/components/alerts.dart';
import '../../../view_models/delete_account_view_model/delete_account_view_model.dart';
import '../../change_language_view/change_language_view.dart';
import '../../refund_list_view/refund_list_view.dart';

class MenuTiles extends StatelessWidget {
  final bool signedIn;
  const MenuTiles({super.key, required this.signedIn});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: context.color.accentContrastColor,
          child: Column(
            children: [
              MenuTile(
                title: LocalKeys.favorites,
                svg: SvgAssets.heart,
                onPress: () {
                  context.toPage(const FavoriteServicesView());
                },
                haveDivider: signedIn,
              ),
              if (signedIn) ...[
                MenuTile(
                  title: LocalKeys.supportTicket,
                  svg: SvgAssets.ticket,
                  onPress: () {
                    context.toPage(const SupportTicketView());
                  },
                  haveDivider: true,
                ),
                MenuTile(
                  title: LocalKeys.refunds,
                  svg: SvgAssets.refund,
                  onPress: () {
                    context.toPage(const RefundListView());
                  },
                  haveDivider: true,
                ),
                // MenuTile(
                //   title: LocalKeys.wallet,
                //   svg: SvgAssets.creditCard,
                //   onPress: () {
                //     WalletViewModel.dispose;
                //     context.toPage(const WalletView());
                //   },
                //   haveDivider: true,
                // ),
                MenuTile(
                  title: LocalKeys.notifications,
                  svg: SvgAssets.notificationBell,
                  onPress: () {
                    context.toPage(const NotificationListView());
                  },
                  haveDivider: true,
                ),
                MenuTile(
                  title: LocalKeys.addresses,
                  svg: SvgAssets.addressHome,
                  onPress: () {
                    context.toPage(const AddressListView());
                  },
                ),
              ],
            ],
          ),
        ),
        8.toHeight,
        Container(
          color: context.color.accentContrastColor,
          child: Column(
            children: [
              MenuTile(
                title: LocalKeys.languages,
                svg: SvgAssets.languages,
                onPress: () {
                  context.toPage(const ChangeLanguageView());
                },
                haveDivider: true,
              ),
              const ThemeSettingTile(),
              MenuTile(
                title: LocalKeys.termsAndConditions,
                svg: SvgAssets.fileText,
                onPress: () {
                  context.toPage(
                    TacPpView(
                      title: LocalKeys.termsAndConditions,
                      url: AppUrls.termsAndConditions,
                    ),
                  );
                },
                haveDivider: true,
              ),
              MenuTile(
                title: LocalKeys.privacyPolicy,
                svg: SvgAssets.fileText,
                onPress: () {
                  context.toPage(
                    TacPpView(
                      title: LocalKeys.privacyPolicy,
                      url: AppUrls.privacyPolicy,
                    ),
                  );
                },
                haveDivider: true,
              ),
              MenuTile(
                title: LocalKeys.contact,
                svg: SvgAssets.contact,
                onPress: () {
                  context.toPage(
                    TacPpView(title: LocalKeys.contact, url: AppUrls.contact),
                  );
                },
                haveDivider: false,
              ),
            ],
          ),
        ),
        8.toHeight,
        Container(
          color: context.color.accentContrastColor,
          child: Column(
            children: [
              if (signedIn) ...[
                MenuTile(
                  title: LocalKeys.deleteAccount,
                  svg: SvgAssets.trash,
                  onPress: () {
                    DeleteAccountViewModel.dispose;
                    context.toPage(const DeleteAccountView());
                  },
                  haveDivider: true,
                ),
                MenuTile(
                  title: LocalKeys.signOut,
                  svg: SvgAssets.logout,
                  onPress: () {
                    Alerts().confirmationAlert(
                      context: context,
                      title: LocalKeys.areYouSure,
                      buttonText: LocalKeys.signOut,
                      onConfirm: () async {
                        await SignOutService().trySignOut().then((result) {
                          if (result == true) {
                            context.pop;
                            Provider.of<ProfileInfoService>(
                              context,
                              listen: false,
                            ).reset();
                            SocialSignInViewModel.instance.signOut();
                          }
                        });
                      },
                    );
                  },
                  haveDivider: false,
                ),
              ],
              if (!signedIn)
                MenuTile(
                  title: LocalKeys.signIn,
                  svg: SvgAssets.user,
                  onPress: () {
                    SignInViewModel.dispose;
                    SignInViewModel.instance.initSavedInfo();
                    context.toPage(const SignInView());
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
