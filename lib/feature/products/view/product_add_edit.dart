// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gngm/core/core.dart';
import 'package:gngm/feature/products/ctrl/product_add_edit_ctrl.dart';
import 'package:gngm/models/product/categories.dart';
import 'package:gngm/widget/widget.dart';

class ProductAddEdit extends ConsumerWidget {
  const ProductAddEdit(this.id, {super.key});
  final String? id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productsEditCtrlProvider(id));
    final productCtrl = ref.read(productsEditCtrlProvider(id).notifier);
    final imageState = ref.watch(productImageStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton.outlined(
            onPressed: () => productCtrl.reload(id),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ).adapt(context),
          if (kIsWeb) const SizedBox(width: 10),
          if (id != null)
            IconButton.outlined(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Create Duplicate ?'),
                      content: const Text('Are you sure ??'),
                      actions: [
                        IconButton.outlined(
                          onPressed: () {
                            context.pop;
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            await context.pop;
                            productCtrl.createDuplicate(context);
                          },
                          child: const Text('Duplicate'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.content_copy_rounded),
              tooltip: 'Create Duplicate',
            ).adapt(context),
          if (id != null) const SizedBox(width: 10),
          IconButton.filledTonal(
            onPressed: () async => productCtrl.showPreview(context, id != null),
            icon: const Icon(Icons.upload_rounded),
            tooltip: 'Preview',
          ).adapt(context),
          const SizedBox(width: 10),
        ],
      ),
      body: DropZoneWarper(
        onDropMultiple: (files) => productCtrl.onImageDrop(files),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: AdaptiveBody(
              width: context.adaptiveWidth(
                large: context.width / 1.5,
                mid: context.width / 1.4,
              ),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    context.colorTheme.surfaceVariant,
                                padding: const EdgeInsets.all(20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => productCtrl.selectImage(),
                              icon: const Icon(
                                Icons.add_photo_alternate_outlined,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              spacing: 5,
                              runSpacing: 5,
                              children: [
                                // Show selected image (not yet uploaded)
                                if (imageState.isNotEmpty)
                                  ...List.generate(
                                    imageState.length,
                                    (index) => Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Card(
                                          color:
                                              context.colorTheme.surfaceVariant,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: KImage(
                                              imageState[index],
                                              showPreview: true,
                                              height: 80,
                                              width: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Icon(
                                            Icons.cloud_off_rounded,
                                            size: 15,
                                          ),
                                        ),
                                        Positioned(
                                          right: -5,
                                          top: -5,
                                          child: SmallCircularButton(
                                            onTap: () => productCtrl
                                                .removeImage(index, true),
                                            icon: Icons.remove_rounded,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // Show uploaded product image
                                ...List.generate(
                                  product.imgUrls.length,
                                  (index) => Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Card(
                                        color:
                                            context.colorTheme.surfaceVariant,
                                        child: KCachedImg(
                                          url: product.imgUrls[index],
                                          height: 80,
                                          width: 80,
                                          showPreview: true,
                                        ),
                                      ),
                                      Positioned(
                                        right: -5,
                                        top: -5,
                                        child: SmallCircularButton(
                                          onTap: () => productCtrl.removeImage(
                                              index, false),
                                          icon: Icons.remove_rounded,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Row(
                      children: [
                        Flexible(
                          child: SwitchListTile(
                            title: const Text('Enabled'),
                            value: product.isEnabled,
                            onChanged: (value) => productCtrl.toggleEnabled(),
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: context.colorTheme.outline,
                        ),
                        Flexible(
                          child: SwitchListTile(
                            title: const Text('In Stock'),
                            value: product.inStock,
                            onChanged: (value) {
                              productCtrl.toggleStock();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(
                            controller: productCtrl.nameCtrl,
                            textInputAction: TextInputAction.next,
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Flexible(
                                child: TextField(
                                  controller: productCtrl.brandCtrl,
                                  textInputAction: TextInputAction.next,
                                  decoration:
                                      const InputDecoration(labelText: 'Brand'),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Flexible(
                                child: DropdownButtonFormField<String>(
                                  hint: const Text('Category'),
                                  isExpanded: true,
                                  value: product.category.isEmpty
                                      ? null
                                      : product.category,
                                  items: [
                                    ...Categories.values.map(
                                      (e) => DropdownMenuItem(
                                        value: e.title,
                                        child: Text(e.title),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    productCtrl.updateCategory(value ?? '');
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Flexible(
                                child: TextField(
                                  controller: productCtrl.priceCtrl,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  decoration:
                                      const InputDecoration(labelText: 'Price'),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Flexible(
                                child: TextField(
                                  controller: productCtrl.discountCtrl,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Discount',
                                    suffixIcon: Checkbox(
                                      value: product.haveDiscount,
                                      onChanged: (value) {
                                        productCtrl.toggleDiscount();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 120,
                            child: TextField(
                              controller: productCtrl.discCtrl,
                              textInputAction: TextInputAction.next,
                              maxLines: null,
                              expands: true,
                              decoration: const InputDecoration(
                                  labelText: 'Description'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: productCtrl.specCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Specification',
                              prefixIcon: IconButton(
                                onPressed: () {
                                  productCtrl.addSpec();
                                },
                                icon: const Icon(Icons.arrow_downward_rounded),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  productCtrl.specCtrl.clear();
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ...List.generate(
                                ProductConst.specList.length,
                                (index) {
                                  final spec = ProductConst.specList[index];
                                  if (index == 0 || index == 1) {
                                    return PopupMenuButton(
                                      itemBuilder: (context) {
                                        final list = index == 0
                                            ? ProductConst.ram
                                            : ProductConst.storage;
                                        return [
                                          ...list.map(
                                            (e) => PopupMenuItem(
                                              child: Text(e),
                                              onTap: () => productCtrl
                                                  .addSpecificSpec(spec, e),
                                            ),
                                          )
                                        ];
                                      },
                                      child: Chip(label: Text(spec)),
                                    );
                                  } else {
                                    return ChoiceChip(
                                      selected: false,
                                      onSelected: (value) {
                                        productCtrl.specCtrl.text = '$spec~';
                                      },
                                      label: Text(spec),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 40),
                          Text(
                            'Added Specification :',
                            style: context.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ...product.specifications.entries.map(
                                (e) => Chip(
                                  label: Text('${e.key} : ${e.value}'),
                                  onDeleted: () =>
                                      productCtrl.removeSpec(e.key),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
