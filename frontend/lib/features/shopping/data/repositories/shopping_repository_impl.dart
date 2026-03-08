import '../../../../core/network/api_client.dart';
import '../../domain/entities/shopping.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../models/shopping_model.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final ApiClient _api;
  ShoppingRepositoryImpl(this._api);

  @override
  Future<List<ShoppingList>> getLists(String profileId) async {
    final res = await _api.get('/shopping/lists', params: {'profile_id': profileId});
    return (res.data as List)
        .map((j) => ShoppingListModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ShoppingList> createList(Map<String, dynamic> data) async {
    final res = await _api.post('/shopping/lists', data: data);
    return ShoppingListModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteList(String id) async {
    await _api.delete('/shopping/lists/$id');
  }

  @override
  Future<List<ShoppingItem>> getItems(String listId) async {
    final res = await _api.get('/shopping/lists/$listId/items');
    return (res.data as List)
        .map((j) => ShoppingItemModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ShoppingItem> addItem(String listId, Map<String, dynamic> data) async {
    final res = await _api.post('/shopping/lists/$listId/items', data: data);
    return ShoppingItemModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<ShoppingItem> updateItem(String id, Map<String, dynamic> data) async {
    final res = await _api.patch('/shopping/items/$id', data: data);
    return ShoppingItemModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _api.delete('/shopping/items/$id');
  }

  @override
  Future<void> clearDone(String listId) async {
    await _api.delete('/shopping/lists/$listId/done');
  }
}
