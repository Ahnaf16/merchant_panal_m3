import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/feature/orders/ctrl/order_ctrl.dart';
import 'package:gngm/models/models.dart';

class UpdateStatusDialog extends ConsumerWidget {
  const UpdateStatusDialog({
    super.key,
    required this.order,
  });
  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderCtrl = ref.watch(orderCtrlProvider(order).notifier);
    return AlertDialog(
      title: const Text('Update Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<OrderStatus>(
            isDense: true,
            value: order.status,
            items: [
              ...OrderStatus.kValue.map(
                (e) => DropdownMenuItem<OrderStatus>(
                  value: e,
                  child: Text(e.title),
                ),
              ),
            ],
            onChanged: (value) {
              orderCtrl.setOrderStatus(value!);
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: orderCtrl.statusCommentCtrl,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Comment',
            ),
          ),
        ],
      ),
      actions: [
        IconButton.outlined(
          onPressed: () => context.pop,
          icon: const Icon(Icons.close_rounded),
        ),
        OutlinedButton(
          onPressed: () => orderCtrl.updateOrderStatus(context),
          child: const Text('Update'),
        ),
      ],
    );
  }
}
