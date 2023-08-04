import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';

import 'package:gngm/feature/campaign/ctrl/campaign_ctrl.dart';
import 'package:gngm/feature/products/ctrl/products_list_ctrl.dart';
import 'package:gngm/feature/products/view/local/product_search_sheet.dart';
import 'package:gngm/models/models.dart';
import 'package:gngm/widget/widget.dart';

class AddUpdateCampaignView extends ConsumerWidget {
  const AddUpdateCampaignView(this.title, {super.key});

  final String? title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parsedTitle = title?.replaceAll('_', ' ');

    final campaignImgFile = ref.watch(campaignImageStateProvider);
    final campaign = ref.watch(campaignEditCtrlProvider(parsedTitle));
    final campaignCtrl =
        ref.read(campaignEditCtrlProvider(parsedTitle).notifier);

    final productCtrl = ref.read(productsListCtrlProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(title == null ? 'Add Campaign' : 'Update Campaign'),
        actions: [
          IconButton.outlined(
            onPressed: () {
              campaignCtrl.reload();
              productCtrl.clear();
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ).adapt(context),
          if (kIsWeb) const SizedBox(width: 10),
          IconButton.filledTonal(
            onPressed: () {
              campaignCtrl.uploadCampaign(context, title != null);
            },
            icon: const Icon(Icons.done_rounded),
            tooltip: 'Upload',
          ).adapt(context),
          const SizedBox(width: 10),
        ],
      ),
      body: DropZoneWarper(
        onDrop: (file) => campaignCtrl.onImageDrop(file),
        child: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: AdaptiveBody(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InformativeCard(
                    header: 'Campaign Details',
                    actions: [
                      FilledButton.icon(
                        onPressed: () => campaignCtrl.selectImage(),
                        icon: const Icon(Icons.add_photo_alternate_rounded),
                        label: const Text('Add Image'),
                      ),
                    ],
                    children: [
                      if (campaign.campaign.image.isEmpty &&
                          campaignImgFile == null)
                        Card(
                          color: context.colorTheme.surfaceVariant,
                          child: const SizedBox(
                            height: 150,
                            width: double.maxFinite,
                            child: Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 40,
                            ),
                          ),
                        ),
                      if (campaign.campaign.image.isNotEmpty)
                        Stack(
                          children: [
                            KCachedImg(
                              url: campaign.campaign.image,
                              height: 150,
                              width: double.maxFinite,
                              showPreview: true,
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton.filledTonal(
                                onPressed: () => campaignCtrl.removeImage(true),
                                icon: const Icon(Icons.remove_rounded),
                              ),
                            ),
                          ],
                        ),
                      if (campaignImgFile != null)
                        Stack(
                          children: [
                            KImage(
                              campaignImgFile,
                              height: 150,
                              width: double.maxFinite,
                              showPreview: true,
                            ),
                            const Positioned(
                              bottom: -10,
                              left: -10,
                              child: Icon(Icons.cloud_off_rounded),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton.filledTonal(
                                onPressed: () => campaignCtrl.removeImage(true),
                                icon: const Icon(Icons.remove_rounded),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      IgnorePointer(
                        ignoring: title != null,
                        child: TextField(
                          controller: campaignCtrl.titleCtrl,
                          decoration: InputDecoration(
                            labelText: 'Campaign Name',
                            helperText: title == null
                                ? null
                                : 'Campaign Title is not updatable',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                  const SizedBox(height: 20),
                  InformativeCard(
                    header: 'Campaign Products',
                    actions: [
                      FilledButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => ProductSearchBottomSheet(
                              onTrailingTap: (product) =>
                                  campaignCtrl.addProduct(product),
                            ),
                          );
                        },
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('Search'),
                      ),
                    ],
                    children: [
                      ...campaign.products.map(
                        (product) => ListTile(
                          leading: KCachedImg(
                            url: product.img,
                            width: 50,
                          ),
                          trailing: IconButton.filledTonal(
                            onPressed: () =>
                                campaignCtrl.removeProduct(product),
                            icon: const Icon(Icons.close_rounded),
                          ),
                          title: Text(product.name.showUntil(20)),
                          subtitle:
                              Text(product.price.toCurrency()).withDiscount(
                            product.discount,
                            product.haveDiscount,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
