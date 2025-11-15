import 'package:flutter/material.dart';

class TestSearch extends StatefulWidget {
  const TestSearch({super.key});

  @override
  State<TestSearch> createState() => _TestSearchState();
}

class _TestSearchState extends State<TestSearch> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _items = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'];
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _items;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filter(String query) {
    debugPrint('TestSearch: Filtering with: "$query"');
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _items;
      } else {
        _filteredItems = _items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      debugPrint('TestSearch: Found ${_filteredItems.length} items');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Search items...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                debugPrint('TestSearch: onChanged called with: "$value"');
                _filter(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredItems[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
