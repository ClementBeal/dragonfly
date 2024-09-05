import 'package:dragonfly/src/screens/settings/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralSettings extends StatelessWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          WebsiteAppearance(),
        ],
      ),
    );
  }
}

class WebsiteAppearance extends StatelessWidget {
  const WebsiteAppearance({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Choose your preferred website appearance.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            ToggleButtons(
              isSelected: [
                state.themeMode == ThemeMode.system,
                state.themeMode == ThemeMode.light,
                state.themeMode == ThemeMode.dark,
              ],
              direction: Axis.horizontal,
              borderRadius: BorderRadius.circular(8),
              selectedBorderColor: Colors.blue,
              selectedColor: Colors.white,
              fillColor: Colors.blue,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Auto'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Light'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Dark'),
                ),
              ],
              onPressed: (index) {
                switch (index) {
                  case 0:
                    context
                        .read<SettingsCubit>()
                        .setThemeMode(ThemeMode.system);
                    break;
                  case 1:
                    context.read<SettingsCubit>().setThemeMode(ThemeMode.light);
                    break;
                  case 2:
                    context.read<SettingsCubit>().setThemeMode(ThemeMode.dark);
                    break;
                }
              },
            ),
          ],
        );
      },
    );
  }
}
