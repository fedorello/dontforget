import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../cubit/shopping_list_cubit.dart';
import '../../domain/entities/shopping.dart';
import '../../../../shared/widgets/df_empty_state.dart';
import '../../../../shared/widgets/df_loading.dart';

class ShoppingListPage extends StatelessWidget {
  final String listId;
  const ShoppingListPage({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ShoppingListCubit>()..loadItems(listId),
      child: _ShoppingListView(listId: listId),
    );
  }
}

class _ShoppingListView extends StatefulWidget {
  final String listId;
  const _ShoppingListView({required this.listId});

  @override
  State<_ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<_ShoppingListView> {
  final _addCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _addCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _addCtrl.text.trim();
    if (text.isEmpty) return;
    context.read<ShoppingListCubit>().addItem(widget.listId, text);
    _addCtrl.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.shopping_title, style: AppTextStyles.heading3),
        actions: [
          TextButton.icon(
            onPressed: () => context
                .read<ShoppingListCubit>()
                .clearDone(widget.listId),
            icon: const Icon(Icons.clear_all, size: 18),
            label: Text(l10n.shopping_clear_done),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ShoppingListCubit, ShoppingListState>(
              builder: (context, state) {
                if (state is ShoppingListLoading) return const DfLoading();

                if (state is ShoppingListError) {
                  return Center(
                    child: Text(state.message, style: AppTextStyles.body2),
                  );
                }

                if (state is ShoppingListLoaded) {
                  if (state.items.isEmpty) {
                    return DfEmptyState(
                      emoji: '🛒',
                      message: l10n.shopping_empty,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      top: AppConstants.paddingS,
                      bottom: AppConstants.paddingM,
                    ),
                    itemCount: state.items.length,
                    itemBuilder: (context, i) {
                      final item = state.items[i];
                      return _ShoppingItemTile(
                        item: item,
                        onToggle: (v) => context
                            .read<ShoppingListCubit>()
                            .toggleItem(item.id, v),
                        onDelete: () => context
                            .read<ShoppingListCubit>()
                            .deleteItem(item.id),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Bottom input bar
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            padding: EdgeInsets.only(
              left: AppConstants.paddingM,
              right: AppConstants.paddingS,
              top: AppConstants.paddingS,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  AppConstants.paddingS,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addCtrl,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: l10n.shopping_add_item,
                        border: InputBorder.none,
                        filled: false,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _addItem(),
                    ),
                  ),
                  IconButton(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                    iconSize: 32,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _ShoppingItemTile({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.paddingM),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: Checkbox(
          value: item.isDone,
          onChanged: (v) => onToggle(v ?? false),
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
        ),
        title: Text(
          item.text,
          style: AppTextStyles.body1.copyWith(
            decoration: item.isDone ? TextDecoration.lineThrough : null,
            color: item.isDone ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
        subtitle: item.quantity != null && item.quantity!.isNotEmpty
            ? Text(item.quantity!, style: AppTextStyles.caption)
            : null,
        trailing: item.isDone
            ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
            : null,
      ),
    );
  }
}
