import 'package:dragonfly/src/screens/settings/cubit/settings_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralSettings extends StatelessWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          WebsiteAppearance(),
          MainColorSelector(),
          Divider(),
          DownloadLocationSelector(),
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
            const Text(
              'Appearance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose your preferred website appearance.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ToggleButtons(
              isSelected: [
                state.themeMode == ThemeMode.system,
                state.themeMode == ThemeMode.light,
                state.themeMode == ThemeMode.dark,
              ],
              direction: Axis.horizontal,
              borderRadius: BorderRadius.circular(8),
              // selectedBorderColor: Colors.blue,
              // selectedColor: Colors.white,
              // fillColor: Colors.blue,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Auto'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Light'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
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

class DownloadLocationSelector extends StatefulWidget {
  const DownloadLocationSelector({super.key});

  @override
  State<DownloadLocationSelector> createState() =>
      _DownloadLocationSelectorState();
}

class _DownloadLocationSelectorState extends State<DownloadLocationSelector> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(
      text: context.read<SettingsCubit>().state.downloadLocation,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Download folder',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose where will be stored the downloaded files',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: BlocListener<SettingsCubit, SettingsState>(
                listener: (context, state) =>
                    controller.text = state.downloadLocation,
                listenWhen: (previous, current) =>
                    previous.downloadLocation != current.downloadLocation,
                child: TextField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Download Location',
                    border: OutlineInputBorder(),
                  ),
                  controller: controller,
                ),
              ),
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: () async {
                final newDownloadPath = await FilePicker.platform
                    .getDirectoryPath(
                        initialDirectory: context
                            .read<SettingsCubit>()
                            .state
                            .downloadLocation);

                if (newDownloadPath != null) {
                  context
                      .read<SettingsCubit>()
                      .setDownloadLocation(newDownloadPath);
                }
              },
              child: const Text('Browse'),
            ),
          ],
        ),
      ],
    );
  }
}

class MainColorSelector extends StatelessWidget {
  const MainColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Main Color',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose the primary color for the app theme.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Colors.accents
                  .map(
                    (e) => GestureDetector(
                      onTap: () {
                        context.read<SettingsCubit>().setMainColor(e);
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: HSLColor.fromColor(e)
                                .withLightness(0.5)
                                .toColor(),
                          ),
                          color: e,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}
