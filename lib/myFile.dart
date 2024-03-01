import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'hive_dbHelper.dart';
import 'modelclass.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ShoppingItemAdapter());
  await hive().openHiveBox();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<ShoppingItem> _items = [];
  final hive dbHelper = hive();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshItems();
  }
  Future<void> _refreshItems() async {
    final items = await dbHelper.getAllItems();
    setState(() {
      _items = items;
    });
  }
  void _showForm(BuildContext context, int? itemKey) async {
    if(itemKey != null){
      final existingItems =
      _items.firstWhere((element) => element.key == itemKey);
      _nameController.text = existingItems.name;
      _quantityController.text = existingItems.quantity.toString();
    }
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_)=> Container(
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
              decoration: InputDecoration(hintText: 'name'),
            ),
            SizedBox(height: 10,),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(hintText: 'quantity'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: ()async{
                if(itemKey == null){
                  dbHelper.createItem(ShoppingItem(
                    name: _nameController.text,
                    quantity: int.parse(_quantityController.text),)
                  );
                }
                if(itemKey != null){
                  dbHelper.updateItem(itemKey, ShoppingItem(
                    name: _nameController.text,
                    quantity: int.parse(_quantityController.text),
                  ));
                }
                _nameController.text ='';
                _quantityController.text ='';
                Navigator.pop(context);
                _refreshItems();
              },
              child: Text(itemKey==null ? 'Add Item': 'Update'),),
          ],
        ),
      ),
    );
  }
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hive-db Example'),
        ),
        body: _items.isEmpty ? const Center(child: Text('No Items'),
        ) : ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index){
              final currentItem = _items[index];
              return Card(
                color: Colors.greenAccent,
                elevation: 3,
                child: ListTile(
                  title: Text(currentItem.name),
                  subtitle: Text(currentItem.quantity.toString()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: (){
                          _showForm(context, currentItem.key);
                        },
                        icon: Icon(Icons.edit),),
                      SizedBox(width: 10,),
                      IconButton(
                        onPressed: (){
                          dbHelper.deleteItem(currentItem.key);
                        },
                        icon: Icon(Icons.delete),),
                    ],
                  ),
                ),
              );
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(context, null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

