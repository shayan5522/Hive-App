import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'modelclass.dart';

class hive{

  final String _boxName= 'Shopping-Box';
  Future<void> openHiveBox() async{
    // Hive.initFlutter();
    await Hive.openBox<ShoppingItem>(_boxName);
  }

  Box<ShoppingItem> get _shoppingBox => Hive.box<ShoppingItem>(_boxName);
  Future<void> createItem(ShoppingItem newItem) async{
    await _shoppingBox.add(newItem);
  }
  Future<List<ShoppingItem>> getAllItems() async {
    return _shoppingBox.values.toList();
  }
  Future<void> updateItem(int itemKey, ShoppingItem newItem) async {
    await _shoppingBox.put(itemKey, newItem);
  }
  Future<void> deleteItem(int itemKey) async {
    if(itemKey != null){
      _shoppingBox.delete(itemKey);
    }
  }
}