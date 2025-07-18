import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stock_tracker_app/src/features/companies/controllers/company_detail_controller.dart';
import 'package:stock_tracker_app/src/shared/widgets/loading_widget.dart';
import 'package:stock_tracker_app/src/shared/widgets/error_widget.dart';
import 'package:stock_tracker_app/src/shared/widgets/main_navigation.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyDetailScreen extends StatelessWidget {
  const CompanyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompanyDetailController>();

    return MainNavigation(
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(controller.company?.symbol ?? 'Chi tiết công ty')),
          actions: [
            Obx(() {
              final company = controller.company;
              if (company?.website != null) {
                return IconButton(
                  icon: const Icon(Icons.language),
                  onPressed: () => _launchUrl(company!.website!),
                  tooltip: 'Website công ty',
                );
              }
              return const SizedBox.shrink();
            }),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.fetchNewMetrics(),
              tooltip: 'Fetch metrics mới',
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading) {
            return const LoadingWidget(message: 'Đang tải thông tin công ty...');
          }
      
          if (controller.errorMessage.isNotEmpty) {
            return ErrorDisplayWidget(
              message: controller.errorMessage,
              onRetry: () {
                final symbol = Get.parameters['symbol'];
                if (symbol != null) {
                  controller.loadCompanyDetail(symbol);
                }
              },
            );
          }
      
          final company = controller.company;
          if (company == null) {
            return const Center(child: Text('Không tìm thấy thông tin công ty'));
          }
      
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Header
                _buildCompanyHeader(context, company, controller),
      
                // Latest Metrics
                if (controller.latestMetrics != null)
                  _buildLatestMetrics(context, controller.latestMetrics!),
      
                // Charts Section
                if (controller.metricsHistory.isNotEmpty) ...[
                  _buildChartsSection(context, controller),
                ],
      
                // Company Info
                _buildCompanyInfo(context, company),
      
                // Actions
                _buildActionButtons(context, company, controller),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCompanyHeader(BuildContext context, company, CompanyDetailController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: company.isActive ? Colors.green : Colors.grey,
                child: Text(
                  company.symbol.length >= 2 ? company.symbol.substring(0, 2) : company.symbol,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.symbol,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company.companyName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: company.isActive 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  company.isActive ? 'ACTIVE' : 'INACTIVE',
                  style: TextStyle(
                    fontSize: 12,
                    color: company.isActive ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (company.sector != null) ...[
                _buildInfoChip(context, 'Sector', company.sector!, Icons.business),
                const SizedBox(width: 12),
              ],
              if (company.country != null)
                _buildInfoChip(context, 'Country', company.country, Icons.flag),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestMetrics(BuildContext context, metrics) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chỉ số tài chính mới nhất',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _buildMetricCard(
                    context, 
                    'P/E Ratio', 
                    metrics.peRatio?.toStringAsFixed(2) ?? 'N/A',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                  _buildMetricCard(
                    context, 
                    'Market Cap', 
                    metrics.formattedMarketCap,
                    Icons.account_balance,
                    Colors.green,
                  ),
                  _buildMetricCard(
                    context, 
                    'ROE', 
                    metrics.roe != null ? '${(metrics.roe! * 100).toStringAsFixed(1)}%' : 'N/A',
                    Icons.show_chart,
                    Colors.orange,
                  ),
                  _buildMetricCard(
                    context, 
                    'Revenue', 
                    metrics.formattedRevenue,
                    Icons.monetization_on,
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Cập nhật: ${_formatDate(metrics.recordedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, CompanyDetailController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Biểu đồ xu hướng',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // P/E Ratio Chart
              if (controller.peRatioChartData.isNotEmpty) ...[
                Text(
                  'P/E Ratio',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    _buildLineChartData(
                      controller.peRatioChartData,
                      Colors.blue,
                      'P/E',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // ROE Chart
              if (controller.roeChartData.isNotEmpty) ...[
                Text(
                  'ROE (%)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    _buildLineChartData(
                      controller.roeChartData.map((e) => e * 100).toList(), // Convert to percentage
                      Colors.orange,
                      'ROE %',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  LineChartData _buildLineChartData(List<double> data, Color color, String label) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              const style = TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
              );
              if (value.toInt() < data.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text('${value.toInt() + 1}', style: style),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: null,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              );
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: data.length.toDouble() - 1,
      minY: data.isNotEmpty ? data.reduce((a, b) => a < b ? a : b) * 0.9 : 0,
      maxY: data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) * 1.1 : 100,
      lineBarsData: [
        LineChartBarData(
          spots: data.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value);
          }).toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              color,
              color.withOpacity(0.3),
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyInfo(BuildContext context, company) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin công ty',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(context, 'Symbol', company.symbol),
              _buildInfoRow(context, 'Tên công ty', company.companyName),
              if (company.sector != null)
                _buildInfoRow(context, 'Sector', company.sector!),
              if (company.industry != null)
                _buildInfoRow(context, 'Industry', company.industry!),
              _buildInfoRow(context, 'Quốc gia', company.country),
              if (company.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Mô tả',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  company.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, company, CompanyDetailController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.fetchNewMetrics(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Fetch Metrics Mới'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.toggleCompanyStatus(),
                  icon: Icon(company.isActive ? Icons.pause : Icons.play_arrow),
                  label: Text(company.isActive ? 'Tạm dừng' : 'Kích hoạt'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: company.isActive ? Colors.orange : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          if (company.website != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _launchUrl(company.website!),
                icon: const Icon(Icons.language),
                label: const Text('Website công ty'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Lỗi',
        'Không thể mở liên kết',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
