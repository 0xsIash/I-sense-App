import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/core/utils/image_picker_helper.dart';
import 'package:wujidt/core/widgets/custom_header.dart';
import 'package:wujidt/features/home/models/scan_item_model.dart';
import 'package:wujidt/features/home/services/image_service.dart';
import 'package:wujidt/features/home/services/job_service.dart';
import 'package:wujidt/features/home/widgets/scan_item_card.dart';
import 'package:wujidt/features/home/widgets/custom_drawer.dart';
import 'package:wujidt/features/home/widgets/item_details_view.dart';
import 'package:wujidt/features/home/widgets/home_empty_state.dart';
import 'package:wujidt/features/home/widgets/home_section_header.dart';
import 'package:wujidt/features/home/widgets/home_selection_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final ImageService _imageService = ImageService();
  final JobService _jobService = JobService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoadingHistory = false;
  bool isSelectionMode = false;
  bool _isDeleting = false;
  bool _isSharing = false;

  List<ScanItemModel> processingList = [];
  List<ScanItemModel> historyList = [];
  List<ScanItemModel> selectedItems = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final history = await _jobService.getUserHistory();
      if (mounted) {
        setState(() {
          historyList = history;
          _isLoadingHistory = false;
        });
        _fetchDetailsSequentially(historyList);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _fetchDetailsSequentially(List<ScanItemModel> items) async {
    for (var item in items) {
      if (item.extractedItems == null || item.extractedItems!.isEmpty) {
        await _fetchItemDetailsInBackground(item);
      }
    }
  }

  Future<void> _fetchItemDetailsInBackground(ScanItemModel item) async {
    final int targetId = item.imageId ?? item.id ?? 0;
    if (targetId == 0) return;
    try {
      final objects = await _jobService.getImageObjects(targetId);
      if (mounted && objects.isNotEmpty) {
        setState(() => item.extractedItems = objects);
      }
    } catch (e) {
      debugPrint("Error fetching objects: $e");
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;
    return await Geolocator.getCurrentPosition();
  }

  Future<void> pickImage() async {
    try {
      File? imageFile = await ImagePickerHelper.showImageSourceOptions(context);
      if (imageFile != null) {
        Position? position = await _getCurrentLocation();
        final newItem = ScanItemModel(
          imageFile: imageFile,
          progress: 0.1,
          status: 'pending',
          isPublic: false,
        );
        setState(() => processingList.insert(0, newItem));
        _uploadAndProcessImage(newItem, position);
      }
    } catch (e) {
      debugPrint("Picker Error: $e");
    }
  }

  Future<void> _uploadAndProcessImage(ScanItemModel item, Position? position) async {
    try {
      if (item.imageFile != null) {
        String finalLocationName = "Unknown Location";
        if (position != null) {
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
            if (placemarks.isNotEmpty) {
              finalLocationName = "${placemarks[0].locality}, ${placemarks[0].administrativeArea}";
            }
          } catch (e) {
            finalLocationName = "Current Location";
          }
        }
        final responseData = await _imageService.uploadImage(
          item.imageFile!,
          latitude: position?.latitude,
          longitude: position?.longitude,
          locationName: finalLocationName,
        );
        setState(() {
          item.id = responseData['id'];
          item.jobId = responseData['job_id'];
          item.imageId = responseData['image_id'];
          item.progress = 0.4;
        });
        String status = "pending";
        while (status != "completed" && status != "failed" && !item.isDeleted) {
          await Future.delayed(const Duration(seconds: 2));
          status = await _jobService.checkJobStatus(item.jobId!);
          if (mounted && item.progress < 0.8) setState(() => item.progress += 0.1);
          if (status == "failed") throw Exception("Processing failed");
        }
        if (item.isDeleted) return;
        setState(() => item.progress = 0.9);
        final objects = await _jobService.getImageObjects(item.imageId!);
        if (mounted) {
          setState(() {
            item.extractedItems = objects;
            item.progress = 1.0;
            item.isCompleted = true;
            item.status = 'completed';
            processingList.remove(item);
            historyList.insert(0, item);
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => processingList.remove(item));
    }
  }

  void toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) selectedItems.clear();
    });
  }

  void toggleItemSelection(ScanItemModel item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
    });
  }

  Future<void> deleteSelectedItems() async {
    setState(() => _isDeleting = true);
    for (var item in List.from(selectedItems)) {
      final int targetId = item.imageId ?? item.id ?? 0;
      if (targetId != 0) await _jobService.deleteImage(targetId);
    }
    if (mounted) {
      setState(() {
        historyList.removeWhere((item) => selectedItems.contains(item));
        isSelectionMode = false;
        selectedItems.clear();
        _isDeleting = false;
      });
    }
  }

  Future<void> _shareSelectedItems() async {
    setState(() => _isSharing = true);
    for (var item in List.from(selectedItems)) {
      if (item.isPublic != true && item.imageId != null) {
        bool res = await _jobService.publishImage(item.imageId!);
        if (res) item.isPublic = true;
      }
    }
    if (mounted) {
      setState(() {
        _isSharing = false;
        isSelectionMode = false;
        selectedItems.clear();
      });
    }
  }

  Future<void> _confirmDelete() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Delete ${selectedItems.length} image(s)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteSelectedItems();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmShare() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Sharing'),
        content: Text('Share ${selectedItems.length} image(s) publicly?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _shareSelectedItems();
            },
            child: const Text('Yes', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?) ?? {};
    final String userName = args['userName'] ?? "User";
    final int currentUserId = args['userId'] ?? 0;
    
    List<ScanItemModel> allItems = [...processingList, ...historyList];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: CustomDrawer(userName: userName),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 15.h),
            CustomHeader(
              userName: userName,
              scaffoldKey: _scaffoldKey,
              processingCount: processingList.length,
              historyCount: historyList.length,
            ),
            HomeSectionHeader(
              isSelectionMode: isSelectionMode,
              onToggleSelection: toggleSelectionMode,
            ),
            Expanded(
              child: _isLoadingHistory && allItems.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : allItems.isEmpty
                      ? const HomeEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          color: AppColors.primary,
                          child: GridView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                            itemCount: allItems.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15.w,
                              mainAxisSpacing: 15.h,
                              childAspectRatio: 0.85,
                            ),
                            itemBuilder: (context, index) {
                              final item = allItems[index];
                              return GestureDetector(
                                onTap: () {
                                  if (isSelectionMode) {
                                    toggleItemSelection(item);
                                  } else if (item.isCompleted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ItemDetailsView(
                                          item: item,
                                          currentUserId: currentUserId,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: ScanItemCard(
                                  imageFile: item.imageFile,
                                  imageUrl: item.imageUrl,
                                  bottomContent: _buildBottomContent(item),
                                  isSelectionMode: isSelectionMode,
                                  isSelected: selectedItems.contains(item),
                                ),
                              );
                            },
                          ),
                        ),
            ),
            if (isSelectionMode)
              HomeSelectionBottomBar(
                selectedCount: selectedItems.length,
                isDeleting: _isDeleting,
                isSharing: _isSharing,
                onDelete: _confirmDelete,
                onShare: _confirmShare,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomContent(ScanItemModel item) {
    if (item.status == 'pending' || item.progress < 1.0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LinearProgressIndicator(
            value: item.progress,
            color: AppColors.primary,
            backgroundColor: AppColors.primary.withOpacity(0.2),
          ),
          SizedBox(height: 5.h),
          Text("${(item.progress * 100).toInt()}%", style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
        ],
      );
    } else {
      return ListView(
        scrollDirection: Axis.horizontal,
        children: (item.extractedItems ?? [])
            .map((e) => e.category)
            .toSet()
            .toList()
            .take(2)
            .map((tag) => Container(
                  margin: EdgeInsets.only(right: 5.w),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                  child: Center(
                    child: Text(tag.toString(), style: TextStyle(color: Colors.white, fontSize: 10.sp)),
                  ),
                ))
            .toList(),
      );
    }
  }
}