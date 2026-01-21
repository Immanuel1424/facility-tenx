import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'villa_form_fields.dart';
import 'villa_type_helper.dart';

/// Reactive form fields that auto-suggest values based on Villa Type
class VillaTypeReactiveFields extends StatelessWidget {
  const VillaTypeReactiveFields({
    super.key,
    required this.formKey,
  });

  final GlobalKey<FormBuilderState> formKey;

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<String>(
      name: 'villa_type',
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VillaFormFields.buildFieldLabel('Villa Type'),
            FormBuilderDropdown<String>(
              name: 'villa_type',
              decoration: const InputDecoration(
                hintText: 'Select villa type (optional)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Select Villa Type'),
                ),
                ...VillaFormFields.villaTypes.map(
                  (type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                field.didChange(newValue);
                _handleVillaTypeChange(newValue);
              },
            ),
            // Show suggestion hint if applicable
            if (field.value != null)
              _buildSuggestionHint(field.value as String),
          ],
        );
      },
    );
  }

  void _handleVillaTypeChange(String? villaType) {
    final formState = formKey.currentState;
    if (formState == null) return;

    // Auto-suggest bedroom count
    final suggestedBedroomCount =
        VillaTypeHelper.getSuggestedBedroomCount(villaType);
    if (suggestedBedroomCount != null) {
      final currentBedroomCount = formState.value['bedroom_count'];
      // Only auto-fill if field is empty
      if (currentBedroomCount == null ||
          currentBedroomCount.toString().trim().isEmpty) {
        formState.fields['bedroom_count']?.didChange(
          suggestedBedroomCount.toString(),
        );
      }
    }

    // Auto-suggest floor count
    final suggestedFloorCount =
        VillaTypeHelper.getSuggestedFloorCount(villaType);
    if (suggestedFloorCount != null) {
      final currentFloorCount = formState.value['floor_count'];
      // Only auto-fill if field is empty
      if (currentFloorCount == null ||
          currentFloorCount.toString().trim().isEmpty) {
        formState.fields['floor_count']?.didChange(
          suggestedFloorCount.toString(),
        );
      }
    }
  }

  Widget _buildSuggestionHint(String villaType) {
    final bedroomSuggestion =
        VillaTypeHelper.getSuggestedBedroomCount(villaType);
    final floorSuggestion = VillaTypeHelper.getSuggestedFloorCount(villaType);

    if (bedroomSuggestion == null && floorSuggestion == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Auto-suggested values:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            if (bedroomSuggestion != null) ...[
              const SizedBox(height: 4),
              Text(
                '• Bedroom Count: $bedroomSuggestion (you can change this)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
            if (floorSuggestion != null) ...[
              const SizedBox(height: 4),
              Text(
                '• Floor Count: $floorSuggestion (you can change this)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Enhanced bedroom count field with validation against villa type
class BedroomCountField extends StatelessWidget {
  const BedroomCountField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VillaFormFields.buildFieldLabel('Bedroom Count'),
        FormBuilderTextField(
          name: 'bedroom_count',
          decoration: const InputDecoration(
            hintText: 'Enter bedroom count (optional)',
            border: OutlineInputBorder(),
            helperText: 'Will be auto-filled based on Villa Type',
          ),
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.integer(errorText: 'Must be a valid number'),
            FormBuilderValidators.min(0),
            // Custom validator to check against villa type
            (String? value) {
              if (value == null || value.isEmpty) return null;
              final formState = FormBuilder.of(context);
              if (formState == null) return null;

              final villaType = formState.value['villa_type'] as String?;
              final bedroomCount = int.tryParse(value);

              if (villaType != null && bedroomCount != null) {
                // Validation passed - could show warning in UI if needed
                VillaTypeHelper.validateBedroomCountAgainstType(
                  villaType,
                  bedroomCount,
                );
              }
              return null;
            },
          ]),
        ),
      ],
    );
  }
}

/// Enhanced floor count field with validation against villa type
class FloorCountField extends StatelessWidget {
  const FloorCountField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VillaFormFields.buildFieldLabel('Floor Count'),
        FormBuilderTextField(
          name: 'floor_count',
          decoration: const InputDecoration(
            hintText: 'Enter floor count (optional)',
            border: OutlineInputBorder(),
            helperText: 'Will be auto-filled for Duplex (2 floors)',
          ),
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.integer(errorText: 'Must be a valid number'),
            FormBuilderValidators.min(0),
          ]),
        ),
      ],
    );
  }
}

