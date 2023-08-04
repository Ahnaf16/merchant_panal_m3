import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/feature/version_manager/ctrl/app_version_ctrl.dart';
import 'package:gngm/feature/version_manager/provider/app_version_provider.dart';
import 'package:gngm/feature/auth/ctrl/auth_ctrl.dart';
import 'package:gngm/feature/employee/provider/employee_provider.dart';
import 'package:gngm/models/models.dart';
import 'package:gngm/widget/widget.dart';
import 'package:routemaster/routemaster.dart';

class RootNavigationView extends ConsumerStatefulWidget {
  const RootNavigationView({super.key});

  @override
  ConsumerState<RootNavigationView> createState() => _RootNavigationViewState();
}

class _RootNavigationViewState extends ConsumerState<RootNavigationView> {
  bool extended = true;
  @override
  Widget build(BuildContext context) {
    final indexedPage = IndexedPage.of(context);

    final employee = ref.watch(permissionProvider);
    final authCtrl = ref.read(authCtrlProvider.notifier);

    final versionData = ref.watch(realTimeVersionProvider);

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(context.mq.viewPadding.top),
          child: SizedBox(height: context.mq.viewPadding.top),
        ),
        body: Stack(
          children: [
            AdaptiveLayout(
              primaryNavigation: SlotLayout(
                config: <Breakpoint, SlotLayoutConfig>{
                  Breakpoints.medium: SlotLayout.from(
                    key: const Key('Primary Navigation Medium'),
                    inAnimation: AdaptiveScaffold.leftOutIn,
                    builder: (_) {
                      return AdaptiveScaffold.standardNavigationRail(
                        selectedIndex: indexedPage.index,
                        onDestinationSelected: (int newIndex) =>
                            indexedPage.index = newIndex,
                        leading: header(false, employee),
                        destinations: destinations,
                        trailing: Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Divider(height: 40),
                              IconButton.filledTonal(
                                onPressed: () => authCtrl.logOut(),
                                icon: const Icon(Icons.logout_rounded),
                                tooltip: 'Logout',
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Breakpoints.large: SlotLayout.from(
                    key: const Key('Primary Navigation Large'),
                    inAnimation: AdaptiveScaffold.leftOutIn,
                    builder: (_) => RepaintBoundary(
                      child: AdaptiveScaffold.standardNavigationRail(
                        selectedIndex: indexedPage.index,
                        onDestinationSelected: (int newIndex) {
                          indexedPage.index = newIndex;
                        },
                        extended: extended,
                        destinations: destinations,
                        leading: header(extended, employee),
                        trailing: Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Divider(height: 40),
                              if (extended)
                                TextButton.icon(
                                  style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(40)),
                                  onPressed: () => authCtrl.logOut(),
                                  label: const Text('Log Out'),
                                  icon: const Icon(Icons.logout_rounded),
                                )
                              else
                                IconButton.filledTonal(
                                  onPressed: () => authCtrl.logOut(),
                                  icon: const Icon(Icons.logout_rounded),
                                  tooltip: 'Logout',
                                ),
                              const SizedBox(height: 10),
                              IconButton(
                                onPressed: () =>
                                    setState(() => extended = !extended),
                                icon: extended
                                    ? const Icon(
                                        Icons.arrow_back_ios_new_rounded)
                                    : const Icon(
                                        Icons.arrow_forward_ios_rounded),
                                tooltip: 'Expand',
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                },
              ),
              body: SlotLayout(
                config: <Breakpoint, SlotLayoutConfig>{
                  Breakpoints.small: SlotLayout.from(
                    key: const Key('Body Small'),
                    builder: (_) =>
                        PageStackNavigator(stack: indexedPage.currentStack),
                  ),
                  Breakpoints.mediumAndUp: SlotLayout.from(
                    key: const Key('Body Medium'),
                    builder: (_) =>
                        PageStackNavigator(stack: indexedPage.currentStack),
                  )
                },
              ),
              bottomNavigation: SlotLayout(
                config: <Breakpoint, SlotLayoutConfig>{
                  Breakpoints.small: SlotLayout.from(
                    key: const Key('Bottom Navigation Small'),
                    inAnimation: AdaptiveScaffold.bottomToTop,
                    outAnimation: AdaptiveScaffold.topToBottom,
                    builder: (_) => NavigationBar(
                      destinations: destinationSmall,
                      selectedIndex: indexedPage.index,
                      onDestinationSelected: (int newIndex) =>
                          indexedPage.index = newIndex,
                    ),
                  ),
                },
              ),
            ),
            versionData.maybeWhen(
              orElse: () => const SizedBox.shrink(),
              data: (version) => version.canUpdateMerchant
                  ? UpdateAppDialog(version)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Column header(bool isExpanded, EmployeeModel? employee) {
    final indent = isExpanded ? 10.0 : 5.0;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 15, 0, 8),
          child: Row(
            children: [
              KCachedImg(
                radius: 180,
                height: 40,
                width: 40,
                url: employee?.photo ?? AuthDefaults.employeePhoto,
                showPreview: true,
              ),
              if (isExpanded) const SizedBox(width: 5),
              if (isExpanded)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(employee?.name ?? ''),
                    Text(employee?.email ?? ''),
                  ],
                ),
            ],
          ),
        ),
        Divider(indent: indent, endIndent: indent),
      ],
    );
  }

  List<NavigationRailDestination> get destinations => [
        const NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: Text('Dashboard'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt_rounded),
          label: Text('Products'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle_rounded),
          label: Text('Add Products'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.shopping_bag_outlined),
          selectedIcon: Icon(Icons.shopping_bag_rounded),
          label: Text('Orders'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.point_of_sale_outlined),
          selectedIcon: Icon(Icons.point_of_sale_rounded),
          label: Text('POS'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.campaign_outlined),
          selectedIcon: Icon(Icons.campaign_rounded),
          label: Text('Campaign'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.flash_on_outlined),
          selectedIcon: Icon(Icons.flash_on_rounded),
          label: Text('Flash Sale'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.card_giftcard_outlined),
          selectedIcon: Icon(Icons.card_giftcard_rounded),
          label: Text('Vouchers'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.slideshow_outlined),
          selectedIcon: Icon(Icons.slideshow_rounded),
          label: Text('Slider'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.newspaper_outlined),
          selectedIcon: Icon(Icons.newspaper_rounded),
          label: Text('News'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.handyman_outlined),
          selectedIcon: Icon(Icons.handyman_rounded),
          label: Text('More'),
        ),
      ];

  List<NavigationDestination> get destinationSmall => [
        const NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        const NavigationDestination(
          icon: Icon(Icons.list_alt),
          selectedIcon: Icon(Icons.list_alt_rounded),
          label: 'Products',
        ),
        const NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle_rounded),
          label: 'Add Product',
        ),
        const NavigationDestination(
          icon: Icon(Icons.shopping_bag_outlined),
          selectedIcon: Icon(Icons.shopping_bag_rounded),
          label: 'Orders',
        ),
        const NavigationDestination(
          icon: Icon(Icons.handyman_outlined),
          selectedIcon: Icon(Icons.handyman_rounded),
          label: 'More',
        ),
      ];
}

class UpdateAppDialog extends ConsumerWidget {
  const UpdateAppDialog(this.version, {super.key});

  final AppVersionModel version;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionCtrl = ref.read(appVersionProvider.notifier);
    final progress = ref.watch(progressVAlueProvider);
    if (kIsWeb) {
      return AlertDialog(
        title: const Text('Update Available'),
        content: Text(
          'Version ${version.fullVersion} is available.\n'
          'Please Reload webpage',
        ),
        actions: [
          if (progress.status == ProgressStatus.notStarted)
            FilledButton.icon(
              onPressed: () {
                versionCtrl.reloadWebToUpdateCatch();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reload'),
            ),
        ],
      );
    }
    return AlertDialog(
      title: const Text('Update Available'),
      content: Text(
        'Version ${version.fullVersion} is available',
      ),
      actions: [
        if (progress.value.isNegative)
          const CircularProgressIndicator()
        else if (progress.status == ProgressStatus.notStarted)
          FilledButton.icon(
            onPressed: () => versionCtrl.downloadNewVersion(version),
            icon: const Icon(Icons.download_rounded),
            label: const Text('Update'),
          )
        else if (progress.status == ProgressStatus.started)
          CircularProgressIndicator(
            value: progress.value.isNegative ? null : progress.value,
          )
        else if (progress.status == ProgressStatus.complete)
          FilledButton.icon(
            onPressed: () => versionCtrl.openApk(version),
            icon: const Icon(Icons.install_mobile_rounded),
            label: const Text('Install'),
          )
      ],
    );
  }
}
