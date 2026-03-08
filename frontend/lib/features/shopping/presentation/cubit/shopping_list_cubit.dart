import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/shopping.dart';
import '../../domain/repositories/shopping_repository.dart';

part 'shopping_list_state.dart';

class ShoppingListCubit extends Cubit<ShoppingListState> {
  final ShoppingRepository _repo;
  ShoppingListCubit(this._repo) : super(ShoppingListInitial());

  List<ShoppingItem> get _current =>
      state is ShoppingListLoaded ? (state as ShoppingListLoaded).items : [];

  Future<void> loadItems(String listId) async {
    emit(ShoppingListLoading());
    try {
      final items = await _repo.getItems(listId);
      emit(ShoppingListLoaded(_sorted(items)));
    } catch (e) {
      emit(ShoppingListError(e.toString()));
    }
  }

  Future<void> addItem(
      String listId, String text, {String? quantity}) async {
    try {
      final item = await _repo.addItem(listId, {
        'text': text,
        if (quantity != null && quantity.isNotEmpty) 'quantity': quantity,
        'position': _current.length,
      });
      emit(ShoppingListLoaded(_sorted([..._current, item])));
    } catch (e) {
      emit(ShoppingListError(e.toString()));
    }
  }

  Future<void> toggleItem(String itemId, bool isDone) async {
    final updated =
        _current.map((i) => i.id == itemId ? i.copyWith(isDone: isDone) : i).toList();
    emit(ShoppingListLoaded(_sorted(updated)));
    try {
      await _repo.updateItem(itemId, {'is_done': isDone});
    } catch (e) {
      emit(ShoppingListLoaded(_sorted(_current)));
      emit(ShoppingListError(e.toString()));
    }
  }

  Future<void> deleteItem(String itemId) async {
    final withoutItem = _current.where((i) => i.id != itemId).toList();
    emit(ShoppingListLoaded(withoutItem));
    try {
      await _repo.deleteItem(itemId);
    } catch (e) {
      emit(ShoppingListLoaded(_current));
      emit(ShoppingListError(e.toString()));
    }
  }

  Future<void> clearDone(String listId) async {
    try {
      await _repo.clearDone(listId);
      emit(ShoppingListLoaded(_current.where((i) => !i.isDone).toList()));
    } catch (e) {
      emit(ShoppingListError(e.toString()));
    }
  }

  List<ShoppingItem> _sorted(List<ShoppingItem> items) {
    final undone = items.where((i) => !i.isDone).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    final done = items.where((i) => i.isDone).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return [...undone, ...done];
  }
}
