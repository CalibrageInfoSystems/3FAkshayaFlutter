import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common_utils/common_styles.dart';
import '../../../localization/locale_keys.dart';

class EncyclopediaActivity extends StatelessWidget {
  final List<String> tabNames;
  final String appBarTitle;

  EncyclopediaActivity({required this.tabNames, required this.appBarTitle});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabNames.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          bottom: TabBar(
            tabs: tabNames.map((name) => Tab(text: name)).toList(),
          ),
        ),
        body: TabBarView(
          children: tabNames.map((name) {
            // Replace this with the corresponding widget for each tab
            return Center(child: Text('Content for $name'));
          }).toList(),
        ),
      ),
    );
  }
}

