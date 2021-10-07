import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/user_controller_impl.dart';
import '../services/auth_service.dart';
import '../services/spring_service.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/exception_alert_dialog.dart';
import '../widgets/radio_item.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/settings_list_item.dart';
import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key, required this.controller}) : super(key: key);

  static const String routeName = '/settings';

  final SettingsController controller;

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool _didRequestSignOut = await CustomAlertDialog(
          title: AppLocalizations.of(context)!.logoutConfirm,
          cancelActionText: AppLocalizations.of(context)!.cancel,
          defaultActionText: AppLocalizations.of(context)!.logout,
        ).show(context) ??
        false;

    if (_didRequestSignOut) {
      // final MyUser user =
      //     Provider.of<UserControllerImpl>(context, listen: false).user!;
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      // final int index = user.fcmTokens!.indexOf(fcmToken!);

      // await GetIt.I.get<SpringService>().removeFcmToken(
      //     userId: user.id!, fcmTokenIndex: index, fcmToken: fcmToken);
      await GetIt.I.get<SpringService>().logout(fcmToken: fcmToken!);

      await _signOut(context);

      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final AuthService auth = Provider.of<AuthService>(context, listen: false);
      await auth.signOut();
      Provider.of<UserControllerImpl>(context, listen: false).logout();
    } on PlatformException catch (e) {
      await ExceptionAlertDialog(
        title: AppLocalizations.of(context)!.logoutFailed,
        exception: e,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    Widget getLanguageImage(Locale locale) {
      late String svgLocation;
      if (locale == kLocaleTurkish) {
        svgLocation = kTurkishSvg;
      } else {
        svgLocation = kEnglishSvg;
      }

      return SvgPicture.asset(svgLocation);
    }

    String getLanguageName(Locale locale) {
      if (locale == kLocaleEnglish) {
        return AppLocalizations.of(context)!.english;
      }

      return AppLocalizations.of(context)!.turkish;
    }

    String getThemeName(ThemeMode themeMode) {
      if (themeMode == ThemeMode.system) {
        return AppLocalizations.of(context)!.system;
      } else if (themeMode == ThemeMode.light) {
        return AppLocalizations.of(context)!.light;
      }

      return AppLocalizations.of(context)!.dark;
    }

    Future<void> changeLanguage() {
      return showDialog<void>(
        context: context,
        builder: (BuildContext ctx) {
          return StatefulBuilder(
            builder:
                (BuildContext context, void Function(VoidCallback) setState) {
              return SettingsDialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioItem<Locale>(
                      onChanged: controller.updateLocale,
                      onTap: () => controller.updateLocale(kLocaleEnglish),
                      providerValue: controller.locale,
                      radioValue: kLocaleEnglish,
                      text: AppLocalizations.of(context)!.english,
                      iconPath: 'assets/icons/en.svg',
                    ),
                    RadioItem<Locale>(
                      onChanged: controller.updateLocale,
                      onTap: () => controller.updateLocale(kLocaleTurkish),
                      providerValue: controller.locale,
                      radioValue: kLocaleTurkish,
                      text: AppLocalizations.of(context)!.turkish,
                      iconPath: 'assets/icons/tr.svg',
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          AppLocalizations.of(context)!.ok,
                          style: textTheme.bodyText1!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    Future<void> changeAppTheme() {
      return showDialog<void>(
        context: context,
        builder: (BuildContext ctx) {
          return SettingsDialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioItem<ThemeMode>(
                  onChanged: controller.updateThemeMode,
                  onTap: () {
                    controller.updateThemeMode(ThemeMode.system);
                  },
                  providerValue: controller.themeMode,
                  radioValue: ThemeMode.system,
                  icon: Icons.brightness_auto,
                  text: AppLocalizations.of(context)!.system,
                ),
                RadioItem<ThemeMode>(
                  onChanged: controller.updateThemeMode,
                  onTap: () {
                    controller.updateThemeMode(ThemeMode.light);
                  },
                  providerValue: controller.themeMode,
                  radioValue: ThemeMode.light,
                  icon: Icons.light_mode,
                  text: AppLocalizations.of(context)!.light,
                ),
                RadioItem<ThemeMode>(
                  onChanged: controller.updateThemeMode,
                  onTap: () {
                    controller.updateThemeMode(ThemeMode.dark);
                  },
                  providerValue: controller.themeMode,
                  radioValue: ThemeMode.dark,
                  icon: Icons.dark_mode,
                  text: AppLocalizations.of(context)!.dark,
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      AppLocalizations.of(context)!.ok,
                      style: textTheme.bodyText1!.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: Column(
        children: [
          SettingsListItem(
            image: getLanguageImage(controller.locale),
            title: AppLocalizations.of(context)!.language,
            subtitle: getLanguageName(controller.locale),
            onTap: changeLanguage,
          ),
          SettingsListItem(
            icon: Icons.settings_brightness,
            title: AppLocalizations.of(context)!.theme,
            subtitle: getThemeName(controller.themeMode),
            onTap: changeAppTheme,
          ),
          if (Provider.of<UserControllerImpl>(context).user != null)
            SettingsListItem(
              hasNavigation: false,
              icon: Icons.cancel,
              title: AppLocalizations.of(context)!.logout,
              onTap: () => _confirmSignOut(context),
            ),
        ],
      ),
    );
  }
}
