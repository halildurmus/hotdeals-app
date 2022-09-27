import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common_widgets/exception_alert_dialog.dart';
import '../../../common_widgets/social_button.dart';
import '../../../helpers/context_extensions.dart';
import '../../../l10n/localization_constants.dart';
import '../data/firebase_auth_repository.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  static const String routeName = '/sign-in';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authApi = ref.read(authApiProvider);
    if (authApi.currentUser != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(context.t.primaryColor),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.l.signIn),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l.signIn,
              style: context.textTheme.headline2!.copyWith(
                color: context.t.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            Wrap(
              runSpacing: 12,
              children: [
                SocialButton.facebook(
                  onPressed: () async {
                    try {
                      await authApi.signInWithFacebook();
                    } on PlatformException catch (e) {
                      await ExceptionAlertDialog(
                        title: context.l.signInFailed,
                        exception: e,
                      ).show(context);
                    }
                  },
                  text: context.l.continueWithFacebook,
                ),
                SocialButton.google(
                  onPressed: () async {
                    try {
                      await authApi.signInWithGoogle();
                    } on PlatformException catch (e) {
                      await ExceptionAlertDialog(
                        title: context.l.signInFailed,
                        exception: e,
                      ).show(context);
                    }
                  },
                  text: context.l.continueWithGoogle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
