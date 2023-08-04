import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/feature/campaign/provider/campaign_provider.dart';
import 'package:gngm/feature/employee/provider/employee_provider.dart';
import 'package:gngm/models/models.dart';
import 'package:gngm/routes/route_names.dart';
import 'package:gngm/widget/widget.dart';

class CampaignDetailsView extends ConsumerWidget {
  const CampaignDetailsView(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parsedTitle = title.replaceAll('_', ' ');
    final campaignsDetailsData = ref.watch(campaignItemsProvider(parsedTitle));
    final employee = ref.watch(permissionProvider);

    final canUpdate = EPermissions.campaignAdd.canDo(employee);

    return Scaffold(
      appBar: AppBar(
        title: Text(parsedTitle),
      ),
      floatingActionButton: canUpdate
          ? FloatingActionButton(
              onPressed: () => context.pushTo(RoutesName.editCampaign(title)),
              child: const Icon(Icons.edit_rounded),
            )
          : null,
      body: campaignsDetailsData.when(
        error: ErrorView.errorMathod,
        loading: Loader.loading,
        data: (products) => Padding(
          padding: const EdgeInsets.all(20),
          child: AdaptiveBody(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final product = products[index];
                return Card(
                  child: ListTile(
                    leading: KCachedImg(
                      url: product.img,
                      height: 40,
                      width: 40,
                    ),
                    title: Text(product.name),
                    subtitle: Text(product.price.toCurrency())
                        .withDiscount(product.discount, product.haveDiscount),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
