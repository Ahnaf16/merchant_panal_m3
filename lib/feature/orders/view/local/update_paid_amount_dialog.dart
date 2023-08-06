import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/orders/ctrl/order_ctrl.dart';
import 'package:merchant_m3/models/models.dart';

class UpdatePaidAmountDialog extends ConsumerWidget {
  const UpdatePaidAmountDialog({
    super.key,
    required this.order,
  });
  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderCtrl = ref.watch(orderCtrlProvider(order).notifier);
    return AlertDialog(
      title: const Text('Update Paid Amount'),
      content: TextField(
        controller: orderCtrl.paidAmountCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          labelText: 'Paid Amount',
        ),
      ),
      actions: [
        IconButton.outlined(
          onPressed: () => context.pop,
          icon: const Icon(Icons.close_rounded),
        ),
        OutlinedButton(
          onPressed: () => orderCtrl.updatePaidAmount(context),
          child: const Text('Update'),
        ),
        FilledButton(
          onPressed: () => orderCtrl.updatePaidAmount(context, true),
          child: const Text('Full paid'),
        ),
      ],
    );
  }
}
