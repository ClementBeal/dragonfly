import 'package:dragonfly/src/screens/settings/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchSettings extends StatelessWidget {
  const SearchSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
        const Text(
          'Search Engine',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose your preferred search engine.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return DropdownButton<String>(
              value: state.searchEngine,
              items: const [
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
