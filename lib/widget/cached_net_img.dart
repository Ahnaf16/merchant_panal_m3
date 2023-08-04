import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:gngm/core/core.dart';
import 'package:gngm/widget/shimmer.dart';

class KCachedImg extends StatelessWidget {
  const KCachedImg({
    super.key,
    this.color,
    this.fit = BoxFit.cover,
    this.height = 150,
    this.padding = const EdgeInsets.all(8.0),
    this.radius = 10,
    required this.url,
    this.width,
    this.showPreview = false,
  });

  final Color? color;
  final BoxFit fit;
  final double height;
  final EdgeInsetsGeometry padding;
  final double radius;
  final String url;
  final double? width;
  final bool showPreview;

  ImageProvider get provider => CachedNetworkImageProvider(url,
      maxHeight: height.toInt(), maxWidth: width?.toInt());

  _onTap(BuildContext context) => showDialog(
        context: context,
        builder: (context) => ImageDialog(url: url),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: showPreview ? () => _onTap(context) : null,
          child: CachedNetworkImage(
            color: color,
            height: height,
            width: width,
            imageUrl: url,
            fit: fit,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                KShimmer(
              child: SizedBox(
                height: height,
                width: width ?? 150,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class KImage extends StatelessWidget {
  const KImage(
    this.imgFile, {
    Key? key,
    this.height = 150,
    this.width,
    this.fit = BoxFit.cover,
    this.radius = 10,
    this.showPreview = false,
  }) : super(key: key);

  final BoxFit fit;
  final double height;
  final PlatformFile imgFile;
  final double radius;
  final double? width;
  final bool showPreview;

  ImageProvider<Object> get provider => kIsWeb
      ? MemoryImage(imgFile.bytes!)
      : FileImage(File(imgFile.path!)) as ImageProvider<Object>;

  _onTap(BuildContext context) => showDialog(
        context: context,
        builder: (context) => ImageDialog(imgFile: imgFile),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: showPreview ? () => _onTap(context) : null,
        child: Image(
          image: provider,
          height: height,
          width: width,
          fit: fit,
        ),
      ),
    );
  }
}

class ImageDialog extends StatelessWidget {
  const ImageDialog({
    super.key,
    this.url,
    this.imgFile,
  }) : assert(
          url != null || imgFile != null,
          'Both URL and PlatformFile cannot be null',
        );

  final PlatformFile? imgFile;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: IconButton.outlined(
        onPressed: () => context.pop,
        icon: const Icon(Icons.close),
      ),
      content: Center(
        child: url != null
            ? KCachedImg(
                url: url!,
                height: context.height,
                fit: BoxFit.contain,
              )
            : KImage(
                imgFile!,
                height: context.height,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
