import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/features/home/services/search_service.dart';
import 'package:wujidt/features/home/models/top_match_model.dart';

class BrowseSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onCameraTap;
  final Function(TopMatchItem)? onResultTapped; // أضفنا هذا الـ Callback للانتقال للتفاصيل

  const BrowseSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onCameraTap,
    this.onResultTapped,
  });

  @override
  State<BrowseSearchBar> createState() => _BrowseSearchBarState();
}

class _BrowseSearchBarState extends State<BrowseSearchBar> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  
  bool _isLoading = false;
  List<TopMatchItem> _searchResults = [];
  final SearchService _searchService = SearchService();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && (_searchResults.isNotEmpty || _isLoading)) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _onTextChanged(String query) {
    widget.onSearch(query);
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() => _searchResults.clear());
      _hideOverlay();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isLoading = true);
      _showOverlay(); // إظهار حالة التحميل

      final response = await _searchService.searchByText(query);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = response?.results ?? [];
        });
        if (_focusNode.hasFocus) {
          _overlayEntry?.markNeedsBuild(); // تحديث الـ Dropdown بالبيانات الجديدة
        }
      }
    });
  }

  void _showOverlay() {
    _hideOverlay();
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 8.h), // مسافة بين السيرش والدروب داون
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(15.r),
            color: Colors.white,
            child: Container(
              constraints: BoxConstraints(maxHeight: 300.h), // أقصى طول للقائمة
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: _isLoading
                  ? Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    )
                  : _searchResults.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Text("No results found", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Kreon', color: Colors.grey)),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.network(
                                  item.segmentedImageUrl.isNotEmpty ? item.segmentedImageUrl : item.originalImageUrl,
                                  width: 40.w,
                                  height: 40.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 40.w, height: 40.h,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.image, color: Colors.grey[400]),
                                  ),
                                ),
                              ),
                              title: Text(item.objectLabel, style: TextStyle(fontFamily: 'Kreon', fontWeight: FontWeight.bold, fontSize: 14.sp)),
                              subtitle: Text("By: ${item.publisherUsername}", style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                              trailing: Icon(Icons.arrow_forward_ios, size: 12.sp, color: Colors.grey),
                              onTap: () {
                                _hideOverlay();
                                _focusNode.unfocus();
                                widget.onResultTapped?.call(item); // إرسال العنصر لصفحة Browse
                              },
                            );
                          },
                        ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    // هذا هو تصميم السيرش بار الأساسي الخاص بك مغلف بـ CompositedTransformTarget
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: _onTextChanged,
          decoration: InputDecoration(
            hintText: "Search items...",
            hintStyle: TextStyle(fontFamily: 'Kreon', color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              onPressed: widget.onCameraTap,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          ),
        ),
      ),
    );
  }
}