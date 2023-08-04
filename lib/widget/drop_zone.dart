import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:gngm/core/core.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DropZoneWarper extends StatefulWidget {
  const DropZoneWarper({
    super.key,
    required this.child,
    this.onDrop,
    this.onDropMultiple,
  });

  final Function(PlatformFile file)? onDrop;
  final Function(List<PlatformFile> files)? onDropMultiple;
  final Widget child;

  @override
  State<DropZoneWarper> createState() => _DropZoneWarperState();
}

class _DropZoneWarperState extends State<DropZoneWarper> {
  late DropzoneViewController controller;
  bool isHovering = false;

  Future<PlatformFile> _parseHtmlFile(htmlFile) async {
    return PlatformFile(
      name: htmlFile.name,
      size: htmlFile.size,
      bytes: await controller.getFileData(htmlFile),
      readStream: controller.getFileStream(htmlFile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (kIsWeb)
          DropzoneView(
            operation: DragOperation.copy,
            cursor: CursorType.auto,
            onCreated: (ctrl) => controller = ctrl,
            onHover: () => setState(() => isHovering = true),
            onLeave: () => setState(() => isHovering = false),
            onDrop: (dynamic htmlFile) async {
              setState(() => isHovering = false);

              final file = await _parseHtmlFile(htmlFile);

              if (widget.onDrop != null) widget.onDrop!(file);
            },
            onDropMultiple: (List<dynamic>? files) async {
              setState(() => isHovering = false);
              final List<PlatformFile> platformFiles = [];

              for (var htmlFile in files!) {
                PlatformFile file = await _parseHtmlFile(htmlFile);
                platformFiles.add(file);
              }
              if (widget.onDropMultiple != null) {
                widget.onDropMultiple!(platformFiles);
              }
            },
          ),
        widget.child,
        if (isHovering)
          Positioned.fill(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: context.colorTheme.primary,
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(MdiIcons.trayArrowDown, size: 40),
                    const SizedBox(height: 20),
                    Text(
                      'Drop Files Here',
                      style: context.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
