import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/feature/orders/view/local/order_list_table.dart';
import 'package:gngm/feature/orders/view/local/order_tile.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:gngm/feature/orders/ctrl/order_list_ctrl.dart';
import 'package:gngm/feature/orders/providers/order_provider.dart';
import 'package:gngm/feature/orders/view/local/order_filter_dialog.dart';
import 'package:gngm/models/models.dart';
import 'package:gngm/widget/widget.dart';

class OrderListView extends ConsumerWidget {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersData = ref.watch(orderListCtrlProvider);
    final orderCtrl = ref.read(orderListCtrlProvider.notifier);
    final counts = ref.watch(orderCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton.outlined(
            onPressed: () {
              orderCtrl.reload();
              return ref.refresh(orderCountProvider.future);
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ).adapt(context),
          if (!context.isSmall) const SizedBox(width: 10),
          IconButton.outlined(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const OrderSearchDialog(),
              );
            },
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search',
          ).adapt(context),
          const SizedBox(width: 10),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: counts.maybeWhen(
            data: (data) => OrderCounts(
              data: data,
              onTap: (status) {
                orderCtrl.setOrderStatus(status);
                orderCtrl.filter(context);
              },
            ),
            error: (e, s) => Toaster.show('$e'),
            orElse: () => Loader.shimmer(),
          ),
        ),
      ),
      body: ordersData.orders.when(
        error: ErrorView.errorMathod,
        loading: Loader.loading,
        data: (orders) => Padding(
          padding: const EdgeInsets.all(10),
          child: SmartRefresher(
            controller: orderCtrl.refreshCtrl,
            enablePullUp: true,
            onRefresh: () {
              orderCtrl.reload();
              return ref.refresh(orderCountProvider.future);
            },
            onLoading: () => orderCtrl.loadMore(),
            child: context.isSmall
                ? ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) =>
                        Card(child: OrderTile(order: orders[index])),
                  )
                : OrderListTable(orders: orders),
          ),
        ),
      ),
    );
  }
}

class OrderCounts extends StatelessWidget {
  const OrderCounts({
    super.key,
    required this.onTap,
    required this.data,
  });

  final Function(OrderStatus status) onTap;
  final Map<OrderStatus, int> data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            ...data.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.all(5),
                child: InputChip(
                  side: BorderSide(color: e.key.color),
                  onPressed: () => onTap(e.key),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.key.title),
                      const SizedBox(width: 10),
                      Text('${e.value}'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
