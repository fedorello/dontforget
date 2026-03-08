import '../entities/todo.dart';

abstract interface class TodosRepository {
  Future<List<Todo>> getTodos(String profileId, {String filter});
  Future<Todo> createTodo(Map<String, dynamic> data);
  Future<Todo> updateTodo(String id, Map<String, dynamic> data);
  Future<void> deleteTodo(String id);
}
