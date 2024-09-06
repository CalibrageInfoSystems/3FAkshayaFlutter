import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/models/important_places_model.dart';
import 'package:akshaya_flutter/screens/my3f_screen.dart/screens/godowns_content_screen.dart';
import 'package:akshaya_flutter/screens/my3f_screen.dart/screens/collection_content_screen.dart';
import 'package:akshaya_flutter/screens/my3f_screen.dart/screens/mills_content_screen.dart';
import 'package:akshaya_flutter/screens/my3f_screen.dart/screens/nurseries_content_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../localization/locale_keys.dart';

class ImportantPlacesScreen extends StatefulWidget {
  final ImportantPlaces data;
  const ImportantPlacesScreen({super.key, required this.data});

  @override
  State<ImportantPlacesScreen> createState() => _ImportantPlacesScreenState();
}

class _ImportantPlacesScreenState extends State<ImportantPlacesScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return
      DefaultTabController(
      length: 4,
      child:
      Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Container(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: CommonStyles.primaryTextColor,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Stack(
                children: [
                  TabBar(
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 1),
                    indicatorSize: TabBarIndicatorSize.tab,
                    unselectedLabelColor: CommonStyles.primaryTextColor,
                    indicator: BoxDecoration(
                      color: CommonStyles.primaryTextColor,
                      borderRadius: borderForSelectedTab(selectedTab),
                    ),
                    onTap: (tab) {
                      setState(() {
                        selectedTab = tab;
                      });
                    },
                    labelStyle:  CommonStyles.txSty_12p_f5,
                    tabs:  [
                      Tab(
                        child: Text(
                          tr(LocaleKeys.fertgodown),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                         // style: CommonStyles.txSty_12p_f5,
                        ),
                      ),
                      Tab(
                        child: Text(
                          tr(LocaleKeys.collection_centres),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                         // style: CommonStyles.txSty_12p_f5,
                        ),
                      ),
                      Tab( child: Text(
                        tr(LocaleKeys.Mills),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                      //  style: CommonStyles.txSty_12p_f5,
                      ),),
                      Tab(child: Text(
                        tr(LocaleKeys.Nurseries),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                      //  style: CommonStyles.txSty_12p_f5,
                      ),),
                    ],
                  ),
                  Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(child: Container()),
                        Container(
                          width: 1.0,
                          color: CommonStyles.primaryTextColor,
                        ),
                        Expanded(child: Container()),
                        Container(
                          width: 1.0,
                          color: CommonStyles.primaryTextColor,
                        ),
                        Expanded(child: Container()),
                        Container(
                          width: 1.0,
                          color: CommonStyles.primaryTextColor,
                        ),
                        Expanded(child: Container()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TabBarView(
            children: [
              GoDownsScreen(godowns: widget.data.godowns!),
              CollectionContentScreen(data: widget.data.collectionCenters!),
              MillsContentScreen(mills: widget.data.mills!),
              NurseriesContentScreen(nurseries: widget.data.nurseries!),
              /*  PlaceTemplate1(),
              PlaceTemplate2(),
              PlaceTemplate2(),
              PlaceTemplate2(), */
            ],
          ),
        ),
      ),
    );
  }

  BorderRadius borderForSelectedTab(int selectedTab) {
    print('selectedTab: $selectedTab');
    switch (selectedTab) {
      case 0:
        return const BorderRadius.only(
          topLeft: Radius.circular(4.0),
          bottomLeft: Radius.circular(4.0),
        );
      case 3:
        return const BorderRadius.only(
          topRight: Radius.circular(4.0),
          bottomRight: Radius.circular(4.0),
        );
      default:
        return const BorderRadius.all(Radius.circular(0));
    }
  }
}
