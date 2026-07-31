import 'package:flutter/material.dart';

/// User preferences that apply across the app.
class AppSettings extends ChangeNotifier {
  AppSettings({this.wireframeAnimationsEnabled = true});

  bool wireframeAnimationsEnabled;

  void setWireframeAnimationsEnabled(bool enabled) {
    if (wireframeAnimationsEnabled == enabled) return;
    wireframeAnimationsEnabled = enabled;
    notifyListeners();
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettings> {
  const AppSettingsScope({
    super.key,
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);

  static AppSettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope not found in widget tree');
    return scope!.notifier!;
  }
}

void showAppSettingsDialog(BuildContext context) {
  final settings = AppSettingsScope.of(context);

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          return AlertDialog(
            title: const Text('Settings'),
            content: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Wireframe animations'),
              subtitle: const Text(
                'Off shows a still pose for each exercise instead of an animated rep.',
              ),
              value: settings.wireframeAnimationsEnabled,
              onChanged: settings.setWireframeAnimationsEnabled,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Done'),
              ),
            ],
          );
        },
      );
    },
  );
}
