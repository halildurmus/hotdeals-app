import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:line_icons/line_icon.dart';
import 'package:provider/provider.dart';

import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../settings/settings.view.dart';
import '../sign_in/sign_in_page.dart';
import '../utils/navigation_util.dart';
import 'avatar_fullscreen.dart';
import 'my_deals.dart';
import 'my_favorites.dart';
import 'my_notifications.dart';
import 'update_profile.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  static const String routeName = '/profile';

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final MyUser? user = Provider.of<UserControllerImpl>(context).user;

    Widget buildAvatar() {
      return GestureDetector(
        onTap: () => NavigationUtil.navigate(
          context,
          AvatarFullScreen(avatarURL: user!.avatar!, heroTag: user.id!),
        ),
        child: Hero(
          tag: user!.id!,
          child: CircleAvatar(
            backgroundImage: NetworkImage(user.avatar!),
            radius: 50,
          ),
        ),
      );
    }

    Widget buildUpdateProfileButton() {
      return SizedBox(
        width: 150,
        child: OutlinedButton(
          onPressed: () =>
              NavigationUtil.navigate(context, const UpdateProfile()),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(AppLocalizations.of(context)!.updateProfile),
        ),
      );
    }

    Widget buildProfileDetails() {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            buildAvatar(),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user!.nickname!, style: textTheme.headline6),
                const SizedBox(height: 5),
                Text(user.email!, style: textTheme.caption),
                const SizedBox(height: 5),
                buildUpdateProfileButton(),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildTabBar() {
      return Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.only(bottom: 2),
        child: Center(
          child: TabBar(
            indicatorColor: theme.primaryColor,
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            labelColor: theme.primaryColor,
            unselectedLabelColor: theme.primaryColorLight,
            labelStyle: textTheme.bodyText2!.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: AppLocalizations.of(context)!.notifications),
              Tab(text: AppLocalizations.of(context)!.posts),
              Tab(text: AppLocalizations.of(context)!.favorites),
            ],
          ),
        ),
      );
    }

    Widget buildTabBarView() {
      return const TabBarView(
        children: [MyNotifications(), MyDeals(), MyFavorites()],
      );
    }

    Widget buildProfile() {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profile),
          actions: [
            IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(SettingsView.routeName),
              icon: LineIcon.cog(),
            ),
          ],
        ),
        body: DefaultTabController(
          length: 3,
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool value) {
              return [
                SliverToBoxAdapter(child: buildProfileDetails()),
                SliverToBoxAdapter(child: buildTabBar()),
              ];
            },
            body: buildTabBarView(),
          ),
        ),
      );
    }

    return user == null ? const SignInPageBuilder() : buildProfile();
  }
}
