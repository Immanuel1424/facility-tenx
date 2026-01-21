import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Reusable form field widgets for Villa forms
class VillaFormFields {
  /// Dubai Region Standards for Alosool Group (www.alosoolgroup.com)
  static const List<String> villaTypes = [
    'Studio',
    '1BHK',
    '2BHK',
    '3BHK',
    '4BHK',
    '5BHK',
    'Penthouse',
    'Duplex',
    'Townhouse',
    'Villa',
    'Mansion',
  ];

  static Widget buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  static Widget villaNumberField({String? hintText}) {
    return FormBuilderTextField(
      name: 'villa_number',
      decoration: InputDecoration(
        hintText: hintText ?? 'Enter villa number (e.g., 101, 101A, V-101)',
        border: const OutlineInputBorder(),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
        FormBuilderValidators.maxLength(50),
      ]),
    );
  }

  static Widget villaTypeField() {
    return FormBuilderDropdown<String>(
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
        ...villaTypes.map(
          (type) => DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          ),
        ),
      ],
    );
  }

  static Widget blockField() {
    return FormBuilderTextField(
      name: 'block',
      decoration: const InputDecoration(
        hintText: 'Enter block (optional)',
        border: OutlineInputBorder(),
      ),
      validator: FormBuilderValidators.maxLength(50),
    );
  }

  static Widget streetField() {
    return FormBuilderTextField(
      name: 'street',
      decoration: const InputDecoration(
        hintText: 'Enter street (optional)',
        border: OutlineInputBorder(),
      ),
    );
  }

  static Widget cityField() {
    return FormBuilderTextField(
      name: 'city',
      decoration: const InputDecoration(
        hintText: 'Enter city (optional)',
        border: OutlineInputBorder(),
      ),
    );
  }

  static Widget pinCodeField() {
    return FormBuilderTextField(
      name: 'pin_code',
      decoration: const InputDecoration(
        hintText: 'Enter PIN code (optional)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  static Widget floorCountField() {
    return FormBuilderTextField(
      name: 'floor_count',
      decoration: const InputDecoration(
        hintText: 'Enter floor count (optional)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.integer(errorText: 'Must be a valid number'),
        FormBuilderValidators.min(0),
      ]),
    );
  }

  static Widget bedroomCountField() {
    return FormBuilderTextField(
      name: 'bedroom_count',
      decoration: const InputDecoration(
        hintText: 'Enter bedroom count (optional)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.integer(errorText: 'Must be a valid number'),
        FormBuilderValidators.min(0),
      ]),
    );
  }

  static Widget areaSqmField() {
    return FormBuilderTextField(
      name: 'area_sqm',
      decoration: const InputDecoration(
        hintText: 'Enter area in square meters (optional)',
        border: OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.numeric(errorText: 'Must be a valid number'),
        FormBuilderValidators.min(0),
      ]),
    );
  }

  static Widget parkingSlotNumberField() {
    return FormBuilderTextField(
      name: 'parking_slot_number',
      decoration: const InputDecoration(
        hintText: 'Enter parking slot number (optional)',
        border: OutlineInputBorder(),
      ),
    );
  }

  static Widget meterNumberField() {
    return FormBuilderTextField(
      name: 'meter_number',
      decoration: const InputDecoration(
        hintText: 'Enter electricity meter number (optional)',
        border: OutlineInputBorder(),
      ),
    );
  }

  static Widget waterMeterNumberField() {
    return FormBuilderTextField(
      name: 'water_meter_number',
      decoration: const InputDecoration(
        hintText: 'Enter water meter number (optional)',
        border: OutlineInputBorder(),
      ),
    );
  }

  static Widget ownerNameField() {
    return FormBuilderTextField(
      name: 'owner_name',
      decoration: const InputDecoration(
        hintText: 'Enter owner name (optional)',
        border: OutlineInputBorder(),
      ),
      validator: FormBuilderValidators.maxLength(255),
    );
  }

  static Widget contactPhoneField() {
    return FormBuilderTextField(
      name: 'contact_phone',
      decoration: const InputDecoration(
        hintText: 'Enter contact phone (optional)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.phone,
      validator: FormBuilderValidators.maxLength(50),
    );
  }

  static Widget contactEmailField() {
    return FormBuilderTextField(
      name: 'contact_email',
      decoration: const InputDecoration(
        hintText: 'Enter contact email (optional)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.email(),
        FormBuilderValidators.maxLength(255),
      ]),
    );
  }

  static Widget remarksField() {
    return FormBuilderTextField(
      name: 'remarks',
      decoration: const InputDecoration(
        hintText: 'Enter any additional remarks (optional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 4,
    );
  }

  static Widget isActiveField() {
    return FormBuilderCheckbox(
      name: 'is_active',
      title: const Text('Mark villa as active'),
      initialValue: true,
    );
  }
}

