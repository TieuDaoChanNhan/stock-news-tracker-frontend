import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/companies/controllers/companies_controller.dart';
import 'package:stock_tracker_app/src/shared/widgets/loading_widget.dart';
import 'package:stock_tracker_app/src/shared/widgets/error_widget.dart';
import 'package:stock_tracker_app/src/shared/widgets/empty_widget.dart';
import 'package:stock_tracker_app/src/shared/utils/app_routes.dart';
import 'package:stock_tracker_app/src/shared/widgets/main_navigation.dart';

class CompaniesListScreen extends StatelessWidget {
  const CompaniesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final companiesController = Get.find<CompaniesController>();

    return MainNavigation(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Công ty theo dõi'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => companiesController.refreshCompanies(),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'toggle_filter':
                    companiesController.toggleActiveFilter();
                    break;
                  case 'add_company':
                    _showAddCompanyDialog(context, companiesController);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle_filter',
                  child: Row(
                    children: [
                      Icon(companiesController.showActiveOnly 
                          ? Icons.visibility_off 
                          : Icons.visibility),
                      const SizedBox(width: 8),
                      Text(companiesController.showActiveOnly 
                          ? 'Hiện tất cả' 
                          : 'Chỉ hiện active'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'add_company',
                  child: Row(
                    children: [
                      Icon(Icons.add_business),
                      SizedBox(width: 8),
                      Text('Thêm công ty'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // // Filter chips
            // Padding(
            //   padding: const EdgeInsets.all(16),
            //   child: Obx(() => Wrap(
            //     spacing: 8,
            //     children: [
            //       FilterChip(
            //         selected: companiesController.showActiveOnly,
            //         label: Text('Chỉ active (${companiesController.companies.where((c) => c.isActive).length})'),
            //         onSelected: (selected) => companiesController.toggleActiveFilter(),
            //       ),
            //       // Sector filters
            //       ...companiesController.companiesBySector.keys.map((sector) {
            //         final count = companiesController.companiesBySector[sector]!.length;
            //         return FilterChip(
            //           selected: false,
            //           label: Text('$sector ($count)'),
            //           onSelected: (selected) {
            //             // Implement sector filtering if needed
            //           },
            //         );
            //       }).take(3), // Chỉ hiển thị top 3 sectors
            //     ],
            //   )),
            // ),
      
            // Companies List
            Expanded(
              child: Obx(() {
                if (companiesController.isLoading) {
                  return const LoadingWidget(message: 'Đang tải danh sách công ty...');
                }
      
                if (companiesController.errorMessage.isNotEmpty) {
                  return ErrorDisplayWidget(
                    message: companiesController.errorMessage,
                    onRetry: () => companiesController.refreshCompanies(),
                  );
                }
      
                if (companiesController.companies.isEmpty) {
                  return const EmptyWidget(
                    title: 'Chưa có công ty nào',
                    subtitle: 'Thêm công ty để bắt đầu theo dõi',
                    icon: Icons.business_outlined,
                  );
                }
      
                return RefreshIndicator(
                  onRefresh: () => companiesController.refreshCompanies(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: companiesController.companies.length,
                    itemBuilder: (context, index) {
                      final company = companiesController.companies[index];
                      return _buildCompanyCard(context, company, companiesController);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyCard(BuildContext context, company, CompaniesController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: company.isActive ? Colors.green : Colors.grey,
          child: Text(
            company.symbol.length >= 2 ? company.symbol.substring(0, 2) : company.symbol,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                company.symbol,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: company.isActive 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                company.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  color: company.isActive ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              company.companyName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (company.sector != null)
              Text(
                '${company.sector} • ${company.industry ?? "N/A"}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.language,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  company.country,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    company.isActive ? Icons.pause : Icons.play_arrow,
                    color: company.isActive ? Colors.orange : Colors.green,
                  ),
                  onPressed: () => controller.updateCompanyStatus(
                    company.symbol, 
                    !company.isActive
                  ),
                  tooltip: company.isActive ? 'Tạm dừng tracking' : 'Bắt đầu tracking',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => controller.fetchMetricsForCompany(company.symbol),
                  tooltip: 'Fetch metrics mới',
                ),
              ],
            ),
          ],
        ),
        onTap: () => Get.toNamed(
          AppRoutes.companyDetail.replaceAll(':symbol', company.symbol),
        ),
      ),
    );
  }

  void _showAddCompanyDialog(BuildContext context, CompaniesController controller) {
    final symbolController = TextEditingController();
    final nameController = TextEditingController();
    final sectorController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Thêm công ty mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: symbolController,
              decoration: const InputDecoration(
                labelText: 'Symbol (VD: AAPL)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên công ty',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sectorController,
              decoration: const InputDecoration(
                labelText: 'Sector (tùy chọn)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (symbolController.text.trim().isNotEmpty &&
                  nameController.text.trim().isNotEmpty) {
                Get.back();
                // TODO: Implement add company functionality
                Get.snackbar(
                  'Thông báo',
                  'Tính năng thêm công ty sẽ có trong phiên bản tới',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}
