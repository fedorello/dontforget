import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../medicines/domain/repositories/medicines_repository.dart';
import '../../../todos/domain/entities/todo.dart';
import '../../../todos/domain/repositories/todos_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final MedicinesRepository _medicinesRepo;
  final TodosRepository _todosRepo;

  DashboardCubit(this._medicinesRepo, this._todosRepo)
      : super(DashboardInitial());

  Future<void> load(String profileId, String profileName) async {
    emit(DashboardLoading());
    try {
      final results = await Future.wait([
        _medicinesRepo.getTodaySchedule(profileId),
        _todosRepo.getTodos(profileId, filter: 'today'),
      ]);

      final schedule = results[0] as List<Map<String, dynamic>>;
      final todos = results[1] as List<Todo>;

      emit(DashboardLoaded(
        scheduleItems: schedule,
        todosCount: todos.length,
        todayTodos: todos,
        profileName: profileName,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> markIntake(String logId, String status) async {
    try {
      await _medicinesRepo.updateIntakeLog(logId, status);
      final current = state;
      if (current is DashboardLoaded) {
        final updated = current.scheduleItems.map((item) {
          if (item['log_id'] == logId) {
            return {...item, 'status': status};
          }
          return item;
        }).toList();
        emit(DashboardLoaded(
          scheduleItems: updated,
          todosCount: current.todosCount,
          todayTodos: current.todayTodos,
          profileName: current.profileName,
        ));
      }
    } catch (_) {}
  }
}
