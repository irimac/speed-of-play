import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../services/history_repository.dart';
import 'components/app_header.dart';
import 'main_screen.dart';
import 'session/time_format.dart';
import 'styles/history_styles.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static const routeName = '/history';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<SessionResult>> _future;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _future = _loadHistory();
  }

  Future<List<SessionResult>> _loadHistory() {
    final repo = context.read<SessionHistoryRepository>();
    return repo.loadHistory();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final styles = HistoryStyles.defaults(Theme.of(context));
    return Scaffold(
      appBar: AppHeader(
        title: 'History',
        titleColor: styles.titleStyle.color ?? const Color(0xFF111111),
        actionColor: styles.accentColor,
        backgroundColor: styles.headerBackgroundColor,
        leadingAction: AppHeaderAction(
          label: 'Done',
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: styles.backgroundGradient),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<SessionResult>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final sessions = snapshot.data!;
                    if (sessions.isEmpty) {
                      return _HistoryEmptyState(styles: styles);
                    }
                    return ListView.separated(
                      padding: styles.listPadding,
                      itemCount: sessions.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: styles.cardSpacing),
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final selected = _selectedIds.contains(session.id);
                        return _HistoryCard(
                          styles: styles,
                          session: session,
                          selected: selected,
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                _selectedIds.add(session.id);
                              } else {
                                _selectedIds.remove(session.id);
                              }
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              if (_selectedIds.isNotEmpty)
                _HistoryActionsBar(
                  styles: styles,
                  selectedCount: _selectedIds.length,
                  onDelete: () async {
                    final repo = context.read<SessionHistoryRepository>();
                    await repo.deleteByIds(_selectedIds);
                    if (!mounted) return;
                    setState(() => _selectedIds.clear());
                    await _refresh();
                  },
                  onExport: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final repo = context.read<SessionHistoryRepository>();
                    final all = await repo.loadHistory();
                    final sessions =
                        all.where((s) => _selectedIds.contains(s.id)).toList();
                    if (sessions.isEmpty) return;
                    final file = await repo.exportCsv(sessions);
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text('CSV saved to ${file.path}')),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState({required this.styles});

  final HistoryStyles styles;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: styles.emptyStatePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No sessions yet.',
              style: styles.emptyStateTitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Run a session to capture your first summary.',
              style: styles.emptyStateSubtitleStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: styles.sectionSpacing),
            SizedBox(
              height: styles.actionButtonHeight,
              child: OutlinedButton(
                style: styles.secondaryButtonStyle,
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    MainScreen.routeName,
                    (route) => false,
                  );
                },
                child: const Text('Back to Main'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.styles,
    required this.session,
    required this.selected,
    required this.onSelected,
  });

  final HistoryStyles styles;
  final SessionResult session;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.resolveWithContrast(
      session.presetSnapshot.paletteId,
      highContrast: session.presetSnapshot.highContrastPalette,
    );
    final subtitle =
        'Rounds: ${session.roundsCompleted}/${session.presetSnapshot.rounds} | '
        'Total: ${formatSessionSeconds(session.totalElapsedSec)} | '
        'Palette: ${palette.label}';
    return Container(
      padding: styles.cardPadding,
      constraints: BoxConstraints(minHeight: styles.cardMinHeight),
      decoration: BoxDecoration(
        color: selected ? styles.cardSelectedColor : styles.cardColor,
        borderRadius: BorderRadius.circular(styles.cardRadius),
        border: Border.all(
          color: selected ? styles.cardSelectedBorder : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: styles.cardShadows,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: styles.checkboxSize,
            height: styles.checkboxSize,
            child: Checkbox(
              value: selected,
              onChanged: (value) => onSelected(value ?? false),
              materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatSessionDateTime(session.completedAt),
                  style: styles.primaryTextStyle,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: styles.secondaryTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryActionsBar extends StatelessWidget {
  const _HistoryActionsBar({
    required this.styles,
    required this.selectedCount,
    required this.onDelete,
    required this.onExport,
  });

  final HistoryStyles styles;
  final int selectedCount;
  final VoidCallback onDelete;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: styles.actionBarPadding,
      decoration: BoxDecoration(
        color: styles.actionBarColor,
        boxShadow: styles.actionBarShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$selectedCount selected',
            style: styles.selectionCountStyle,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: styles.actionButtonHeight,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Selected'),
                    style: styles.secondaryButtonStyle,
                    onPressed: onDelete,
                  ),
                ),
              ),
              SizedBox(width: styles.actionButtonSpacing),
              Expanded(
                child: SizedBox(
                  height: styles.actionButtonHeight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.ios_share),
                    label: const Text('Export CSV'),
                    style: styles.primaryButtonStyle,
                    onPressed: onExport,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatSessionDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final date =
      '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  final time =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  return '$date $time';
}
