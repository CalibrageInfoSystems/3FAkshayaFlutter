import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWid extends StatelessWidget {
  final Widget? child;
  const ShimmerWid({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.separated(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: child ?? shimmerCard());
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 10);
        },
      ),
    );
  }

  Widget shimmerCard() {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: decoration(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              flex: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 20,
                    decoration: decoration(),
                  ),
                  Container(
                    height: 20,
                    decoration: decoration(),
                  ),
                  Container(
                    height: 20,
                    decoration: decoration(),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  BoxDecoration decoration() {
    return BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(10.0),
    );
  }
}
