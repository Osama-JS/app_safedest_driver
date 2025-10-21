import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../services/wallet_service.dart';
import '../models/wallet.dart';
import 'package:fl_chart/fl_chart.dart';

class EarningsChartCard extends StatefulWidget {
  const EarningsChartCard({super.key});

  @override
  State<EarningsChartCard> createState() => _EarningsChartCardState();
}

class _EarningsChartCardState extends State<EarningsChartCard> {
  EarningsPeriod _selectedPeriod = EarningsPeriod.month;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEarningsData();
  }

  Future<void> _loadEarningsData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final walletService = Provider.of<WalletService>(context, listen: false);
    await walletService.getEarningsStats(period: _selectedPeriod);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<WalletService>(
      builder: (context, walletService, child) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.earningsStatistics,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Period Selector
              _buildPeriodSelector(context),

              const SizedBox(height: 20),

              // Chart or Loading
              _isLoading
                  ? _buildLoadingChart(context)
                  : _buildEarningsChart(context, walletService),

              const SizedBox(height: 20),

              // Quick Stats
              _buildQuickStats(context, walletService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        _buildPeriodChip(
            context, l10n.today, _selectedPeriod == EarningsPeriod.today),
        const SizedBox(width: 8),
        _buildPeriodChip(
            context, l10n.week, _selectedPeriod == EarningsPeriod.week),
        const SizedBox(width: 8),
        _buildPeriodChip(
            context, l10n.month, _selectedPeriod == EarningsPeriod.month),
        const SizedBox(width: 8),
        _buildPeriodChip(
            context, l10n.year, _selectedPeriod == EarningsPeriod.year),
      ],
    );
  }

  Widget _buildPeriodChip(BuildContext context, String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          EarningsPeriod newPeriod;
          final l10n = AppLocalizations.of(context);

          if (label == l10n.today) {
            newPeriod = EarningsPeriod.today;
          } else if (label == l10n.week) {
            newPeriod = EarningsPeriod.week;
          } else if (label == l10n.month) {
            newPeriod = EarningsPeriod.month;
          } else {
            newPeriod = EarningsPeriod.year;
          }

          setState(() {
            _selectedPeriod = newPeriod;
          });

          _loadEarningsData();
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Colors.grey,
      ),
    );
  }

  Widget _buildLoadingChart(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEarningsChart(
      BuildContext context, WalletService walletService) {
    final earningsStats = walletService.earningsStats;

    if (earningsStats == null ||
        earningsStats.stats.dailyEarnings.isEmpty ||
        earningsStats.stats.totalEarnings == 0.0) {
      return _buildEmptyChart(context);
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          _buildLineChartData(context, earningsStats.stats.dailyEarnings),
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback or error handling
      return const SizedBox.shrink();
    }
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noEarningsData,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ في قبول المهام لرؤية إحصائيات أرباحك',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildLineChartData(
      BuildContext context, List<DailyEarning> dailyEarnings) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Create spots for the line chart
    final spots = dailyEarnings.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.amount);
    }).toList();

    // Find min and max values for better scaling
    final amounts = dailyEarnings.map((e) => e.amount).toList();
    final minY =
        amounts.isEmpty ? 0.0 : amounts.reduce((a, b) => a < b ? a : b);
    final maxY =
        amounts.isEmpty ? 100.0 : amounts.reduce((a, b) => a > b ? a : b);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: dailyEarnings.length > 7
                ? (dailyEarnings.length / 7).ceil().toDouble()
                : 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < dailyEarnings.length) {
                final earning = dailyEarnings[index];
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _selectedPeriod == EarningsPeriod.today
                        ? '${earning.date.hour}:00'
                        : earning.dayNumber,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: (maxY - minY) / 4,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  '${value.toInt()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (dailyEarnings.length - 1).toDouble(),
      minY: minY * 0.9, // Add some padding
      maxY: maxY * 1.1, // Add some padding
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: primaryColor,
                strokeWidth: 2,
                strokeColor: Theme.of(context).colorScheme.surface,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: primaryColor.withValues(alpha: 0.1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              if (index >= 0 && index < dailyEarnings.length) {
                final earning = dailyEarnings[index];
                return LineTooltipItem(
                  '${earning.amount.toStringAsFixed(2)} ر.س\n${earning.shortDayName}',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, WalletService walletService) {
    final earningsStats = walletService.earningsStats;
    final l10n = AppLocalizations.of(context);

    if (earningsStats == null || earningsStats.stats.totalEarnings == 0.0) {
      return _buildEmptyStats(context);
    }

    final stats = earningsStats.stats;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            l10n.highestEarning,
            '${stats.highestDayEarning.toStringAsFixed(2)} ر.س',
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            l10n.averagePerTask,
            '${stats.averageEarningPerTask.toStringAsFixed(2)} ر.س',
            Icons.task_alt,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            l10n.totalEarnings,
            '${stats.totalEarnings.toStringAsFixed(2)} ر.س',
            Icons.account_balance_wallet,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'لا توجد أرباح في هذه الفترة',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
