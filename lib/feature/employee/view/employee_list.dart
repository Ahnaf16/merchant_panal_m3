import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/auth/ctrl/auth_ctrl.dart';
import 'package:merchant_m3/feature/auth/provider/auth_provider.dart';
import 'package:merchant_m3/feature/employee/ctrl/employee_ctrl.dart';
import 'package:merchant_m3/feature/employee/provider/employee_provider.dart';
import 'package:merchant_m3/models/models.dart';
import 'package:merchant_m3/routes/route_names.dart';
import 'package:merchant_m3/widget/widget.dart';

class EmployeeListView extends ConsumerWidget {
  const EmployeeListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authCtrl = ref.read(authCtrlProvider.notifier);
    final employeeData = ref.watch(employeeListProvider);

    return employeeData.when(
      loading: Loader.withScaffold,
      error: ErrorView.withScaffold,
      data: (data) {
        final self = data.where((element) => element.uid == getUser!.uid).first;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Employess'),
            actions: [
              IconButton.outlined(
                onPressed: () => authCtrl.logOut(),
                icon: const Icon(Icons.logout_rounded),
              ),
              if (kIsWeb) const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: () => context.pushTo(RoutesName.addEmployee),
                icon: const Icon(Icons.add_rounded),
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: AdaptiveBody(
              child: Column(
                children: [
                  EmployeeCard(
                    employee: self,
                    isExpanded: true,
                    canUpdate: EPermissions.employeeManage.canDo(self),
                  ),
                  const Divider(height: 30),
                  Expanded(
                    child: MasonryGridView.builder(
                      itemCount: data.length,
                      gridDelegate:
                          SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.crossAxisCustom(2, 3, 4),
                      ),
                      itemBuilder: (context, index) {
                        var employee = data[index];
                        return EmployeeCard(
                          employee: employee,
                          canUpdate: EPermissions.employeeManage.canDo(self),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class EmployeeCard extends ConsumerWidget {
  const EmployeeCard({
    super.key,
    required this.employee,
    this.isExpanded = false,
    required this.canUpdate,
  });

  final EmployeeModel employee;
  final bool isExpanded;
  final bool canUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeCtrl = ref.read(employeeCtrlProvider(null).notifier);

    return Card(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Padding(
              padding: EdgeInsets.all(isExpanded ? 20 : 10),
              child: Flex(
                direction: isExpanded ? Axis.horizontal : Axis.vertical,
                children: [
                  KCachedImg(
                    radius: 180,
                    url: employee.photo,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    showPreview: true,
                  ),
                  _space(),
                  Column(
                    crossAxisAlignment: isExpanded
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      Text(
                        employee.name,
                        style: context.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      Text(employee.email),
                      _space(),
                      Text('${employee.permissions.length} permissions'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!isExpanded)
            Positioned(
              right: -5,
              top: -5,
              child: PopupMenuButton(
                itemBuilder: (context) => [
                  if (canUpdate)
                    PopupMenuTile(
                      icon: Icons.edit_rounded,
                      child: const Text('Edit'),
                      onTap: () =>
                          context.pushTo(RoutesName.editEmployee(employee.uid)),
                    ),
                  if (canUpdate)
                    PopupMenuTile(
                      icon: Icons.copy_all_rounded,
                      child: const Text('Copy Data'),
                      onTap: () => ClipBoardAPI.copy(
                        '${employee.name}\n${employee.email}\n${employee.password}',
                      ),
                    ),
                  if (employee.isDev)
                    if (canUpdate)
                      PopupMenuTile(
                        icon: Icons.login_rounded,
                        child: const Text('Instant Login'),
                        onTap: () => employeeCtrl.instantLogin(employee),
                      ),
                  if (canUpdate)
                    PopupMenuTile(
                      icon: Icons.delete_rounded,
                      onTap: () => Future.delayed(
                        Duration.zero,
                        () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete ?'),
                            content: const Text(
                                'Are ypu sure? \nThis can not be undone!'),
                            actions: [
                              IconButton.outlined(
                                onPressed: () => context.pop,
                                icon: const Icon(Icons.close_rounded),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    employeeCtrl.deleteEmployee(employee.uid),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  SizedBox _space() => const SizedBox(
        height: 5,
        width: 20,
      );
}
