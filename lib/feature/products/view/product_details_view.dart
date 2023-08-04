import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/feature/employee/provider/employee_provider.dart';
import 'package:gngm/feature/products/provider/product_provider.dart';
import 'package:gngm/models/models.dart';
import 'package:gngm/routes/route_names.dart';
import 'package:gngm/widget/widget.dart';

class ProductDetailsView extends ConsumerWidget {
  const ProductDetailsView({
    super.key,
    required this.id,
  });

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productDetailsData = ref.watch(productDetailsProvider(id));
    final employee = ref.watch(permissionProvider);

    final canUpdate = EPermissions.productUpdate.canDo(employee);

    return productDetailsData.when(
      error: ErrorView.withScaffold,
      loading: Loader.withScaffold,
      data: (product) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Product Details'),
            actions: [
              IconButton(
                tooltip: 'Copy Product ID',
                onPressed: () => ClipBoardAPI.copy(product.id),
                icon: const Icon(Icons.copy_rounded),
              ),
              if (product.isEnabled)
                const Icon(Icons.visibility_rounded)
              else
                const Icon(Icons.visibility_off_rounded),
              const SizedBox(width: 10),
              if (product.inStock)
                const Icon(Icons.check_circle_rounded)
              else
                const Icon(Icons.cancel_rounded),
              const SizedBox(width: 10),
            ],
          ),
          floatingActionButton: canUpdate
              ? FloatingActionButton(
                  onPressed: () =>
                      context.pushTo(RoutesName.editProducts(product.id)),
                  child: const Icon(Icons.edit_rounded),
                )
              : null,
          body: AdaptiveBody(
            child: ProductDetailsBody(product: product),
          ),
        );
      },
    );
  }
}

class ProductDetailsBody extends StatelessWidget {
  const ProductDetailsBody({
    super.key,
    required this.product,
    this.imgFiles = const [],
  });

  final ProductModel product;
  final List<PlatformFile> imgFiles;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.imgUrls.isNotEmpty)
            CarouselSlider.builder(
              itemCount: product.imgUrls.length,
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                viewportFraction: context.isSmall ? 0.8 : 0.5,
              ),
              itemBuilder: (_, index, __) {
                return Card(
                  child: KCachedImg(
                    url: product.imgUrls[index],
                    fit: BoxFit.contain,
                    width: context.adaptiveWidth(),
                    showPreview: true,
                  ),
                );
              },
            ),
          if (imgFiles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20).copyWith(bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imgFiles.isNotEmpty)
                    Text(
                      'New Images',
                      style: context.textTheme.titleLarge,
                    ),
                  if (imgFiles.isNotEmpty) const SizedBox(height: 10),
                  if (imgFiles.isNotEmpty)
                    Wrap(
                      children: [
                        ...List.generate(
                          imgFiles.length,
                          (index) => Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Card(
                                color: context.colorTheme.surfaceVariant,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.memory(
                                    imgFiles[index].bytes!,
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Text('Enabled : ${product.isEnabled}'),
                  Text('In Stock : ${product.inStock}'),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  '${product.brand} - ${product.category}',
                  style: context.textTheme.titleSmall,
                ),
                Text(
                  product.variant,
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                product.pricingWidget,
                const Divider(height: 50),
                Text('Description', style: context.textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(product.description),
                const Divider(height: 50),
                Text(
                  'Specifications',
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...product.specifications.entries.map(
                      (e) => Chip(
                        label: Text('${e.key} : ${e.value}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
