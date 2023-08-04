import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:gngm/core/core.dart';
import 'package:gngm/feature/slider/controller/slider_controller.dart';
import 'package:gngm/feature/slider/provider/slider_provider.dart';
import 'package:gngm/widget/widget.dart';

class SliderView extends ConsumerWidget {
  const SliderView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sliderData = ref.watch(sliderListProvider);
    final sliderCtrl = ref.read(slideCtrlProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Slider Images'),
        actions: [
          FilledButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const AddImageDialog(),
            ),
            label: const Text('Add Image'),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: sliderData.when(
        error: ErrorView.errorMathod,
        loading: Loader.loading,
        data: (sliders) => Padding(
          padding: const EdgeInsets.all(20),
          child: MasonryGridView.builder(
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.crossAxisCustom(1, 2, 3),
            ),
            itemCount: sliders.length,
            itemBuilder: (context, index) => Stack(
              children: [
                Card(
                  child: KCachedImg(
                    url: sliders[index].img,
                    width: double.maxFinite,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuTile(
                        icon: Icons.delete_rounded,
                        onTap: () {
                          Future.delayed(
                            Duration.zero,
                            () => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete ?'),
                                content: const Text('Are you sure ??'),
                                actions: [
                                  IconButton.outlined(
                                    onPressed: () => context.pop,
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                                  OutlinedButton(
                                    onPressed: () async {
                                      await sliderCtrl
                                          .deleteSlider(sliders[index]);
                                      context.pop;
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                    child: const SmallCircularButton(
                      padding: EdgeInsets.all(5),
                      icon: Icons.more_horiz_rounded,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddImageDialog extends ConsumerWidget {
  const AddImageDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slider = ref.watch(slideCtrlProvider);
    final sliderCtrl = ref.read(slideCtrlProvider.notifier);
    final sliderImgFile = ref.watch(slideImageStateProvider);

    return AlertDialog(
      title: const Text('Add Image'),
      actions: [
        IconButton.outlined(
          onPressed: () => context.pop,
          icon: const Icon(
            Icons.close_rounded,
          ),
        ),
        FilledButton(
          onPressed: () => sliderCtrl.reset(),
          child: const Text('Reset'),
        ),
        FilledButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Are you sure'),
              content: const Text('Confirm image upload'),
              actions: [
                IconButton.outlined(
                  onPressed: () => context.pop,
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                ),
                FilledButton(
                  onPressed: () => sliderCtrl.addSlider(context),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
          child: const Text('Upload'),
        ),
      ],
      content: SizedBox(
        height: 200,
        child: DropZoneWarper(
          onDrop: (file) => sliderCtrl.onImageDropped(file),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              if (sliderImgFile == null && slider.img.isEmpty)
                SizedBox(
                  height: 150,
                  width: context.adaptiveWidth(),
                  child: OutlinedButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: context.colorTheme.surfaceVariant,
                      foregroundColor: context.colorTheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: const Text('Drop or Select Image'),
                    onPressed: () => sliderCtrl.selectImage(),
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                  ),
                ),
              if (sliderImgFile != null)
                KImage(
                  sliderImgFile,
                  height: 150,
                  width: context.adaptiveWidth(),
                  fit: BoxFit.cover,
                  showPreview: true,
                ),
              if (slider.img.isNotEmpty)
                KCachedImg(
                  url: slider.img,
                  height: 150,
                  width: context.adaptiveWidth(),
                  fit: BoxFit.cover,
                  showPreview: true,
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
