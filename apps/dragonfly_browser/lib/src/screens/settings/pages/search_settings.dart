import 'package:dragonfly/src/screens/settings/cubit/settings_cubit.dart';
import 'package:dragonfly/src/screens/settings/pages/general_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchSettings extends StatelessWidget {
  const SearchSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          SearchEngineSelector(),
        ],
      ),
    );
  }
}

class SearchEngineSelector extends StatelessWidget {
  const SearchEngineSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Search Engine',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Choose your preferred search engine.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 16),
        BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return DropdownButton<String>(
              value: state.searchEngine,
              items: [
                DropdownMenuItem(value: 'google', child: Text('Google')),
                DropdownMenuItem(value: 'bing', child: Text('Bing')),
                DropdownMenuItem(
                    value: 'duckduckgo', child: Text('DuckDuckGo')),
                DropdownMenuItem(value: 'wikipedia', child: Text('Wikipedia')),
                // Add more search engines as needed
              ],
              onChanged: (value) {
                context.read<SettingsCubit>().setSearchEngine(value!);
              },
            );
          },
        ),
      ],
    );
  }
}
