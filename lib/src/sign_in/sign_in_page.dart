import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icon.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../settings/settings.view.dart';
import '../widgets/exception_alert_dialog.dart';
import '../widgets/social_button.dart';
import 'sign_in_manager.dart';

class SignInPageBuilder extends StatelessWidget {
  const SignInPageBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context, listen: false);

    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, ValueNotifier<bool> isLoading, __) =>
            Provider<SignInManager>(
          create: (_) => SignInManager(auth: auth, isLoading: isLoading),
          child: Consumer<SignInManager>(
            builder: (_, SignInManager manager, __) => SignInPage._(
              isLoading: isLoading.value,
              manager: manager,
            ),
          ),
        ),
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage._({Key? key, required this.isLoading, required this.manager})
      : super(key: key);

  final SignInManager manager;
  final bool isLoading;

  Future<void> showSignInError(
      BuildContext context, PlatformException exception) async {
    await ExceptionAlertDialog(
      title: AppLocalizations.of(context)!.signInFailed,
      exception: exception,
    ).show(context);
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      await manager.signInWithFacebook();
    } on PlatformException catch (e) {
      if (e.code != 'ERROR_ABORTED_BY_USER') {
        await showSignInError(context, e);
      }
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await manager.signInWithGoogle();
    } on PlatformException catch (e) {
      if (e.code != 'ERROR_ABORTED_BY_USER') {
        await showSignInError(context, e);
      }
    }
  }

  Widget buildSignIn(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.signIn,
            style: textTheme.headline2!.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 50),
          SocialButton(
            onPressed: () => signInWithFacebook(context),
            backgroundColor: const Color.fromRGBO(63, 91, 150, 1),
            height: 48,
            icon: FontAwesomeIcons.facebook,
            text: AppLocalizations.of(context)!.continueWithFacebook,
          ),
          const SizedBox(height: 10),
          SocialButton(
            onPressed: () => signInWithGoogle(context),
            backgroundColor: const Color.fromRGBO(66, 133, 244, 1),
            height: 48,
            icon: FontAwesomeIcons.google,
            text: AppLocalizations.of(context)!.continueWithGoogle,
          ),
        ],
      ),
    );
  }

  Widget buildLoadingIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.signIn),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsView.routeName),
            icon: LineIcon.cog(),
          ),
        ],
      ),
      body: isLoading ? buildLoadingIndicator(context) : buildSignIn(context),
    );
  }
}
