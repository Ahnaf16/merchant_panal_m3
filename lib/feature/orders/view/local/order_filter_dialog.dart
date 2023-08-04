import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/feature/orders/ctrl/order_list_ctrl.dart';
import 'package:gngm/models/models.dart';
import 'package:gngm/widget/decorated.dart';

class OrderSearchDialog extends ConsumerWidget {
  const OrderSearchDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderListCtrlProvider);
    final orderCtrl = ref.read(orderListCtrlProvider.notifier);

    return WillPopScope(
      onWillPop: () => Future(() => true),
      child: AlertDialog(
        alignment: Alignment.topCenter + const Alignment(0, 0.3),
        actions: [
          IconButton.outlined(
            onPressed: () => context.pop,
            icon: const Icon(Icons.close_rounded),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              await orderCtrl.filter(context);
              context.pop;
            },
            icon: const Icon(Icons.search_rounded),
            label: const Text('Search'),
          ),
        ],
        content: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter Orders',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              TextField(
                // focusNode: orderCtrl.searchFocus..requestFocus(),
                controller: orderCtrl.searchCtrl,
                textInputAction: TextInputAction.go,
                onSubmitted: (value) => orderCtrl.filter(context),
                decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  suffixIcon: IconButton(
                    onPressed: () => orderCtrl.filter(context),
                    icon: const Icon(Icons.search_outlined),
                  ),
                  hintText: 'Search ...',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: KDecorated(
                      hint: 'Status',
                      child: DropdownButton<OrderStatus>(
                        padding: const EdgeInsets.all(8),
                        underline: Container(),
                        value: orderState.status,
                        isDense: true,
                        isExpanded: true,
                        items: [
                          ...OrderStatus.values.map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.title),
                            ),
                          ),
                        ],
                        onChanged: (value) => orderCtrl.setOrderStatus(value!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: KDecorated(
                      hint: 'Payment Method',
                      child: DropdownButton<PaymentMethods>(
                        padding: const EdgeInsets.all(8),
                        underline: Container(),
                        value: orderState.payment,
                        isDense: true,
                        isExpanded: true,
                        items: [
                          ...PaymentMethods.values.map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.title),
                            ),
                          ),
                        ],
                        onChanged: (value) => orderCtrl.setPayment(value!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: orderState.firstDate,
                    lastDate: orderState.lastDate,
                    builder: (context, child) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: context.adaptiveWidth(),
                            maxHeight: context.adaptiveHeight(),
                          ),
                          child: child,
                        ),
                      ],
                    ),
                  );
                  orderCtrl.setDateRange(range);
                },
                icon: const Icon(Icons.schedule_rounded),
                label: const Text('Pick Date Range'),
              ),
              if (orderState.dateRange != null)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Chip(
                    padding: const EdgeInsets.all(8),
                    onDeleted: () => orderCtrl.clearDateRange(),
                    label: Text(
                      '${orderState.dateRange!.start.formatDate()}  '
                      'To  ${orderState.dateRange!.end.formatDate()}',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
