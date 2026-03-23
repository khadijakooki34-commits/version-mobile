import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:fl_chart/fl_chart.dart';

import '../../providers/index.dart';

import '../../widgets/index.dart';

import '../../utils/index.dart';



class AdminStatisticsScreen extends StatefulWidget {

  const AdminStatisticsScreen({super.key});



  @override

  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();

}



class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {

  @override

  void initState() {

    super.initState();

    _loadStatistics();

  }



  Future<void> _loadStatistics() async {

    context.read<AdminProvider>().fetchStatistics();

  }



  static int? _toInt(dynamic v) {

    if (v == null) return null;

    if (v is int) return v;

    if (v is num) return v.toInt();

    return null;

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text('Statistiques'),

        elevation: 0,

        scrolledUnderElevation: 1,

        actions: [

          IconButton(

            icon: const Icon(Icons.dashboard),

            tooltip: 'Tableau de bord',

            onPressed: () {

              Navigator.of(context).pushReplacementNamed('/admin-dashboard');

            },

          ),

        ],

      ),

      body: Consumer<AdminProvider>(

        builder: (context, provider, _) {

          if (provider.isLoading || provider.statistics == null) {

            return const LoadingWidget();

          }



          if (provider.error != null) {

            return AppErrorWidget(

              error: provider.error,

              onRetry: _loadStatistics,

            );

          }



          final stats = provider.statistics!;

          final adminCount = _toInt(stats.usersByRole['ADMIN']) ?? 0;

          final userCount = _toInt(stats.usersByRole['USER']) ?? 0;



          return SingleChildScrollView(

            padding: const EdgeInsets.all(AppTheme.spacingL),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  'Statistiques de la plateforme',

                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(

                    fontWeight: FontWeight.w700,

                    letterSpacing: -0.25,

                  ),

                ),

                const SizedBox(height: AppTheme.spacingL),

                _buildStatCard(

                  context,

                  'Total des utilisateurs',

                  stats.totalUsers.toString(),

                  'Actifs : ${stats.activeUsers} / Bloqués : ${stats.blockedUsers}',

                ),

                _buildStatCard(

                  context,

                  'Total des destinations',

                  stats.totalDestinations.toString(),

                  'Disponibles pour réservation',

                ),

                _buildStatCard(

                  context,

                  'Total des avis',

                  stats.totalReviews.toString(),

                  'Note moyenne : ${stats.averageRating.toStringAsFixed(2)}/5',

                ),

                _buildStatCard(

                  context,

                  'Total des événements',

                  stats.totalEvents.toString(),

                  'Événements culturels',

                ),

                const SizedBox(height: AppTheme.spacingL),

                // Quick view cards for Admin vs Users

                Row(

                  children: [

                    Expanded(

                      child: _buildRoleCountCard(

                        context,

                        label: 'Administrateurs',

                        value: adminCount,

                        color: AppTheme.errorColor,

                      ),

                    ),

                    const SizedBox(width: AppTheme.spacingM),

                    Expanded(

                      child: _buildRoleCountCard(

                        context,

                        label: 'Utilisateurs',

                        value: userCount,

                        color: AppTheme.successColor,

                      ),

                    ),

                  ],

                ),

                Text(

                  'Destinations par catégorie',

                  style: Theme.of(context).textTheme.titleLarge?.copyWith(

                    fontWeight: FontWeight.w600,

                  ),

                ),

                const SizedBox(height: AppTheme.spacingM),

                _buildDestinationsBarChart(context, stats),

                const SizedBox(height: AppTheme.spacingL),

                const SizedBox(height: AppTheme.spacingL),

                Text(

                  'Utilisateurs par rôle',

                  style: Theme.of(context).textTheme.titleLarge?.copyWith(

                    fontWeight: FontWeight.w600,

                  ),

                ),

                const SizedBox(height: AppTheme.spacingL),

                _buildUsersByRolePieChart(context, stats),

                const SizedBox(height: AppTheme.spacingL),

                Text(

                  'Last Updated: ${DateFormatUtil.formatDateTime(stats.generatedAt)}',

                  style: Theme.of(context).textTheme.bodySmall,

                ),

              ],

            ),

          );

        },

      ),

    );

  }



  Widget _buildStatCard(

    BuildContext context,

    String title,

    String value,

    String subtitle,

  ) {

    return Container(

      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(AppTheme.radiusL),

        border: Border.all(color: AppTheme.borderColor, width: 1),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.06),

            blurRadius: 12,

            offset: const Offset(0, 4),

          ),

        ],

      ),

      child: Padding(

        padding: const EdgeInsets.all(AppTheme.spacingL),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              title,

              style: Theme.of(context).textTheme.titleMedium?.copyWith(

                color: AppTheme.textLightColor,

                fontWeight: FontWeight.w600,

              ),

            ),

            const SizedBox(height: AppTheme.spacingM),

            Text(

              value,

              style: Theme.of(context).textTheme.headlineMedium?.copyWith(

                color: AppTheme.primaryColor,

                fontWeight: FontWeight.w700,

                letterSpacing: -0.5,

              ),

            ),

            const SizedBox(height: AppTheme.spacingS),

            Text(

              subtitle,

              style: Theme.of(context).textTheme.bodySmall?.copyWith(

                color: AppTheme.textHintColor,

              ),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildRoleCountCard(

    BuildContext context, {

    required String label,

    required int value,

    required Color color,

  }) {

    return Container(

      padding: const EdgeInsets.all(AppTheme.spacingM),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(AppTheme.radiusL),

        border: Border.all(color: AppTheme.borderColor),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            label,

            style: Theme.of(context).textTheme.bodySmall?.copyWith(

                  color: AppTheme.textLightColor,

                  fontWeight: FontWeight.w600,

                ),

          ),

          const SizedBox(height: AppTheme.spacingS),

          Text(

            value.toString(),

            style: Theme.of(context).textTheme.headlineSmall?.copyWith(

                  color: color,

                  fontWeight: FontWeight.w700,

                ),

          ),

        ],

      ),

    );

  }



  Widget _buildDestinationsBarChart(BuildContext context, dynamic stats) {

    final categories = stats.destinationsByCategory.entries.toList();

    if (categories.isEmpty) {

      return Text(

        'No destination data yet.',

        style: Theme.of(context).textTheme.bodySmall,

      );

    }



    int maxVal = 0;

    for (final e in categories) {

      final v = e.value is int ? e.value as int : (e.value as num).toInt();

      if (v > maxVal) maxVal = v;

    }

    final maxY = (maxVal * 1.2).clamp(1.0, double.infinity);



    return Container(

      height: 220,

      padding: const EdgeInsets.all(AppTheme.spacingM),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(AppTheme.radiusL),

        border: Border.all(color: AppTheme.borderColor),

      ),

      child: BarChart(

        BarChartData(

          borderData: FlBorderData(show: false),

          gridData: const FlGridData(show: true, drawVerticalLine: false),

          titlesData: FlTitlesData(

            leftTitles: AxisTitles(

              sideTitles: SideTitles(

                showTitles: true,

                reservedSize: 28,

                getTitlesWidget: (value, meta) => Text(

                  value.toInt().toString(),

                  style: Theme.of(context).textTheme.bodySmall,

                ),

              ),

            ),

            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

            bottomTitles: AxisTitles(

              sideTitles: SideTitles(

                showTitles: true,

                getTitlesWidget: (value, meta) {

                  final index = value.toInt();

                  if (index < 0 || index >= categories.length) return const SizedBox.shrink();

                  return Padding(

                    padding: const EdgeInsets.only(top: 8),

                    child: Text(

                      categories[index].key,

                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),

                      overflow: TextOverflow.ellipsis,

                    ),

                  );

                },

              ),

            ),

          ),

          barGroups: List.generate(categories.length, (index) {

            final entry = categories[index];

            final value = entry.value is int ? (entry.value as int).toDouble() : (entry.value as num).toDouble();

            return BarChartGroupData(

              x: index,

              barRods: [

                BarChartRodData(

                  toY: value,

                  color: AppTheme.primaryColor,

                  borderRadius: BorderRadius.circular(6),

                  width: 18,

                ),

              ],

            );

          }),

          maxY: maxY,

        ),

      ),

    );

  }



  Widget _buildUsersByRolePieChart(BuildContext context, dynamic stats) {

    if (stats.usersByRole.isEmpty) {

      return Text(

        'No user role data yet.',

        style: Theme.of(context).textTheme.bodySmall,

      );

    }



    final entries = stats.usersByRole.entries.toList();

    final colors = <Color>[

      AppTheme.successColor,

      AppTheme.errorColor,

      AppTheme.accentColor,

      AppTheme.infoColor,

    ];



    return Container(

      margin: const EdgeInsets.only(bottom: AppTheme.spacingL),

      padding: const EdgeInsets.symmetric(

        horizontal: AppTheme.spacingL,

        vertical: AppTheme.spacingM,

      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(AppTheme.radiusL),

        border: Border.all(color: AppTheme.borderColor),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.06),

            blurRadius: 12,

            offset: const Offset(0, 4),

          ),

        ],

      ),

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          SizedBox(

            height: 220,

            child: PieChart(

              PieChartData(

                sectionsSpace: 3,

                centerSpaceRadius: 55,

                sections: List.generate(entries.length, (index) {

                  final entry = entries[index];

                  final color = colors[index % colors.length];

                  final count = entry.value is int ? entry.value as int : (entry.value as num).toInt();

                  return PieChartSectionData(

                    color: color,

                    value: count.toDouble(),

                    title: count.toString(),

                    radius: 72,

                    titleStyle: const TextStyle(

                      color: Colors.white,

                      fontWeight: FontWeight.bold,

                      fontSize: 13,

                    ),

                  );

                }),

              ),

            ),

          ),

          const SizedBox(height: AppTheme.spacingS),

          Wrap(

            spacing: AppTheme.spacingL,

            runSpacing: AppTheme.spacingS,

            alignment: WrapAlignment.center,

            children: List.generate(entries.length, (index) {

              final entry = entries[index];

              final color = colors[index % colors.length];

              return Row(

                mainAxisSize: MainAxisSize.min,

                children: [

                  Container(

                    width: 12,

                    height: 12,

                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),

                  ),

                  const SizedBox(width: 8),

                  Text(

                    entry.key,

                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(

                      fontWeight: FontWeight.w600,

                    ),

                  ),

                ],

              );

            }),

          ),

        ],

      ),

    );

  }

}

