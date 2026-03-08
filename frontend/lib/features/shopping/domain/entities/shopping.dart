class ShoppingList {
  final String id;
  final String profileId;
  final String name;
  final String emoji;
  final DateTime createdAt;
  final int itemCount;
  final int doneCount;

  const ShoppingList({
    required this.id,
    required this.profileId,
    required this.name,
    required this.emoji,
    required this.createdAt,
    required this.itemCount,
    required this.doneCount,
  });
}

class ShoppingItem {
  final String id;
  final String listId;
  final String text;
  final String? quantity;
  final String? category;
  final bool isDone;
  final int position;
  final DateTime createdAt;

  const ShoppingItem({
    required this.id,
    required this.listId,
    required this.text,
    this.quantity,
    this.category,
    required this.isDone,
    required this.position,
    required this.createdAt,
  });

  ShoppingItem copyWith({bool? isDone}) => ShoppingItem(
        id: id,
        listId: listId,
        text: text,
        quantity: quantity,
        category: category,
        isDone: isDone ?? this.isDone,
        position: position,
        createdAt: createdAt,
      );
}
