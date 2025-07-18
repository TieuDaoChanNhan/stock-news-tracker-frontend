import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/models/dashboard_model.dart';
import 'package:stock_tracker_app/src/shared/utils/app_routes.dart';

class CompanyOverviewSection extends StatelessWidget {
  final DashboardData? dashboardData;

  const CompanyOverviewSection({
    super.key,
    this.dashboardData,
  });

  @override
  Widget build(BuildContext context) {
    if (dashboardData == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tổng quan công ty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.companies),
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Company stats cards
        Row(
          children: [
            Expanded(
              child: _buildCompanyStatCard(
                context,
                'Có dữ liệu',
                '${dashboardData!.companiesWithData}',
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCompanyStatCard(
                context,
                'Thiếu dữ liệu',
                '${dashboardData!.companiesWithoutData}',
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Top companies list
        if (dashboardData!.companies.isNotEmpty) ...[
          Text(
            'Top công ty gần đây',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dashboardData!.companies.take(5).length,
            itemBuilder: (context, index) {
              final company = dashboardData!.companies[index];
              return _buildCompanyTile(context, company);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCompanyStatCard(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyTile(BuildContext context, CompanySummary company) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        backgroundColor: company.isActive ? Colors.green : Colors.grey,
        child: Text(
          company.symbol.substring(0, 2),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      title: Text(
        company.symbol,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        company.sector ?? 'N/A',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (company.peRatio != null)
            Text(
              'PE: ${company.peRatio!.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          if (company.marketCap != null)
            Text(
              _formatMarketCap(company.marketCap!),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      onTap: () => Get.toNamed(
        AppRoutes.companyDetail.replaceAll(':symbol', company.symbol),
      ),
    );
  }

  String _formatMarketCap(int marketCap) {
    if (marketCap >= 1000000000) {
      return '\$${(marketCap / 1000000000).toStringAsFixed(1)}B';
    } else if (marketCap >= 1000000) {
      return '\$${(marketCap / 1000000).toStringAsFixed(1)}M';
    }
    return '\$${marketCap}';
  }
}
