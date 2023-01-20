part of 'custom_dropdown.dart';

const _headerPadding = EdgeInsets.only(
  left: 16.0,
  top: 16,
  bottom: 16,
  right: 14,
);
const _overlayOuterPadding = EdgeInsets.only(bottom: 12, left: 12, right: 12);
const _overlayShadowOffset = Offset(0, 6);
const _listItemPadding = EdgeInsets.symmetric(vertical: 12, horizontal: 16);

class _DropdownOverlay extends StatefulWidget {
  final List<String> items;
  final TextEditingController controller;
  final Size size;
  final LayerLink layerLink;
  final VoidCallback hideOverlay;
  final String hintText;
  final TextStyle? headerStyle;
  final TextStyle? listItemStyle;
  final String? emptyText;
  final TextStyle? emptyStyle;

  final bool? excludeSelected;
  final bool? canCloseOutsideBounds;
  final _SearchType? searchType;
  final _ListItemBuilder? listItemBuilder;
  final Color? itemSelectedBackgroundColor;

  final bool isMultilpleSelection;

  const _DropdownOverlay({
    Key? key,
    required this.items,
    required this.controller,
    required this.size,
    required this.layerLink,
    required this.hideOverlay,
    required this.hintText,
    this.headerStyle,
    this.listItemStyle,
    this.excludeSelected,
    this.canCloseOutsideBounds,
    this.searchType,
    this.listItemBuilder,
    this.itemSelectedBackgroundColor,
    this.emptyText,
    this.emptyStyle,
    this.isMultilpleSelection = false,
  }) : super(key: key);

  @override
  _DropdownOverlayState createState() => _DropdownOverlayState();
}

class _DropdownOverlayState extends State<_DropdownOverlay> {
  bool displayOverly = true;
  bool displayOverlayBottom = true;

  late String headerText;
  late List<String> items;
  late List<String> filteredItems;
  List<String> selectedItems = [];
  final key1 = GlobalKey(), key2 = GlobalKey();
  final scrollController = ScrollController();

  // default list item builder
  Widget defaultListItemBuilder(BuildContext context, String result) {
    return Text(
      result,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 16,
      ).merge(widget.listItemStyle),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final render1 = key1.currentContext?.findRenderObject() as RenderBox;
      final render2 = key2.currentContext?.findRenderObject() as RenderBox;
      final screenHeight = MediaQuery.of(context).size.height;
      double y = render1.localToGlobal(Offset.zero).dy;
      if (screenHeight - y < render2.size.height) {
        displayOverlayBottom = false;
        setState(() {});
      }
    });

    headerText = widget.controller.text;
    if (widget.excludeSelected! &&
        widget.items.length > 1 &&
        widget.controller.text.isNotEmpty) {
      items = widget.items.where((item) {
        return (item != headerText) ||
            (headerText.contains(',') &&
                selectedItems.where((element) => element != item).isNotEmpty);
      }).toList();
    } else {
      items = widget.items;
    }
    filteredItems = items;

    if (widget.isMultilpleSelection &&
        widget.controller.text.isNotEmpty &&
        !widget.controller.text.contains(',') &&
        !selectedItems.contains(widget.controller.text)) {
      selectedItems.add(widget.controller.text);
      print('Masuk 1');
    } else if (widget.isMultilpleSelection &&
        widget.controller.text.contains(',')) {
      widget.controller.text.split(', ').forEach((element) {
        if (!selectedItems.contains(element)) {
          selectedItems.add(element);
        }
      });

      print('Masuk 2' + widget.controller.text.split(', ').toString());
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // search availability check
    final onListDataSearch = widget.searchType == _SearchType.onListData;

    // border radius
    final borderRadius = BorderRadius.circular(12);

    // overlay icon
    final overlayIcon = Icon(
      displayOverlayBottom
          ? Icons.keyboard_arrow_up_rounded
          : Icons.keyboard_arrow_down_rounded,
      color: Colors.black,
      size: 20,
    );

    // empty style :: if provided then merge with default
    final emptyStyle = const TextStyle(
      fontSize: 16,
      color: Color(0xFFA7A7A7),
      fontWeight: FontWeight.w400,
    ).merge(widget.emptyStyle);

    // overlay offset
    final overlayOffset = Offset(-12, displayOverlayBottom ? 0 : 60);

    // list padding
    final listPadding =
        onListDataSearch ? const EdgeInsets.only(top: 8) : EdgeInsets.zero;

    // items list
    final list = items.isNotEmpty
        ? _ItemsList(
            scrollController: scrollController,
            listItemBuilder: widget.listItemBuilder ?? defaultListItemBuilder,
            excludeSelected:
                widget.items.length > 1 ? widget.excludeSelected! : false,
            items: items,
            padding: listPadding,
            headerText: headerText,
            itemTextStyle: widget.listItemStyle,
            itemSelectedBackgroundColor: widget.itemSelectedBackgroundColor,
            onItemSelect: (value) {
              if (widget.isMultilpleSelection) {
                if (selectedItems
                        .where((element) => element == value)
                        .isNotEmpty &&
                    !widget.excludeSelected!) {
                  selectedItems.remove(value);
                } else if ((selectedItems
                            .where((element) => element != value)
                            .isNotEmpty &&
                        !widget.excludeSelected!) ||
                    !selectedItems.contains(value)) {
                  selectedItems.add(value);
                }
                widget.controller.text = selectedItems.join(', ');
              } else if (headerText != value) {
                widget.controller.text = value;
              }
              setState(() => displayOverly = false);
            },
          )
        : Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                widget.emptyText ?? 'No result found.',
                style: emptyStyle,
              ),
            ),
          );

    final child = Stack(
      children: [
        Positioned(
          width: widget.size.width + 24,
          child: CompositedTransformFollower(
            link: widget.layerLink,
            followerAnchor:
                displayOverlayBottom ? Alignment.topLeft : Alignment.bottomLeft,
            showWhenUnlinked: false,
            offset: overlayOffset,
            child: Container(
              key: key1,
              padding: _overlayOuterPadding,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 24.0,
                      color: Colors.black.withOpacity(.08),
                      offset: _overlayShadowOffset,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedSection(
                    animationDismissed: widget.hideOverlay,
                    expand: displayOverly,
                    axisAlignment: displayOverlayBottom ? 1.0 : -1.0,
                    child: SizedBox(
                      key: key2,
                      height: items.length > 4
                          ? onListDataSearch
                              ? 270
                              : 225
                          : null,
                      child: ClipRRect(
                        borderRadius: borderRadius,
                        child: NotificationListener<
                            OverscrollIndicatorNotification>(
                          onNotification: (notification) {
                            notification.disallowIndicator();
                            return true;
                          },
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                                thumbVisibility: MaterialStateProperty.all(
                                  true,
                                ),
                                thickness: MaterialStateProperty.all(5),
                                radius: const Radius.circular(4),
                                thumbColor: MaterialStateProperty.all(
                                  Colors.grey[300],
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: _headerPadding,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          headerText.isNotEmpty
                                              ? headerText
                                              : widget.hintText,
                                          style: widget.headerStyle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      overlayIcon,
                                    ],
                                  ),
                                ),
                                if (onListDataSearch)
                                  _SearchField(
                                    items: filteredItems,
                                    onSearchedItems: (val) {
                                      setState(() => items = val);
                                    },
                                  ),
                                items.length > 4 ? Expanded(child: list) : list
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: () => setState(() => displayOverly = false),
      child: widget.canCloseOutsideBounds!
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
              child: child,
            )
          : child,
    );
  }
}

class _ItemsList extends StatelessWidget {
  final ScrollController scrollController;
  final List<String> items;
  final bool excludeSelected;
  final String headerText;
  final ValueSetter<String> onItemSelect;
  final EdgeInsets padding;
  final TextStyle? itemTextStyle;
  final Color? itemSelectedBackgroundColor;
  final _ListItemBuilder listItemBuilder;

  const _ItemsList({
    Key? key,
    required this.scrollController,
    required this.items,
    required this.excludeSelected,
    required this.headerText,
    required this.onItemSelect,
    required this.listItemBuilder,
    required this.padding,
    this.itemTextStyle,
    this.itemSelectedBackgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        padding: padding,
        itemCount: items.length,
        itemBuilder: (_, index) {
          final selected =
              !excludeSelected && headerText.contains(items[index]);
          return Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.grey[200],
              onTap: () => onItemSelect(items[index]),
              child: Container(
                color: selected
                    ? itemSelectedBackgroundColor ?? Colors.grey[100]
                    : Colors.transparent,
                padding: _listItemPadding,
                child: listItemBuilder(context, items[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  final List<String> items;
  final ValueChanged<List<String>> onSearchedItems;
  const _SearchField({
    Key? key,
    required this.items,
    required this.onSearchedItems,
  }) : super(key: key);

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final searchCtrl = TextEditingController();

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  void onSearch(String str) {
    final result = widget.items
        .where((item) => item.toLowerCase().contains(str.toLowerCase()))
        .toList();
    widget.onSearchedItems(result);
  }

  void onClear() {
    if (searchCtrl.text.isNotEmpty) {
      searchCtrl.clear();
      widget.onSearchedItems(widget.items);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: searchCtrl,
        onChanged: onSearch,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[50],
          constraints: const BoxConstraints.tightFor(height: 40),
          contentPadding: const EdgeInsets.all(8),
          hintText: 'Search',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
          suffixIcon: GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, color: Colors.grey, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(.25),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(.25),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(.25),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
