import 'package:dragonfly/main.dart';
import 'package:dragonfly/src/screens/scaffold/widgets/favicon_icon.dart';
import 'package:dragonfly/utils/extensions/list.dart';
import 'package:dragonfly_browservault/dragonfly_browservault.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showHistoryScreen(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const HistoryScreen(),
  );
}

enum HistorySort {
  today,
  yesterday,
  lastSevenDays,
  thisMonth,
  month1,
  month2,
  month3,
  month4,
  month5,
  before,
  all,
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final List<Link> history;
  HistorySort sort = HistorySort.today;

  @override
  void initState() {
    super.initState();

    history = navigationHistory.getAllLinks();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 1200,
        height: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: 40,
                child: TimePeriodList(
                  sort: sort,
                  onSortChanged: (newSort) => setState(() => sort = newSort),
                )),
            Expanded(
              child: Builder(builder: (context) {
                final today = DateTime.now();

                final List<Link> sortedHistory = switch (sort) {
                  HistorySort.today => history.where((link) => link.timestamp
                      .isAfter(
                          DateTime.now().subtract(const Duration(days: 1)))),
                  HistorySort.yesterday => history.where((link) =>
                      link.timestamp.year == today.year &&
                      link.timestamp.month == today.month &&
                      link.timestamp.day == today.day - 1),
                  HistorySort.lastSevenDays => history.where(
                      (link) =>
                          link.timestamp.isBefore(
                            DateTime(today.year, today.month, today.day - 1),
                          ) &&
                          link.timestamp
                              .isAfter(today.subtract(const Duration(days: 7))),
                    ),
                  HistorySort.thisMonth => history.where(
                      (link) =>
                          link.timestamp.isAfter(
                            DateTime(today.year, today.month),
                          ) &&
                          link.timestamp.isBefore(
                              today.subtract(const Duration(days: 7))),
                    ),
                  HistorySort.month1 => history.where((link) =>
                      link.timestamp.year == today.year &&
                      link.timestamp.month == today.month - 1),
                  HistorySort.month2 => history.where((link) =>
                      link.timestamp.year == today.year &&
                      link.timestamp.month == today.month - 2),
                  HistorySort.month3 => history.where((link) =>
                      link.timestamp.year == today.year &&
                      link.timestamp.month == today.month - 3),
                  HistorySort.month4 => history.where((link) =>
                      link.timestamp.year == today.year &&
                      link.timestamp.month == today.month - 4),
                  HistorySort.month5 => history.where((link) =>
                      link.timestamp.year == today.year &&
                      link.timestamp.month == today.month - 5),
                  HistorySort.before =>
                    history.where((link) => link.timestamp.isBefore(
                          today.subtract(
                            const Duration(
                              days: 30 * 6,
                            ),
                          ),
                        )),
                  HistorySort.all => history,
                }
                    .toList()
                  ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: sortedHistory.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      title: Text(sortedHistory[i].title),
                      subtitle: Text(sortedHistory[i].link.toString()),
                      trailing: IconButton(
                        icon: Text(
                            DateFormat().format(sortedHistory[i].timestamp)),
                        onPressed: () {},
                      ),
                      onTap: () {},
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class TimePeriodList extends StatelessWidget {
  const TimePeriodList(
      {super.key, required this.sort, required this.onSortChanged});

  final HistorySort sort;
  final void Function(HistorySort newSort) onSortChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        ChoiceChip(
          label: const Text('Today'),
          selected: sort == HistorySort.today,
          onSelected: (value) {
            onSortChanged(HistorySort.today);
          },
        ),
        ChoiceChip(
          label: const Text('Yesterday'),
          selected: sort == HistorySort.yesterday,
          onSelected: (value) {
            onSortChanged(HistorySort.yesterday);
          },
        ),
        ChoiceChip(
          label: const Text('Last 7 Days'),
          selected: sort == HistorySort.lastSevenDays,
          onSelected: (value) {
            onSortChanged(HistorySort.lastSevenDays);
          },
        ),
        ChoiceChip(
          label: const Text('This Month'),
          selected: sort == HistorySort.thisMonth,
          onSelected: (value) {
            onSortChanged(HistorySort.thisMonth);
          },
        ),
        //
        ChoiceChip(
          label: Text(_getPreviousMonth(1)),
          selected: sort == HistorySort.month1,
          onSelected: (value) {
            onSortChanged(HistorySort.month1);
          },
        ),
        ChoiceChip(
          label: Text(_getPreviousMonth(2)),
          selected: sort == HistorySort.month2,
          onSelected: (value) {
            onSortChanged(HistorySort.month2);
          },
        ),
        ChoiceChip(
          label: Text(_getPreviousMonth(3)),
          selected: sort == HistorySort.month3,
          onSelected: (value) {
            onSortChanged(HistorySort.month3);
          },
        ),
        ChoiceChip(
          label: Text(_getPreviousMonth(4)),
          selected: sort == HistorySort.month4,
          onSelected: (value) {
            onSortChanged(HistorySort.month4);
          },
        ),
        ChoiceChip(
          label: Text(_getPreviousMonth(5)),
          selected: sort == HistorySort.month5,
          onSelected: (value) {
            onSortChanged(HistorySort.month5);
          },
        ),
        //
        ChoiceChip(
          label: const Text('Older than 6 Months'),
          selected: sort == HistorySort.before,
          onSelected: (value) {
            onSortChanged(HistorySort.before);
          },
        ),
      ]
          .cast<Widget>()
          .intersperseInner(() => const SizedBox(
                width: 8,
              ))
          .toList(),
    );
  }

  String _getPreviousMonth(int monthDiff) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final beforeDateTime =
        DateTime(currentMonth.year, currentMonth.month - monthDiff);

    return DateFormat.MMMM().format(beforeDateTime);
  }
}
