import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  List<GroceryItem> _groceryItems = [];
  void _loadItems() async {
    final url = Uri.https(
      "flutter-course-e8679-default-rtdb.europe-west1.firebasedatabase.app",
      "shopping-list.json",
    );
    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> _loadedItems = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      _loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItems = _loadedItems;
    });
  }

  void _addItem() async {
    await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _groceryItems.isEmpty
        ? const Center(
            child: Text("No items"),
          )
        : ListView.builder(
            itemCount: _groceryItems.length,
            itemBuilder: (ctx, index) => Dismissible(
              background: Container(
                color: Colors.red,
              ),
              key: ValueKey(_groceryItems[index].id),
              onDismissed: (direction) {
                setState(() {
                  _groceryItems.remove(_groceryItems[index]);
                });
              },
              child: ListTile(
                title: Text(_groceryItems[index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: _groceryItems[index].category.color,
                ),
                trailing: Text(
                  _groceryItems[index].quantity.toString(),
                ),
              ),
            ),
          );

    return Scaffold(
        appBar: AppBar(title: const Text('Your Groceries'), actions: [
          IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
        ]),
        body: content);
  }
}
