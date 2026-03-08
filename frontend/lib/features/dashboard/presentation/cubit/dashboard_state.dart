part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<Map<String, dynamic>> scheduleItems;
  final int todosCount;
  final List<Todo> todayTodos;
  final String profileName;

  const DashboardLoaded({
    required this.scheduleItems,
    required this.todosCount,
    required this.todayTodos,
    required this.profileName,
  });

  @override
  List<Object?> get props =>
      [scheduleItems, todosCount, todayTodos, profileName];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
