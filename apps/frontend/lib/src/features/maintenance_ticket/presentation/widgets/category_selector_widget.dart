import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/maintenance_ticket_bloc.dart';
import '../bloc/maintenance_ticket_event.dart';
import '../bloc/maintenance_ticket_state.dart';
import '../../domain/entities/ticket_category_entity.dart';

class CategorySelectorWidget extends StatefulWidget {
  const CategorySelectorWidget({
    super.key,
    this.selectedCategoryId,
    this.onChanged,
    this.enabled = true,
  });

  final String? selectedCategoryId;
  final ValueChanged<String?>? onChanged;
  final bool enabled;

  @override
  State<CategorySelectorWidget> createState() => _CategorySelectorWidgetState();
}

class _CategorySelectorWidgetState extends State<CategorySelectorWidget> {
  bool _hasAttemptedLoad = false;

  @override
  void initState() {
    super.initState();
    // Load categories once when widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasAttemptedLoad) {
        final bloc = context.read<MaintenanceTicketBloc>();
        final cachedCategories = bloc.cachedCategories;
        if (cachedCategories.isEmpty) {
          _hasAttemptedLoad = true;
          bloc.add(const LoadCategories());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
      builder: (context, state) {
        final bloc = context.read<MaintenanceTicketBloc>();
        List<TicketCategoryEntity> categories = [];
        bool isLoading = false;

        // Check if we have cached categories first
        final cachedCategories = bloc.cachedCategories;
        final hasCachedCategories = cachedCategories.isNotEmpty;

        if (state is MaintenanceTicketLoading && !hasCachedCategories) {
          isLoading = true;
        } else if (state is CategoriesLoaded) {
          categories = state.categories;
          isLoading = false;
        } else if (hasCachedCategories) {
          // Use cached categories if available
          categories = cachedCategories;
          isLoading = false;
        } else {
          // No categories available yet, but not loading (initial state)
          categories = [];
          isLoading = false;
        }

        // Separate root and child categories
        final rootCategories = categories.where((c) => c.isRoot).toList();
        final childCategories = categories.where((c) => !c.isRoot).toList();

        // Group child categories by parent
        final Map<String, List<TicketCategoryEntity>> childrenByParent = {};
        for (final child in childCategories) {
          final parentId = child.parentCategoryId ?? '';
          if (!childrenByParent.containsKey(parentId)) {
            childrenByParent[parentId] = [];
          }
          childrenByParent[parentId]!.add(child);
        }

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        if (isLoading) {
          return DropdownButtonFormField<String>(
            isExpanded: true,
            items: const [],
            onChanged: null,
            decoration: InputDecoration(
              labelText: 'Loading categories...',
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        // Build hierarchical dropdown items
        final items = <DropdownMenuItem<String?>>[
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('-- Select Category --'),
          ),
        ];

        // Add root categories
        for (final root in rootCategories) {
          items.add(
            DropdownMenuItem<String?>(
              value: root.id,
              child: Text(root.displayName),
            ),
          );

          // Add child categories indented
          final children = childrenByParent[root.id] ?? [];
          for (final child in children) {
            items.add(
              DropdownMenuItem<String?>(
                value: child.id,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text('  └ ${child.displayName}'),
                ),
              ),
            );
          }
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String?>(
            isExpanded: true,
            value: widget.selectedCategoryId,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '-- Select Category --',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: items,
            onChanged: widget.enabled
                ? (String? value) {
                    widget.onChanged?.call(value);
                  }
                : null,
          ),
        );
      },
    );
  }
}

