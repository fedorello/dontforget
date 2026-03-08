import '../entities/shopping.dart';

abstract interface class ShoppingRepository {
  Future<List<ShoppingList>> getLists(String profileId);
  Future<ShoppingList> createList(Map<String, dynamic> data);
  Future<void> deleteList(String id);
  Future<List<ShoppingItem>> getItems(String listId);
  Future<ShoppingItem> addItem(String listId, Map<String, dynamic> data);
  Future<ShoppingItem> updateItem(String id, Map<String, dynamic> data);
  Future<void> deleteItem(String id);
  Future<void> clearDone(String listId);
}
