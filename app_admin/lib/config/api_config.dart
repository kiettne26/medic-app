/// Cấu hình API cho Admin Portal
class ApiConfig {
  // Đổi thành IP máy khi chạy trên thiết bị thật
  // Emulator Android: 10.0.2.2
  // iOS Simulator / Web: localhost
  static const String baseUrl = 'https://medibook.dpdns.org/api';

  // WebSocket URL
  static const String wsUrl = 'wss://medibook.dpdns.org/ws';
}
