import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/features/home/models/scan_item_model.dart';
import 'package:isense/features/home/services/image_service.dart';
import 'package:isense/features/home/services/job_service.dart';
import 'package:isense/features/home/widgets/custom_bottom_nav.dart';
import 'package:isense/features/home/widgets/custom_drawer.dart';
import 'package:isense/features/home/widgets/history_tab.dart';
import 'package:isense/features/home/widgets/notification_page.dart';
import 'package:isense/features/home/widgets/processing_tab.dart';
import 'package:isense/features/home/widgets/toggle_switch_btn.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImageService _imageService = ImageService();
  final JobService _jobService = JobService();
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  bool isProcessingTab = true;
  bool _isLoadingHistory = false; 
  List<ScanItemModel> processingList = [];
  List<ScanItemModel> historyList = [];

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
        });
        
        for (var item in historyList) {
          _fetchItemDetailsInBackground(item);
        }
      }
    } catch (e) {
      debugPrint("Error loading history: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  Future<void> _fetchItemDetailsInBackground(ScanItemModel item) async {
    if (item.imageId == null) return;
    try {
      final objects = await _jobService.getImageObjects(item.imageId!);
      if (mounted && objects.isNotEmpty) {
        setState(() {
          item.extractedItems = objects; 
        });
      }
    } catch (e) {
      // .
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        final newItem = ScanItemModel(
          imageFile: File(image.path),
          progress: 0.1,
          status: 'pending',
        );

        setState(() {
          processingList.add(newItem);
          isProcessingTab = true; 
        });

        _uploadAndProcessImage(newItem);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _uploadAndProcessImage(ScanItemModel item) async {
    try {
      setState(() { item.progress = 0.2; });

      if (item.imageFile != null) {
        final responseData = await _imageService.uploadImage(item.imageFile!);
        
        debugPrint("🔵 UPLOAD RESULT: $responseData"); 

        setState(() {
          item.id = responseData['id'];
          item.jobId = responseData['job_id'];
          item.imageId = responseData['image_id'];
          item.progress = 0.4;
        });

        String status = "pending";
        while (status != "completed" && status != "failed" && !item.isDeleted) {
          await Future.delayed(const Duration(seconds: 2)); 
          if (item.isDeleted) break; 
          
          try {
            status = await _jobService.checkJobStatus(item.jobId!);
          } catch (e) {
            if (item.isDeleted) break; 
            debugPrint("Retry checking status...");
          }

          if (mounted && item.progress < 0.8 && !item.isDeleted) {
             setState(() { item.progress += 0.1; });
          }

          if (status == "failed") throw Exception("Job processing failed on server.");
        }

        if (item.isDeleted) return; 

        setState(() { item.progress = 0.9; });
        
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
      debugPrint("Error: $e");
      if (mounted && !item.isDeleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() {
           processingList.remove(item);
        });
      }
    }
  }

  Future<void> _deleteItem(ScanItemModel item, bool fromProcessing) async {
    item.isDeleted = true; 
    
    if (item.imageId != null) {
      try {
        await _jobService.deleteImage(item.imageId!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete from server: $e"), backgroundColor: Colors.red),
          );
        }
        return; 
      }
    }

    if (mounted) {
      setState(() {
        if (fromProcessing) {
          processingList.remove(item);
        } else {
          historyList.remove(item);
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item deleted successfully"), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _confirmDelete(ScanItemModel item, bool fromProcessing) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this item?'),
                SizedBox(height: 10),
                Text('This action cannot be undone.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(item, fromProcessing);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName = ModalRoute.of(context)!.settings.arguments as String? ?? "User";

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primaryBackgrond,
      
      drawer: CustomDrawer(userName: userName),

      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState!.openDrawer(),
                    child: Row(
                      children: [
                        Icon(Icons.menu, color: AppColors.primary),
                        SizedBox(width: 12.w),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontFamily: 'Nunito Sans',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationPage(
                            processingCount: processingList.length,
                            historyCount: historyList.length,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          color: AppColors.primary,
                          size: 28.sp,
                        ),
                        
                        if (historyList.isNotEmpty)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${historyList.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 25.h),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ToggleSwitchBtn(
                isProcessing: isProcessingTab,
                onChanged: (newValue) {
                  setState(() => isProcessingTab = newValue);
                },
              ),
            ),
            
            SizedBox(height: 10.h),
            
            Expanded(
              child: isProcessingTab
                  ? ProcessingTab(
                      items: processingList,
                      onDelete: (item) => _confirmDelete(item, true),
                    )
                  : _isLoadingHistory && historyList.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : HistoryTab(
                          items: historyList,
                          onDelete: (item) => _confirmDelete(item, false),
                        ),
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: CustomBottomNav(
        onCameraTap: _pickImageFromCamera,
      ),
    );
  }
}