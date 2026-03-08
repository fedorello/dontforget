part of 'shopping_list_cubit.dart';

abstract class ShoppingListState extends Equatable {
  const ShoppingListState();
  @override
  List<Object?> get props => [];
}

class ShoppingListInitial extends ShoppingListState {}

class ShoppingListLoading extends ShoppingListState {}

class ShoppingListLoaded extends ShoppingListState {
  final List<ShoppingItem> items;
  const ShoppingListLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

class ShoppingListError extends ShoppingListState {
  final String message;
  const ShoppingListError(this.message);
  @override
  List<Object?> get props => [message];
}
