import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/delivery/ctrl/delivery_ctrl.dart';
import 'package:merchant_m3/widget/widget.dart';

class DeliveryView extends ConsumerWidget {
  const DeliveryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryCtrl = ref.read(deliveryCtrlProvider.notifier);
    final delivery = ref.watch(deliveryCtrlProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Charges'),
        actions: [
          IconButton.outlined(
            onPressed: () => deliveryCtrl.reload(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ).adapt(context),
          if (!context.isSmall) const SizedBox(width: 10),
          IconButton.outlined(
            onPressed: () => deliveryCtrl.updateCharges(context),
            icon: const Icon(Icons.done_rounded),
            tooltip: 'Update',
          ).adapt(context),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: AdaptiveBody(
            child: Column(
              children: [
                Card(
                  child: SwitchListTile(
                    value: delivery.haveDelivery,
                    onChanged: deliveryCtrl.toggle,
                    title: const Text(
                      'Enable Delivery Charge',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                InformativeCard(
                  header: 'Phone Charges',
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: TextField(
                            controller: deliveryCtrl.phoneInsideCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Inside Dhaka',
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Flexible(
                          child: TextField(
                            controller: deliveryCtrl.phoneOutsideCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Outside Dhaka',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                InformativeCard(
                  header: 'Accessory Charges',
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: TextField(
                            controller: deliveryCtrl.accessoryInsideCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Inside Dhaka',
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Flexible(
                          child: TextField(
                            controller: deliveryCtrl.accessoryOutsideCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Outside Dhaka',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
