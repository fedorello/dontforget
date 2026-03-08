part of 'todos_cubit.dart';

abstract class TodosState extends Equatable {
  const TodosState();
  @override
  List<Object?> get props => [];
}

class TodosInitial extends TodosState {}

class TodosLoading extends TodosState {}

class TodosLoaded extends TodosState {
  final List<Todo> todos;
  final String filter;

  const TodosLoaded({required this.todos, required this.filter});

  TodosLoaded copyWith({List<Todo>? todos, String? filter}) => TodosLoaded(
        todos: todos ?? this.todos,
        filter: filter ?? this.filter,
      );

  @override
  List<Object?> get props => [todos, filter];
}

class TodosError extends TodosState {
  final String message;
  const TodosError(this.message);
  @override
  List<Object?> get props => [message];
}
