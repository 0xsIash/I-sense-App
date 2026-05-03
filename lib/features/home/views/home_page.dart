import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/core/utils/app_assets.dart';
import 'package:wujidt/core/widgets/custom_header.dart';
import 'package:wujidt/features/home/models/scan_item_model.dart';
import 'package:wujidt/features/home/services/image_service.dart';
import 'package:wujidt/features/home/services/job_service.dart';
import 'package:wujidt/features/home/widgets/scan_item_card.dart';
import 'package:wujidt/features/home/widgets/custom_drawer.dart';
import 'package:wujidt/features/home/widgets/item_details_view.dart';
import 'package:wujidt/core/widgets/custom_btn.dart';
import 'package:wujidt/core/widgets/custom_svg_wrapper.dart';

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
        setState(() {
          item.extractedItems = objects;
        });
      }
    } catch (e) {
      debugPrint("Error fetching objects: $e");
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  Future<void> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: Platform.isAndroid || Platform.isIOS
            ? ImageSource.camera
            : ImageSource.gallery,
      );

      if (image != null) {
        Position? position = await _getCurrentLocation();

        final newItem = ScanItemModel(
          imageFile: File(image.path),
          progress: 0.1,
          status: 'pending',
          isPublic: false,
        );

        setState(() {
          processingList.insert(0, newItem);
        });

        _uploadAndProcessImage(newItem, position);
      }
    } catch (e) {
      debugPrint("Picker Error: $e");
    }
  }

  Future<void> _uploadAndProcessImage(ScanItemModel item, Position? position) async {
    try {
      if (item.imageFile != null) {
        final responseData = await _imageService.uploadImage(
          item.imageFile!,
          latitude: position?.latitude,
          longitude: position?.longitude,
          locationName: "Current Location",
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
      debugPrint("Processing Error: $e");
      if (mounted) {
        setState(() => processingList.remove(item));
      }
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

  Future<void> _confirmDelete() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Delete ${selectedItems.length} image(s)?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                deleteSelectedItems();
              },
            ),
          ],
        );
      },
    );
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
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSharing = true);

    int successCount = 0;
    int alreadySharedCount = 0;

    for (var item in List.from(selectedItems)) {
      if (item.isPublic == true) {
        alreadySharedCount++;
        continue;
      }

      if (item.imageId != null) {
        bool res = await _jobService.publishImage(item.imageId!);
        if (res) {
          successCount++;
          item.isPublic = true;
        }
      }
    }

    if (mounted) {
      setState(() {
        _isSharing = false;
        isSelectionMode = false;
        selectedItems.clear();
      });

      String message = "";
      if (successCount > 0) message += "$successCount image(s) shared successfully! ";
      if (alreadySharedCount > 0) message += "$alreadySharedCount image(s) already public.";
      if (message.isEmpty) message = "No changes were made.";

      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: successCount > 0 ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Future<void> _confirmShare() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Sharing'),
          content: Text('Share ${selectedItems.length} image(s) publicly?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Yes', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                _shareSelectedItems();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = (ModalRoute.of(context)!.settings.arguments as String?) ?? "User";
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: AppColors.primary, size: 24.sp),
                      SizedBox(width: 8.w),
                      Text("Recent Uploads", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  CustomBtn(
                    text: isSelectionMode ? "Cancel" : "Select",
                    btnWidth: 90.w,
                    btnHeight: 35.h,
                    onPressed: toggleSelectionMode,
                    weight: FontWeight.bold,
                    size: 14.sp,
                    fontFamily: 'Nunito Sans',
                    eleveation: 0,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoadingHistory && allItems.isEmpty
                  ? const Center(child: CircularProgressIndicator())
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

                          Widget bottomWidget;
                          if (item.status == 'pending' || item.progress < 1.0) {
                            bottomWidget = Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LinearProgressIndicator(
                                  value: item.progress,
                                  color: AppColors.primary,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                ),
                                SizedBox(height: 5.h),
                                Text("${(item.progress * 100).toInt()}%", style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                              ],
                            );
                          } else {
                            bottomWidget = ListView(
                              scrollDirection: Axis.horizontal,
                              children: (item.extractedItems ?? []).map((e) => e.category).toSet().take(2).map((tag) => Container(
                                    margin: EdgeInsets.only(right: 5.w),
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                                    child: Center(child: Text(tag.toString(), style: TextStyle(color: Colors.white, fontSize: 10.sp))),
                                  )).toList(),
                            );
                          }

                          return GestureDetector(
                            onTap: () {
                              if (isSelectionMode) {
                                toggleItemSelection(item);
                              } else if (item.isCompleted) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ItemDetailsView(item: item)));
                              }
                            },
                            child: ScanItemCard(
                              imageFile: item.imageFile,
                              imageUrl: item.imageUrl,
                              bottomContent: bottomWidget,
                              isSelectionMode: isSelectionMode,
                              isSelected: selectedItems.contains(item),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            if (isSelectionMode)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${selectedItems.length} Selected", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Row(
                      children: [
                        InkWell(
                          onTap: (selectedItems.isNotEmpty && !_isDeleting) ? _confirmDelete : null,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isDeleting)
                                SizedBox(width: 24.w, height: 24.h, child: const CircularProgressIndicator(strokeWidth: 2))
                              else
                                CustomSvgWrapper(
                                    path: AppAssets.delete,
                                    iconWidth: 24.w,
                                    iconHeight: 24.h,
                                    color: selectedItems.isNotEmpty ? Colors.red : Colors.grey),
                              SizedBox(height: 4.h),
                              Text("Delete", style: TextStyle(color: selectedItems.isNotEmpty ? Colors.red : Colors.grey, fontSize: 12.sp)),
                            ],
                          ),
                        ),
                        SizedBox(width: 20.w),
                        InkWell(
                          onTap: selectedItems.isNotEmpty && !_isSharing ? _confirmShare : null,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isSharing)
                                SizedBox(width: 24.w, height: 24.h, child: const CircularProgressIndicator(strokeWidth: 2))
                              else
                                Icon(Icons.public, color: selectedItems.isNotEmpty ? AppColors.primary : Colors.grey, size: 24.sp),
                              SizedBox(height: 4.h),
                              Text("Public", style: TextStyle(color: selectedItems.isNotEmpty ? AppColors.primary : Colors.grey, fontSize: 12.sp)),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}