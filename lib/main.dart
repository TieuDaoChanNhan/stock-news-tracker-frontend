import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stock_tracker_app/src/app.dart';
import 'package:stock_tracker_app/src/shared/bindings/initial_binding.dart';
import 'package:stock_tracker_app/src/shared/utils/cache_helper.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Initialize locale data
  await initializeDateFormatting('vi_VN', null);
  
  // Initialize cache
  await CacheHelper.init();
  
  // Initialize dependencies
  InitialBinding().dependencies();

  usePathUrlStrategy();
  
  runApp(const MyApp());
}
