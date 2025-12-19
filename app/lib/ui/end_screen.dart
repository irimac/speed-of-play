import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../services/history_repository.dart';
import 'history_screen.dart';
import 'main_screen.dart';
import 'session/time_format.dart';
import 'styles/summary_styles.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key, required this.result});

  static const routeName = '/end';

  final SessionResult? result;

  @override
  Widget build(BuildContext context) {
    final styles = SummaryStyles.defaults(Theme.of(context));
    final resolvedResult = result;
    final palette = resolvedResult == null
        ? null
        : Palette.resolveWithContrast(
            resolvedResult.presetSnapshot.paletteId,
            highContrast: resolvedResult.presetSnapshot.highContrastPalette,
          );
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: styles.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: styles.screenPadding,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: styles.contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SummaryHeader(
                      styles: styles,
                      completedAt: resolvedResult?.completedAt,
                    ),
                    SizedBox(height: styles.sectionSpacing),
                    if (resolvedResult != null) ...[
                      _SummaryStatsGrid(
                        styles: styles,
                        stats: _buildSummaryStats(resolvedResult),
                      ),
                      SizedBox(height: styles.sectionSpacing),
                      _SummaryDetailsCard(
                        styles: styles,
                        title: 'Details',
                        rows: [
                          _DetailRowData(
                            label: 'Palette',
                            value: palette?.label ?? 'Unknown',
                          ),
                          _DetailRowData(
                            label: 'Numbers',
                            value:
                                '${resolvedResult.presetSnapshot.numberMin} - ${resolvedResult.presetSnapshot.numberMax}',
                          ),
                          _DetailRowData(
                            label: 'Active Colors',
                            value: _formatActiveColors(
                              resolvedResult.presetSnapshot.activeColorIds,
                              palette?.colors.length ?? 0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: styles.sectionSpacing),
                      _SummaryDetailsCard(
                        styles: styles,
                        title: 'Round Durations',
                        rows: [
                          for (int i = 0;
                              i < resolvedResult.perRoundDurationsSec.length;
                              i++)
                            _DetailRowData(
                              label: 'Round ${i + 1}',
                              value: formatSessionSeconds(
                                resolvedResult.perRoundDurationsSec[i],
                              ),
                            ),
                        ],
                      ),
                    ] else
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: styles.sectionSpacing,
                        ),
                        child: Text(
                          'No data captured.',
                          style: styles.emptyStateStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: styles.sectionSpacing),
                    SizedBox(
                      height: styles.actionButtonHeight,
                      child: ElevatedButton(
                        style: styles.primaryButtonStyle,
                        onPressed: resolvedResult == null
                            ? null
                            : () async {
                                final repo =
                                    context.read<SessionHistoryRepository>();
                                await repo.saveResult(resolvedResult);
                                if (context.mounted) {
                                  Navigator.of(context).pushReplacementNamed(
                                    HistoryScreen.routeName,
                                  );
                                }
                              },
                        child: const Text('Save to History'),
                      ),
                    ),
                    SizedBox(height: styles.buttonSpacing),
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
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.styles,
    required this.completedAt,
  });

  final SummaryStyles styles;
  final DateTime? completedAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Session Summary', style: styles.titleStyle),
        if (completedAt != null) ...[
          const SizedBox(height: 6),
          Text(
            'Completed ${_formatCompletedAt(completedAt!)}',
            style: styles.subtitleStyle,
          ),
        ],
      ],
    );
  }
}

class _SummaryStatsGrid extends StatelessWidget {
  const _SummaryStatsGrid({required this.styles, required this.stats});

  final SummaryStyles styles;
  final List<_SummaryStat> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final useTwoColumns = maxWidth >= styles.gridBreakPoint;
        final spacing = styles.cardSpacing;
        final cardWidth = useTwoColumns ? (maxWidth - spacing) / 2 : maxWidth;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: stats
              .map(
                (stat) => SizedBox(
                  width: cardWidth,
                  child: _StatCard(styles: styles, stat: stat),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.styles, required this.stat});

  final SummaryStyles styles;
  final _SummaryStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: styles.cardPadding,
      constraints: BoxConstraints(minHeight: styles.statCardMinHeight),
      decoration: BoxDecoration(
        color: styles.cardColor,
        borderRadius: BorderRadius.circular(styles.cardRadius),
        boxShadow: styles.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stat.label, style: styles.statLabelStyle),
          const SizedBox(height: 6),
          Text(stat.value, style: styles.statValueStyle),
          if (stat.caption != null) ...[
            const SizedBox(height: 4),
            Text(stat.caption!, style: styles.statCaptionStyle),
          ],
        ],
      ),
    );
  }
}

class _SummaryDetailsCard extends StatelessWidget {
  const _SummaryDetailsCard({
    required this.styles,
    required this.title,
    required this.rows,
  });

  final SummaryStyles styles;
  final String title;
  final List<_DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: styles.cardPadding,
      decoration: BoxDecoration(
        color: styles.detailCardColor,
        borderRadius: BorderRadius.circular(styles.cardRadius),
        boxShadow: styles.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: styles.sectionTitleStyle),
          const SizedBox(height: 12),
          for (int i = 0; i < rows.length; i++) ...[
            _DetailRow(styles: styles, data: rows[i]),
            if (i != rows.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: styles.dividerColor, height: 1),
              ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.styles, required this.data});

  final SummaryStyles styles;
  final _DetailRowData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(data.label, style: styles.detailLabelStyle),
        ),
        const SizedBox(width: 12),
        Text(data.value, style: styles.detailValueStyle),
      ],
    );
  }
}

class _SummaryStat {
  const _SummaryStat({
    required this.label,
    required this.value,
    this.caption,
  });

  final String label;
  final String value;
  final String? caption;
}

class _DetailRowData {
  const _DetailRowData({required this.label, required this.value});

  final String label;
  final String value;
}

List<_SummaryStat> _buildSummaryStats(SessionResult result) {
  final preset = result.presetSnapshot;
  return [
    _SummaryStat(
      label: 'Rounds Completed',
      value: '${result.roundsCompleted}',
      caption: 'Target ${preset.rounds}',
    ),
    _SummaryStat(
      label: 'Total Time',
      value: formatSessionSeconds(result.totalElapsedSec),
    ),
    _SummaryStat(
      label: 'Round Duration',
      value: formatSessionSeconds(preset.roundDurationSec),
    ),
    _SummaryStat(
      label: 'Rest Duration',
      value: formatSessionSeconds(preset.restDurationSec),
    ),
  ];
}

String _formatCompletedAt(DateTime dateTime) {
  final date =
      '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  final time =
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  return '$date $time';
}

String _formatActiveColors(List<String>? activeIds, int paletteCount) {
  if (paletteCount <= 0) return '0';
  if (activeIds == null || activeIds.isEmpty) {
    return 'All ($paletteCount)';
  }
  return '${activeIds.length}';
}
