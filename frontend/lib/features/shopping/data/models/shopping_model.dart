import '../../domain/entities/shopping.dart';

class ShoppingListModel extends ShoppingList {
  const ShoppingListModel({
    required super.id,
    required super.profileId,
    required super.name,
    required super.emoji,
    required super.createdAt,
    required super.itemCount,
    required super.doneCount,
  });

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) =>
      ShoppingListModel(
        id: json['id'] as String,
        profileId: json['profile_id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String? ?? '🛒',
        createdAt: DateTime.parse(json['created_at'] as String),
        itemCount: json['item_count'] as int? ?? 0,
        doneCount: json['done_count'] as int? ?? 0,
      );
}

class ShoppingItemModel extends ShoppingItem {
  const ShoppingItemModel({
    required super.id,
    required super.listId,
    required super.text,
    super.quantity,
    super.category,
    required super.isDone,
    required super.position,
    required super.createdAt,
  });

  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) =>
      ShoppingItemModel(
        id: json['id'] as String,
        listId: json['list_id'] as String,
        text: json['text'] as String,
        quantity: json['quantity'] as String?,
        category: json['category'] as String?,
        isDone: json['is_done'] as bool? ?? false,
        position: json['position'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
