import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/employee/ctrl/employee_ctrl.dart';
import 'package:merchant_m3/feature/employee/provider/employee_provider.dart';
import 'package:merchant_m3/models/models.dart';
import 'package:merchant_m3/widget/widget.dart';

class AddEditEmployeeView extends ConsumerWidget {
  const AddEditEmployeeView(this.uid, {super.key});
  final String? uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdate = uid != null;
    final employee = ref.watch(employeeCtrlProvider(uid));
    final employeeCtrl = ref.read(employeeCtrlProvider(uid).notifier);
    final imgFile = ref.watch(employeeImageStateProvider);
    final currentEmployee = ref.watch(permissionProvider);
    final canManagePermission =
        EPermissions.permissionManage.canDo(currentEmployee);

    return Scaffold(
      appBar: AppBar(
        title: isUpdate
            ? const Text('Update Employee')
            : const Text('Add Employee'),
        actions: [
          IconButton.filledTonal(
            onPressed: () =>
                employeeCtrl.createUpdateEmployee(context, isUpdate),
            icon: const Icon(Icons.done_rounded),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: AdaptiveBody(
            child: Column(
              children: [
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (imgFile == null && employee.photo.isEmpty)
                        const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person_4_rounded, size: 30),
                        ),
                      if (employee.photo.isNotEmpty)
                        KCachedImg(
                          url: employee.photo,
                          height: 100,
                          width: 100,
                          radius: 180,
                          showPreview: true,
                        ),
                      if (imgFile != null)
                        KImage(
                          imgFile,
                          height: 100,
                          width: 100,
                          radius: 180,
                          showPreview: true,
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton.filledTonal(
                          onPressed: () => employeeCtrl.selectImage(),
                          icon: const Icon(
                            Icons.add_photo_alternate_rounded,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                InformativeCard(
                  header: 'Employee Info',
                  children: [
                    TextField(
                      controller: employeeCtrl.nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Employee Name',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      enabled: !isUpdate,
                      controller: employeeCtrl.emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        helperText:
                            isUpdate ? 'Email can not be changed' : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      enabled: !isUpdate,
                      controller: employeeCtrl.passCtrl,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        helperText:
                            isUpdate ? 'Password can not be changed' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                InformativeCard(
                  header: 'Permissions',
                  actions: [
                    Switch(
                      value: employeeCtrl.doseContainsEvery,
                      onChanged: canManagePermission
                          ? (value) => employeeCtrl.addAllPermission()
                          : null,
                    ),
                  ],
                  children: [
                    if (!canManagePermission)
                      Text(
                        'You do not have Permission to edit Employee Permission',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorTheme.error,
                        ),
                      ),
                    ...EPermissions.values.map(
                      (e) => SwitchListTile(
                        value: employee.permissions.contains(e),
                        onChanged: canManagePermission
                            ? (value) => employeeCtrl.setPermission(e)
                            : null,
                        title: Text(e.title),
                        subtitle: Text(e.subtitle),
                        secondary: Icon(e.icon),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
