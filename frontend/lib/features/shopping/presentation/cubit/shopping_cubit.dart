import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/shopping.dart';
import '../../domain/repositories/shopping_repository.dart';

part 'shopping_state.dart';

class ShoppingCubit extends Cubit<ShoppingState> {
  final ShoppingRepository _repo;
  ShoppingCubit(this._repo) : super(ShoppingInitial());

  Future<void> loadLists(String profileId) async {
    emit(ShoppingLoading());
    try {
      final lists = await _repo.getLists(profileId);
      emit(ShoppingLoaded(lists));
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> createList(
      String profileId, String name, String emoji) async {
    final current = state is ShoppingLoaded
        ? (state as ShoppingLoaded).lists
        : <ShoppingList>[];
    try {
      final list = await _repo.createList({
        'profile_id': profileId,
        'name': name,
        'emoji': emoji,
      });
      emit(ShoppingLoaded([...current, list]));
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> deleteList(String id) async {
    final current = state is ShoppingLoaded
        ? (state as ShoppingLoaded).lists
        : <ShoppingList>[];
    try {
      await _repo.deleteList(id);
      emit(ShoppingLoaded(current.where((l) => l.id != id).toList()));
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }
}
