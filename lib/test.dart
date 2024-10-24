import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedListAndGrid extends StatelessWidget {
  const AnimatedListAndGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          title: const Text('Animated List & Grid'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'List'),
              Tab(text: 'Grid'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AnimatedListExample(),
            AnimatedGridExample(),
          ],
        ),
      ),
    );
  }
}

class AnimatedListExample extends StatefulWidget {
  const AnimatedListExample({super.key});

  @override
  State<AnimatedListExample> createState() => _AnimatedListExampleState();
}

class _AnimatedListExampleState extends State<AnimatedListExample> {
  Future<void> launchFromDatePicker(BuildContext context,
      {required DateTime firstDate,
      required DateTime lastDate,
      DateTime? initialDate}) async {
    final DateTime? pickedDay = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
    );
    if (pickedDay != null) {}
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        Assets.images.homeIcon.path,
        width: 25,
        height: 25,
        fit: BoxFit.contain,
        color: Colors.black.withOpacity(0.6),
      ),
    );
  }
}

class AnimatedGridExample extends StatelessWidget {
  const AnimatedGridExample({super.key});

  @override
  Widget build(BuildContext context) {
    final gridItems = List.generate(20, (index) => 'Grid Item $index');
    return LiveGrid.options(
      options: const LiveOptions(
        delay: Duration(milliseconds: 100),
        showItemInterval: Duration(milliseconds: 100),
        showItemDuration: Duration(milliseconds: 250),
        reAnimateOnVisibility: false,
      ),
      itemCount: gridItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            child: Card(
              color: Colors.blueAccent,
              child: Center(
                child: Text(
                  gridItems[index],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
