import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;
import 'package:provider/provider.dart';

import '../models/deal.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../widgets/deal_list_item_builder.dart';

class MyFavorites extends StatefulWidget {
  const MyFavorites({Key? key}) : super(key: key);

  @override
  _MyFavoritesState createState() => _MyFavoritesState();
}

class _MyFavoritesState extends State<MyFavorites> with NetworkLoggy {
  @override
  Widget build(BuildContext context) {
    Provider.of<UserControllerImpl>(context).user!;

    return FutureBuilder<List<Deal>?>(
      future: GetIt.I.get<SpringService>().getUserFavorites(),
      builder: (BuildContext context, AsyncSnapshot<List<Deal>?> snapshot) {
        if (snapshot.hasData) {
          final List<Deal> deals = snapshot.data!;

          if (deals.isEmpty) {
            return Center(
              child: Text(
                  AppLocalizations.of(context)!.youHaveNotFavoritedAnyDeal),
            );
          }

          return DealListItemBuilder(deals: deals);
        } else if (snapshot.hasError) {
          loggy.error(snapshot.error, snapshot.error);

          return Center(
            child: Text(AppLocalizations.of(context)!.anErrorOccurred),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
