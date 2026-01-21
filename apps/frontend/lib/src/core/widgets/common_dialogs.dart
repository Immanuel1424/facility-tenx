import 'package:flutter/material.dart';

/// Common dialog widgets for consistent styling across the application.
/// All dialogs use the theme's dialogTheme for consistent appearance.
class CommonDialogs {
  CommonDialogs._();

  // Consistent dialog dimensions
  static const double _dialogWidthMobile = 400.0;
  static const double _dialogWidthDesktop =
      600.0; // Larger width for big screens
  static const double _dialogWidthFormMobile =
      500.0; // Wider for form dialogs on mobile
  static const double _dialogWidthFormDesktop =
      700.0; // Wider for form dialogs on desktop
  static const double _dialogMaxHeight =
      500.0; // Maximum height for all dialogs
  static const double _buttonHeight = 40.0; // Fixed height for all buttons

  static double _getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 768 ? _dialogWidthDesktop : _dialogWidthMobile;
  }

  static double _getFormDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 768 ? _dialogWidthFormDesktop : _dialogWidthFormMobile;
  }

  static Widget _buildDialogTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  /// Shows a confirmation dialog with consistent styling.
  ///
  /// [title] - The dialog title
  /// [content] - The dialog content (can be a String or Widget)
  /// [confirmText] - Text for the confirm button (default: 'Confirm')
  /// [cancelText] - Text for the cancel button (default: 'Cancel')
  /// [confirmColor] - Color for the confirm button (default: primary)
  /// [onConfirm] - Callback when confirm is pressed
  /// [onCancel] - Optional callback when cancel is pressed
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required dynamic content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final confirmButtonColor = confirmColor ?? colorScheme.primary;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _getDialogWidth(dialogContext),
            maxHeight: _dialogMaxHeight,
          ),
          child: AlertDialog(
            title: _buildDialogTitle(dialogContext, title),
            content: content is String
                ? Text(content)
                : content is Widget
                    ? content
                    : Text(content.toString()),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                  onCancel?.call();
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, _buttonHeight),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(cancelText),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmButtonColor,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size(0, _buttonHeight),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                child: Text(confirmText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a delete confirmation dialog with destructive styling.
  ///
  /// [title] - The dialog title (default: 'Delete')
  /// [content] - The dialog content (can be a String or Widget)
  /// [deleteText] - Text for the delete button (default: 'Delete')
  /// [cancelText] - Text for the cancel button (default: 'Cancel')
  /// [onDelete] - Callback when delete is pressed
  static Future<bool?> showDeleteDialog({
    required BuildContext context,
    String title = 'Delete',
    required dynamic content,
    String deleteText = 'Delete',
    String cancelText = 'Cancel',
    required VoidCallback onDelete,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _getDialogWidth(dialogContext),
            maxHeight: _dialogMaxHeight,
          ),
          child: AlertDialog(
            title: _buildDialogTitle(dialogContext, title),
            content: content is String
                ? Text(content)
                : content is Widget
                    ? content
                    : Text(content.toString()),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, _buttonHeight),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                child: Text(cancelText),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                  onDelete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  minimumSize: const Size(0, _buttonHeight),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                child: Text(deleteText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a form dialog with consistent styling.
  ///
  /// [title] - The dialog title
  /// [form] - The form widget to display
  /// [submitText] - Text for the submit button (default: 'Submit')
  /// [cancelText] - Text for the cancel button (default: 'Cancel')
  /// [onSubmit] - Callback when submit is pressed (receives the form key)
  /// [onCancel] - Optional callback when cancel is pressed
  static Future<bool?> showFormDialog({
    required BuildContext context,
    required String title,
    required Widget form,
    required GlobalKey<FormState> formKey,
    String submitText = 'Submit',
    String cancelText = 'Cancel',
    required VoidCallback onSubmit,
    VoidCallback? onCancel,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _getFormDialogWidth(dialogContext),
            maxHeight: _dialogMaxHeight,
          ),
          child: AlertDialog(
            title: _buildDialogTitle(dialogContext, title),
            content: SingleChildScrollView(
              child: form,
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                  onCancel?.call();
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, _buttonHeight),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(cancelText),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.of(dialogContext).pop(true);
                    onSubmit();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size(0, _buttonHeight),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                child: Text(submitText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a custom dialog with consistent styling.
  /// Allows full control over content and actions.
  ///
  /// [title] - The dialog title (optional)
  /// [content] - The dialog content widget
  /// [actions] - List of action buttons
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (dialogContext) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _getDialogWidth(dialogContext),
            maxHeight: _dialogMaxHeight,
          ),
          child: AlertDialog(
            title:
                title != null ? _buildDialogTitle(dialogContext, title) : null,
            content: SingleChildScrollView(
              child: content,
            ),
            actions: actions,
          ),
        ),
      ),
    );
  }
}
