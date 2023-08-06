import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/version_manager/ctrl/app_version_ctrl.dart';
import 'package:merchant_m3/widget/widget.dart';

class AppVersionView extends ConsumerWidget {
  const AppVersionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersionCtrl = ref.read(appVersionProvider.notifier);
    final version = ref.watch(appVersionProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Version Control'),
        actions: [
          IconButton.outlined(
            onPressed: () => appVersionCtrl.reload(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ).adapt(context),
          if (kIsWeb) const SizedBox(width: 10),
          IconButton.filledTonal(
            onPressed: () => appVersionCtrl.submitVersion(context),
            icon: const Icon(Icons.done_rounded),
            tooltip: 'Submit ',
          ).adapt(context),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InformativeCard(
                header: 'Version',
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: appVersionCtrl.clientVersionCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Client App Version'),
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () =>
                                appVersionCtrl.incrementVersion(true, true),
                            icon: const Icon(
                              Icons.keyboard_arrow_up_rounded,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                appVersionCtrl.incrementVersion(false, true),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: appVersionCtrl.merchantVersionCtrl,
                          decoration: InputDecoration(
                            labelText: 'Merchant App Version',
                            helperText:
                                'Current Version : ${version.currentVersion}',
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () =>
                                appVersionCtrl.incrementVersion(true, false),
                            icon: const Icon(
                              Icons.keyboard_arrow_up_rounded,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                appVersionCtrl.incrementVersion(false, false),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              InformativeCard(
                header: 'App Link',
                actions: [
                  FilledButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const FileSelectionDialog(),
                    ),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Select File'),
                  ),
                ],
                children: [
                  TextField(
                    controller: appVersionCtrl.merchantLinkCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Merchant App Link'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FileSelectionDialog extends ConsumerWidget {
  const FileSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersionCtrl = ref.read(appVersionProvider.notifier);
    final selectedFile = ref.watch(merchantAPKFileProvider);
    return AlertDialog(
      title: const Text('Select Apk'),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(100, 100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => appVersionCtrl.selectApkFile(),
            icon: const Icon(Icons.android_rounded),
            label: const Text('Select'),
          ),
          const SizedBox(width: 10),
          if (selectedFile != null)
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(selectedFile.name),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        'Size : ${selectedFile.size.readableFileSize()}',
                      ),
                    ),
                  ),
                  if (!kIsWeb)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(selectedFile.path ?? 'N/A'),
                      ),
                    ),
                ],
              ),
            )
        ],
      ),
      actions: [
        IconButton.outlined(
          onPressed: () => context.pop,
          icon: const Icon(
            Icons.close_rounded,
          ),
        ),
        IconButton.outlined(
          onPressed: () => appVersionCtrl.setFile(null),
          icon: const Icon(
            Icons.refresh_rounded,
          ),
        ),
        FilledButton(
          onPressed: () => appVersionCtrl.uploadSelectedFile(context),
          child: const Text(
            'Upload Apk',
          ),
        ),
      ],
    );
  }
}
