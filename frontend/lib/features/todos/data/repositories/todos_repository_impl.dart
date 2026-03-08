import '../../../../core/network/api_client.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../models/todo_model.dart';

class TodosRepositoryImpl implements TodosRepository {
  final ApiClient _api;
  TodosRepositoryImpl(this._api);

  @override
  Future<List<Todo>> getTodos(String profileId, {String filter = 'all'}) async {
    final res = await _api.get(
      '/todos/$profileId',
      params: {'filter': filter},
    );
    return (res.data as List)
        .map((j) => TodoModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Todo> createTodo(Map<String, dynamic> data) async {
    final res = await _api.post('/todos/', data: data);
    return TodoModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Todo> updateTodo(String id, Map<String, dynamic> data) async {
    final res = await _api.patch('/todos/$id', data: data);
    return TodoModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _api.delete('/todos/$id');
  }
}
