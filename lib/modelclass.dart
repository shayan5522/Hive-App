import 'package:hive/hive.dart';

part 'modelclass.g.dart';

@HiveType(typeId: 0)
class ShoppingItem extends HiveObject{
  @HiveField(1)
  late String name;

  @HiveField(2)
  late int quantity;

  ShoppingItem({required this.name, required this.quantity});
}
