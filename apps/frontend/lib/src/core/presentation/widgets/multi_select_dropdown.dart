import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class MultiSelectDropdown<T> extends FormBuilderField<List<T>> {
  MultiSelectDropdown({
    super.key,
    required super.name,
    required this.items,
    this.itemAsString,
    super.validator,
    super.initialValue,
    super.enabled,
    super.onChanged,
    super.valueTransformer,
    super.onSaved,
    super.autovalidateMode,
    super.onReset,
    super.focusNode,
    this.decoration = const InputDecoration(),
    this.title = const Text('Select Options'),
    this.searchable = false,
  }) : super(
          builder: (FormFieldState<List<T>> field) {
            final state = field as _MultiSelectDropdownState<T>;
            final theme = Theme.of(state.context);

            return InputDecorator(
              decoration: decoration.copyWith(
                errorText: state.errorText,
                suffixIcon: decoration.suffixIcon ??
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: state.enabled ? state._handleTap : null,
                    ),
              ),
              isEmpty: state.value == null || state.value!.isEmpty,
              child: InkWell(
                onTap: state.enabled ? state._handleTap : null,
                child: Text(
                  (state.value == null || state.value!.isEmpty)
                      ? decoration.hintText ?? ''
                      : state.value!
                          .map((e) => itemAsString?.call(e) ?? e.toString())
                          .join(', '),
                  style: (state.value == null || state.value!.isEmpty)
                      ? theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        )
                      : theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );

  final List<T> items;
  final String Function(T)? itemAsString;
  final InputDecoration decoration;
  final Widget title;
  final bool searchable;

  @override
  FormBuilderFieldState<MultiSelectDropdown<T>, List<T>> createState() =>
      _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T>
    extends FormBuilderFieldState<MultiSelectDropdown<T>, List<T>> {
  Future<void> _handleTap() async {
    final selectedValues = await showDialog<List<T>>(
      context: context,
      builder: (context) {
        return _MultiSelectDialog<T>(
          items: widget.items,
          initialSelectedValues: value ?? [],
          itemAsString: widget.itemAsString,
          title: widget.title,
        );
      },
    );

    if (selectedValues != null) {
      didChange(selectedValues);
    }
  }
}

class _MultiSelectDialog<T> extends StatefulWidget {
  const _MultiSelectDialog({
    required this.items,
    required this.initialSelectedValues,
    this.itemAsString,
    required this.title,
  });

  final List<T> items;
  final List<T> initialSelectedValues;
  final String Function(T)? itemAsString;
  final Widget title;

  @override
  State<_MultiSelectDialog<T>> createState() => _MultiSelectDialogState<T>();
}

class _MultiSelectDialogState<T> extends State<_MultiSelectDialog<T>> {
  late List<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = List.from(widget.initialSelectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items.map((item) {
            final checked = _selectedValues.contains(item);
            return CheckboxListTile(
              value: checked,
              title: Text(widget.itemAsString?.call(item) ?? item.toString()),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedValues.add(item);
                  } else {
                    _selectedValues.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedValues),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
