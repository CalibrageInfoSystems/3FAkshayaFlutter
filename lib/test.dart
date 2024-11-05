/* import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Item {
  final String title;
  final String description;

  Item(this.title, this.description);
}

class TestScreen extends StatelessWidget {
  // Sample list with titles and descriptions
  final List<Item> items = [
    Item("Short Title", "Short description"),
    Item("A Much Longer Title",
        "A much longer description that takes more space."),
    Item("Another Short Title", "Another short description"),
    Item("Title with Lots of Text",
        "This is a longer description that takes up more space and demonstrates how the grid item grows based on content."),
    Item("Short Title", "Short description"),
    Item("A Longer Title", "Another description that is fairly long."),
    Item("Short Title", "A very long description to test height adjustment."),
    Item("Another Short Title", "A short description for testing."),
  ];

  TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staggered Grid Example')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(
                      Icons.home,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class TestScreen extends StatelessWidget {
  final String pdfUrl =
      'https://www.antennahouse.com/hubfs/xsl-fo-sample/pdf/basic-link-1.pdf'; // Replace with your PDF URL

  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer Dialog Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("PDF Viewer"),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 500, // Set a suitable height for the dialog
                  child: SfPdfViewer.network(pdfUrl),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Close"),
                  ),
                ],
              ),
            );
          },
          child: const Text("Open PDF Dialog"),
        ),
      ),
    );
  }
}
