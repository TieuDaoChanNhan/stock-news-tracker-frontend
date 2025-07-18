import 'package:flutter/material.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? title;
  final IconData? icon;
  final String? retryText;
  
  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.icon,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'Oops! Có lỗi xảy ra',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Thử lại'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  
  const NetworkErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: 'Lỗi kết nối',
      message: 'Không thể kết nối đến server.\nVui lòng kiểm tra kết nối mạng và thử lại.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      retryText: 'Kết nối lại',
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? errorCode;
  
  const ServerErrorWidget({super.key, this.onRetry, this.errorCode});

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: 'Lỗi server',
      message: 'Server đang gặp sự cố.\nVui lòng thử lại sau ít phút.'
          '${errorCode != null ? '\n\nMã lỗi: $errorCode' : ''}',
      icon: Icons.dns,
      onRetry: onRetry,
    );
  }
}

class TimeoutErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  
  const TimeoutErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: 'Timeout',
      message: 'Kết nối bị timeout.\nVui lòng thử lại.',
      icon: Icons.hourglass_empty,
      onRetry: onRetry,
    );
  }
}

class NotFoundErrorWidget extends StatelessWidget {
  final String? itemType;
  final VoidCallback? onGoBack;
  
  const NotFoundErrorWidget({
    super.key, 
    this.itemType,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: 'Không tìm thấy',
      message: 'Không tìm thấy ${itemType ?? 'dữ liệu'} bạn yêu cầu.',
      icon: Icons.search_off,
      onRetry: onGoBack,
      retryText: 'Quay lại',
    );
  }
}

class UnauthorizedErrorWidget extends StatelessWidget {
  final VoidCallback? onLogin;
  
  const UnauthorizedErrorWidget({super.key, this.onLogin});

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: 'Không có quyền truy cập',
      message: 'Bạn cần đăng nhập để xem nội dung này.',
      icon: Icons.lock_outline,
      onRetry: onLogin,
      retryText: 'Đăng nhập',
    );
  }
}
