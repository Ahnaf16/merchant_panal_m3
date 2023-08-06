import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/campaign/ctrl/campaign_ctrl.dart';
import 'package:merchant_m3/feature/campaign/provider/campaign_provider.dart';
import 'package:merchant_m3/feature/employee/provider/employee_provider.dart';
import 'package:merchant_m3/models/models.dart';
import 'package:merchant_m3/routes/route_names.dart';
import 'package:merchant_m3/widget/widget.dart';

class CampaignListView extends ConsumerWidget {
  const CampaignListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsData = ref.watch(campaignListProvider);
    final campaignCtrl = ref.read(campaignEditCtrlProvider(null).notifier);
    final employee = ref.watch(permissionProvider);

    final canUpdate = EPermissions.campaignAdd.canDo(employee);
    final canDelete = EPermissions.campaignDelete.canDo(employee);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns'),
        actions: [
          FilledButton.icon(
            onPressed: () => context.pushTo(RoutesName.addCampaign),
            icon: const Icon(Icons.add),
            label: const Text("Add Campaign"),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: campaignsData.when(
        error: ErrorView.errorMathod,
        loading: Loader.loading,
        data: (campaigns) => Padding(
          padding: const EdgeInsets.all(10),
          child: MasonryGridView.builder(
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.crossAxisCustom(1, 2, 3),
            ),
            itemCount: campaigns.length,
            itemBuilder: (BuildContext context, int index) {
              final campaign = campaigns[index];

              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => context
                      .pushTo(RoutesName.campaignDetails(campaign.title)),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          KCachedImg(
                            url: campaign.image,
                            height: 150,
                            width: double.maxFinite,
                          ),
                          Text(
                            campaign.title,
                            style: context.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                      Positioned(
                        right: 0,
                        child: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuTile(
                              icon: Icons.edit_rounded,
                              onTap: () => context.pushTo(
                                  RoutesName.editCampaign(campaign.title)),
                              child: const Text('Edit'),
                            ),
                            if (canUpdate)
                              PopupMenuTile(
                                icon: Icons.move_up_rounded,
                                onTap: () {
                                  campaignCtrl.updatePriority(campaign, true);
                                },
                                child: const Text('Move Up'),
                              ),
                            if (canUpdate)
                              PopupMenuTile(
                                icon: Icons.move_down_rounded,
                                onTap: () {
                                  final campaignCtrl = ref.read(
                                      campaignEditCtrlProvider(null).notifier);
                                  campaignCtrl.updatePriority(campaign, false);
                                },
                                child: const Text('Move Down'),
                              ),
                            if (canDelete)
                              PopupMenuTile(
                                icon: Icons.delete_rounded,
                                onTap: () async {
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
                                            icon:
                                                const Icon(Icons.close_rounded),
                                          ),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await campaignCtrl
                                                  .deleteCampaign(campaign);
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
                            padding: EdgeInsets.all(3),
                            icon: Icons.more_horiz_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
