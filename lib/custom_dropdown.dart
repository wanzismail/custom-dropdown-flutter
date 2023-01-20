library animated_custom_dropdown;

import 'package:flutter/material.dart';

export 'custom_dropdown.dart';

part 'animated_section.dart';
part 'dropdown_field.dart';
part 'dropdown_overlay.dart';
part 'overlay_builder.dart';

enum _SearchType { onListData }

typedef _ListItemBuilder = Widget Function(BuildContext context, String result);

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final TextEditingController controller;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? selectedStyle;
  final String? errorText;
  final TextStyle? errorStyle;
  final String? emptyText;
  final TextStyle? emptyStyle;
  final TextStyle? listItemStyle;
  final BorderSide? borderSide;
  final BorderSide? errorBorderSide;
  final BorderRadius? borderRadius;
  final Widget? fieldSuffixIcon;
  final Function(String)? onChanged;
  final bool? excludeSelected;
  final bool isMultipleSelection;
  final Color? fillColor;
  final bool? canCloseOutsideBounds;
  // ignore: library_private_types_in_public_api
  final _SearchType? searchType;
  // ignore: library_private_types_in_public_api
  final _ListItemBuilder? listItemBuilder;
  final Color? itemSelectedBackgroundColor;

  CustomDropdown({
    Key? key,
    required this.items,
    required this.controller,
    this.hintText,
    this.hintStyle,
    this.selectedStyle,
    this.errorText,
    this.errorStyle,
    this.emptyText,
    this.emptyStyle,
    this.listItemStyle,
    this.errorBorderSide,
    this.borderRadius,
    this.borderSide,
    this.listItemBuilder,
    this.itemSelectedBackgroundColor,
    this.fieldSuffixIcon,
    this.onChanged,
    this.excludeSelected = true,
    this.isMultipleSelection = false,
    this.fillColor = Colors.white,
  })  : assert(items.isNotEmpty, 'Items list must contain at least one item.'),
        assert(
          controller.text.isEmpty ||
              items.contains(controller.text) ||
              (isMultipleSelection && controller.text.contains(',')),
          'Controller value must match with one of the item in items list.',
        ),
        assert(
          (listItemBuilder == null && listItemStyle == null) ||
              (listItemBuilder == null && listItemStyle != null) ||
              (listItemBuilder != null && listItemStyle == null),
          'Cannot use both listItemBuilder and listItemStyle.',
        ),
        searchType = null,
        canCloseOutsideBounds = true,
        super(key: key);

  CustomDropdown.search({
    Key? key,
    required this.items,
    required this.controller,
    this.hintText,
    this.hintStyle,
    this.listItemBuilder,
    this.selectedStyle,
    this.errorText,
    this.errorStyle,
    this.emptyText,
    this.emptyStyle,
    this.listItemStyle,
    this.itemSelectedBackgroundColor,
    this.errorBorderSide,
    this.borderRadius,
    this.borderSide,
    this.fieldSuffixIcon,
    this.onChanged,
    this.excludeSelected = true,
    this.isMultipleSelection = false,
    this.canCloseOutsideBounds = true,
    this.fillColor = Colors.white,
  })  : assert(items.isNotEmpty, 'Items list must contain at least one item.'),
        assert(
          controller.text.isEmpty ||
              items.contains(controller.text) ||
              (isMultipleSelection && controller.text.contains(',')),
          'Controller value must match with one of the item in items list.',
        ),
        assert(
          (listItemBuilder == null && listItemStyle == null) ||
              (listItemBuilder == null && listItemStyle != null) ||
              (listItemBuilder != null && listItemStyle == null),
          'Cannot use both listItemBuilder and listItemStyle.',
        ),
        searchType = _SearchType.onListData,
        super(key: key);

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    /// hint text
    final hintText = widget.hintText ?? 'Select value';

    // hint style :: if provided then merge with default
    final hintStyle = const TextStyle(
      fontSize: 16,
      color: Color(0xFFA7A7A7),
      fontWeight: FontWeight.w400,
    ).merge(widget.hintStyle);

    // selected item style :: if provided then merge with default
    final selectedStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ).merge(widget.selectedStyle);

    return _OverlayBuilder(
      overlay: (size, hideCallback) {
        return _DropdownOverlay(
          items: widget.items,
          controller: widget.controller,
          size: size,
          listItemBuilder: widget.listItemBuilder,
          itemSelectedBackgroundColor: widget.itemSelectedBackgroundColor,
          layerLink: layerLink,
          hideOverlay: hideCallback,
          headerStyle:
              widget.controller.text.isNotEmpty ? selectedStyle : hintStyle,
          hintText: hintText,
          emptyText: widget.emptyText,
          emptyStyle: widget.emptyStyle,
          listItemStyle: widget.listItemStyle,
          excludeSelected: widget.excludeSelected,
          canCloseOutsideBounds: widget.canCloseOutsideBounds,
          searchType: widget.searchType,
          isMultilpleSelection: widget.isMultipleSelection,
        );
      },
      child: (showCallback) {
        return CompositedTransformTarget(
          link: layerLink,
          child: _DropDownField(
            controller: widget.controller,
            onTap: showCallback,
            style: selectedStyle,
            borderRadius: widget.borderRadius,
            borderSide: widget.borderSide,
            errorBorderSide: widget.errorBorderSide,
            errorStyle: widget.errorStyle,
            errorText: widget.errorText,
            hintStyle: hintStyle,
            hintText: hintText,
            suffixIcon: widget.fieldSuffixIcon,
            onChanged: widget.onChanged,
            fillColor: widget.fillColor,
          ),
        );
      },
    );
  }
}
