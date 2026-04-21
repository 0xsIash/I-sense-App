import 'package:flutter/material.dart';
import 'package:isense/features/home/models/scan_item_model.dart';
import 'package:isense/features/home/models/draggable_object_model.dart';

class InteractiveCanvasPage extends StatefulWidget {
  final ScanItemModel item;

  const InteractiveCanvasPage({
    super.key,
    required this.item,
  });

  @override
  State<InteractiveCanvasPage> createState() => _InteractiveCanvasPageState();
}

class _InteractiveCanvasPageState extends State<InteractiveCanvasPage> {
  late List<DraggableObject> _objects;

  final double _originalImageWidth = 2000;
  final double _originalImageHeight = 1502;

  @override
  void initState() {
    super.initState();
    _objects = [];
    final items = widget.item.extractedItems ?? [];

    for (int i = 0; i < items.length; i++) {
      if (items[i].imageUrl != null) {
        _objects.add(DraggableObject(
          imageUrl: items[i].imageUrl!,
          label: items[i].name,
          x: items[i].bbX ?? (20 + (i % 2) * 180),
          y: items[i].bbY ?? (20 + (i ~/ 2) * 180),
          width: items[i].bbWidth ?? 150,
          height: items[i].bbHeight ?? 150,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? bgImage;
    if (widget.item.imageFile != null) {
      bgImage = FileImage(widget.item.imageFile!);
    } else if (widget.item.imageUrl != null) {
      bgImage = NetworkImage(widget.item.imageUrl!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Arrange Objects")),
      body: Column(
        children: [
          // Canvas takes upper part of screen
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double scaleX =
                    constraints.maxWidth / _originalImageWidth;
                final double scaleY =
                    constraints.maxHeight / _originalImageHeight;

                return Stack(
                  children: [
                    // Background: original image
                    Positioned.fill(
                      child: bgImage != null
                          ? Image(image: bgImage, fit: BoxFit.fill)
                          : const ColoredBox(color: Colors.grey),
                    ),

                    // Draggable segmented objects scaled to canvas
                    ..._objects.map((obj) => _buildDraggableObject(
                          obj,
                          scaleX: scaleX,
                          scaleY: scaleY,
                        )),
                  ],
                );
              },
            ),
          ),

          // Bottom: object list
          Container(
            height: 120,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(10),
              itemCount: _objects.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 90,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        _objects[index].imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _objects[index].label,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableObject(DraggableObject obj,
      {required double scaleX, required double scaleY}) {
    return Positioned(
      left: obj.x * scaleX,
      top: obj.y * scaleY,
      child: GestureDetector(
        // Drag to move
        onPanUpdate: (details) {
          setState(() {
            obj.x += details.delta.dx / scaleX;
            obj.y += details.delta.dy / scaleY;
          });
        },
        // Right click → show delete menu
        onSecondaryTapUp: (details) {
          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              details.globalPosition.dx,
              details.globalPosition.dy,
              details.globalPosition.dx + 1,
              details.globalPosition.dy + 1,
            ),
            items: [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: const [
                    Icon(Icons.delete, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ).then((value) {
            if (value == 'delete') {
              setState(() {
                _objects.remove(obj);
              });
            }
          });
        },
        child: Container(
          width: obj.width * scaleX,
          height: obj.height * scaleY,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Image.network(
            obj.imageUrl,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}