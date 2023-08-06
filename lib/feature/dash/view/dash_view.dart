import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';

import 'package:merchant_m3/feature/orders/providers/order_provider.dart';
import 'package:merchant_m3/routes/route_names.dart';
import 'package:merchant_m3/widget/widget.dart';

class DashView extends ConsumerStatefulWidget {
  const DashView({super.key});

  @override
  ConsumerState<DashView> createState() => _DashViewState();
}

class _DashViewState extends ConsumerState<DashView> {
  @override
  Widget build(BuildContext context) {
    final counts = ref.watch(orderCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: AdaptiveBody(
            child: Column(
              children: [
                counts.maybeWhen(
                  error: ErrorView.errorMathod,
                  orElse: () => Loader.shimmer(),
                  data: (data) => InformativeCard(
                    header: 'Orders',
                    headerStyle: context.textTheme.bodyLarge,
                    actions: [
                      IconButton(
                        iconSize: 15,
                        onPressed: () => context.pushTo(RoutesName.orders),
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ),
                    ],
                    children: [
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ...data.entries.map(
                              (e) => Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: e.key.color),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 5,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(e.key.title),
                                      Text('${e.value}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
