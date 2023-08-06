import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/auth/ctrl/auth_ctrl.dart';
import 'package:merchant_m3/theme/theme_manager.dart';
import 'package:merchant_m3/widget/widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../routes/route_names.dart';

class ToolsView extends ConsumerWidget {
  const ToolsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authCtrl = ref.read(authCtrlProvider.notifier);
    final themeCtrl = ref.read(themeManagerProvider.notifier);
    final themeMode = ref.watch(themeManagerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              ...ThemeMode.values.map(
                (e) => PopupMenuTile(
                  icon: e.icon,
                  child: Text(e.name.toTitleCase),
                  onTap: () => themeCtrl.setThemeMode(e),
                ),
              ),
            ],
            child: IgnorePointer(
              child: IconButton.filledTonal(
                onPressed: () {},
                icon: Icon(themeMode.icon),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.outlined(
            onPressed: () => authCtrl.logOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            InformativeCard(
              header: 'Features',
              headerStyle: context.textTheme.titleMedium,
              useWrap: true,
              children: [
                SquaredButton(
                  title: "Campaign",
                  icon: Icons.campaign,
                  onTap: () {
                    context.pushTo(RoutesName.campaign);
                  },
                ),
                SquaredButton(
                  title: "Flash Sale",
                  icon: Icons.flash_on_outlined,
                  onTap: () {
                    context.pushTo(RoutesName.flash);
                  },
                ),
                SquaredButton(
                  title: "Slider",
                  icon: CupertinoIcons.photo_fill,
                  onTap: () {
                    context.pushTo(RoutesName.slider);
                  },
                ),
                SquaredButton(
                  title: 'Vouchers',
                  icon: Icons.card_giftcard_rounded,
                  onTap: () {},
                ),
                SquaredButton(
                  title: 'NewsFeed',
                  icon: Icons.newspaper_rounded,
                  onTap: () {},
                ),
                SquaredButton(
                  title: 'Videos',
                  icon: Icons.video_settings_rounded,
                  onTap: () {},
                ),
              ],
            ),
            InformativeCard(
              header: 'Database',
              headerStyle: context.textTheme.titleMedium,
              useWrap: true,
              children: [
                SquaredButton(
                  title: "POS",
                  icon: Icons.point_of_sale_rounded,
                  onTap: () {
                    context.pushTo(RoutesName.pos);
                  },
                ),
                SquaredButton(
                  title: 'Versions',
                  icon: MdiIcons.sourceBranch,
                  onTap: () => context.pushTo(RoutesName.appVersion),
                ),
                SquaredButton(
                  title: 'Gateways',
                  icon: Icons.credit_card_rounded,
                  onTap: () {},
                ),
                SquaredButton(
                  title: 'Delivery',
                  icon: Icons.local_shipping_rounded,
                  onTap: () => context.pushTo(RoutesName.delivery),
                ),
              ],
            ),
            InformativeCard(
              header: 'Management',
              headerStyle: context.textTheme.titleMedium,
              useWrap: true,
              children: [
                SquaredButton(
                  title: "Customers",
                  icon: Icons.person_rounded,
                  onTap: () {},
                ),
                SquaredButton(
                  title: 'Employee',
                  icon: Icons.badge_rounded,
                  onTap: () {
                    context.pushTo(RoutesName.employee);
                  },
                ),
                SquaredButton(
                  title: 'Dev Zone',
                  icon: Icons.handyman_rounded,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
