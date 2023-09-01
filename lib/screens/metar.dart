import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

import 'metar_store.dart';

class MetarPage extends StatelessWidget {
  const MetarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final metarStore = MetarStore();

    final dispose = reaction((_) => metarStore.hasAlert, (bool hasAlert) {
      // if there is an alert to show, show it in a snackbar
      if (hasAlert) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(metarStore.alertMessage),
          ),
        );
        metarStore.hasAlert = false;
        metarStore.alertMessage = "";
      }
    });

    metarStore.getSearchHistoryFromPrefs();

    final SearchController controller = SearchController();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SearchAnchor(
                // searchController: controller,
                builder: (BuildContext context, SearchController controller) {
              // return SearchBar(
              //   controller: controller,
              //   padding: const MaterialStatePropertyAll<EdgeInsets>(
              //     EdgeInsets.symmetric(horizontal: 16.0),
              //   ),
              //   onTap: () {
              //     controller.openView();
              //   },
              //   onChanged: (_) {
              //     controller.openView();
              //   },
              //   leading: const Icon(Icons.search),
              // );
              return IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  controller.openView();
                },
              );
            }, suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
              if (controller.text.isEmpty) {
                if (metarStore.searchHistory.isNotEmpty) {
                  return metarStore.getHistoryList(controller, context);
                }
                return [
                  const Center(
                    child: Text("No history"),
                  ),
                ];
              }
              return metarStore.getSuggestions(controller, context);
            }),
            Observer(
              builder: (_) => metarStore.isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      metarStore.metar != null
                          ? '${metarStore.metar?.raw}'
                          : "No data",
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
