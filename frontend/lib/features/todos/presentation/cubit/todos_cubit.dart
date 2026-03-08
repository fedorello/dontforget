import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';

part 'todos_state.dart';

class TodosCubit extends Cubit<TodosState> {
  final TodosRepository _repo;
  String? _currentProfileId;
  String _currentFilter = 'all';

  TodosCubit(this._repo) : super(TodosInitial());

  List<Todo> get _current =>
      state is TodosLoaded ? (state as TodosLoaded).todos : [];

  Future<void> loadTodos(String profileId, {String filter = 'all'}) async {
    _currentProfileId = profileId;
    _currentFilter = filter;
    emit(TodosLoading());
    try {
      final todos = await _repo.getTodos(profileId, filter: filter);
      emit(TodosLoaded(todos: todos, filter: filter));
    } catch (e) {
      emit(TodosError(e.toString()));
    }
  }

  Future<void> createTodo(
    String profileId,
    String text, {
    DateTime? dueAt,
    int priority = 0,
  }) async {
    try {
      final todo = await _repo.createTodo({
        'profile_id': profileId,
        'text': text,
        if (dueAt != null) 'due_at': dueAt.toIso8601String(),
        'priority': priority,
        'is_done': false,
        'tags': <String>[],
      });
      if (state is TodosLoaded) {
        final current = state as TodosLoaded;
        emit(current.copyWith(todos: [todo, ...current.todos]));
      } else {
        emit(TodosLoaded(todos: [todo], filter: _currentFilter));
      }
    } catch (e) {
      emit(TodosError(e.toString()));
    }
  }

  Future<void> toggleDone(String id, bool isDone) async {
    final updated = _current
        .map((t) =>
            t.id == id ? t.copyWith(isDone: isDone, doneAt: isDone ? DateTime.now() : null) : t)
        .toList();
    if (state is TodosLoaded) {
      emit((state as TodosLoaded).copyWith(todos: updated));
    }
    try {
      await _repo.updateTodo(id, {
        'is_done': isDone,
        'done_at': isDone ? DateTime.now().toIso8601String() : null,
      });
    } catch (e) {
      if (state is TodosLoaded) {
        emit((state as TodosLoaded).copyWith(todos: _current));
      }
      emit(TodosError(e.toString()));
    }
  }

  Future<void> deleteTodo(String id) async {
    final without = _current.where((t) => t.id != id).toList();
    if (state is TodosLoaded) {
      emit((state as TodosLoaded).copyWith(todos: without));
    }
    try {
      await _repo.deleteTodo(id);
    } catch (e) {
      if (state is TodosLoaded) {
        emit((state as TodosLoaded).copyWith(todos: _current));
      }
      emit(TodosError(e.toString()));
    }
  }

  Future<void> changeFilter(String filter) async {
    if (_currentProfileId == null) return;
    _currentFilter = filter;
    if (state is TodosLoaded) {
      emit((state as TodosLoaded).copyWith(filter: filter));
    }
    await loadTodos(_currentProfileId!, filter: filter);
  }
}
