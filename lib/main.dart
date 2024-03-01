import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'hive_dbHelper.dart';
import 'modelclass.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ShoppingItemAdapter());
  await hive().openHiveBox();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hive Example',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ShoppingItem> _items = [];
  final hive dbHelper = hive();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  Future<void> _refreshItems() async {
    final items = await dbHelper.getAllItems();
    setState(() {
      _items = items;
    });
  }
// Future<void>
  void _showForm(BuildContext context, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
      _items.firstWhere((element) => element.key == itemKey);
      _nameController.text = existingItem.name;
      _quantityController.text = existingItem.quantity.toString();
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 15,
          left: 15,
          right: 15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Quantity'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {

                if (itemKey == null) {
                  dbHelper.createItem(ShoppingItem(
                    name: _nameController.text,
                    quantity: int.parse(_quantityController.text),
                  ));
                }

                if (itemKey != null) {
                  dbHelper.updateItem(itemKey, ShoppingItem(
                    name: _nameController.text,
                    quantity: int.parse(_quantityController.text),
                  ));
                }

                _nameController.text = '';
                _quantityController.text = '';

                Navigator.of(context).pop(); // Close the bottom sheet
                _refreshItems(); // Update the UI
              },
              child: Text(itemKey == null ? 'Add Item' : 'Update'),
            ),
            const SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hive Example'),
        ),
        body: _items.isEmpty ? const Center(child: Text('No Items',
          style: TextStyle(fontSize: 30),
        ),
        )
            : ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final currentItem = _items[index];
            return Card(
              color: Colors.orange.shade100,
              margin: const EdgeInsets.all(10),
              elevation: 3,
              child: ListTile(
                title: Text(currentItem.name),
                subtitle: Text(currentItem.quantity.toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showForm(context, currentItem.key)),
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: ()async{
                          dbHelper.deleteItem(currentItem.key);
                          _refreshItems();
                        }
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(context, null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}