import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import 'dto/booking_dto.dart';

final bookingsApiProvider = Provider(
  (ref) => BookingsApi(ref.watch(apiClientProvider)),
);

class BookingsApi {
  final ApiClient _client;

  BookingsApi(this._client);

  /// Lấy danh sách lịch hẹn với filter và phân trang (Admin)
  Future<BookingPageDto> getBookings({
    String? status,
    String? doctorId,
    String? date,
    String? search,
    int page = 0,
    int size = 10,
  }) async {
    try {
      // Backend sử dụng /bookings/admin cho admin
      final response = await _client.get(
        '/bookings/admin',
        queryParameters: {
          if (status != null && status != 'ALL') 'status': status,
          'page': page,
          'size': size,
        },
      );

      // Handle response format
      if (response.data['data'] == null) {
        return const BookingPageDto(content: []);
      }

      // If response is paginated (PageResponse format)
      final data = response.data['data'];
      if (data is Map && data['content'] != null) {
        final content = (data['content'] as List)
            .map((e) => BookingDto.fromJson(e))
            .toList();
        
        // Client-side filter by doctorId if provided
        var filteredContent = content;
        if (doctorId != null && doctorId.isNotEmpty) {
          filteredContent = content.where((b) => b.doctorId == doctorId).toList();
        }
        
        // Client-side filter by date if provided
        if (date != null && date.isNotEmpty) {
          filteredContent = filteredContent.where((b) => b.timeSlot.date == date).toList();
        }
        
        // Client-side search if provided
        if (search != null && search.isNotEmpty) {
          final searchLower = search.toLowerCase();
          filteredContent = filteredContent.where((b) {
            final patientName = b.patientName?.toLowerCase() ?? '';
            final doctorName = b.doctorName?.toLowerCase() ?? '';
            final id = b.id.toLowerCase();
            return patientName.contains(searchLower) ||
                doctorName.contains(searchLower) ||
                id.contains(searchLower);
          }).toList();
        }
        
        return BookingPageDto(
          content: filteredContent,
          totalElements: data['totalElements'] ?? filteredContent.length,
          totalPages: data['totalPages'] ?? 1,
          currentPage: data['page'] ?? page,
          pageSize: data['size'] ?? size,
        );
      }

      // If response is a simple list
      if (data is List) {
        final content = data.map((e) => BookingDto.fromJson(e)).toList();
        return BookingPageDto(
          content: content,
          totalElements: content.length,
          totalPages: 1,
          currentPage: 0,
          pageSize: content.length,
        );
      }

      return const BookingPageDto(content: []);
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy chi tiết lịch hẹn
  Future<BookingDto> getBookingById(String id) async {
    final response = await _client.get('/bookings/$id');
    return BookingDto.fromJson(response.data['data']);
  }

  /// Lấy thống kê lịch hẹn - Tính toán từ danh sách bookings
  Future<BookingStatsDto> getBookingStats() async {
    try {
      // Lấy tất cả bookings để tính stats
      final response = await _client.get(
        '/bookings/admin',
        queryParameters: {'page': 0, 'size': 1000},
      );

      if (response.data['data'] == null) {
        return const BookingStatsDto();
      }

      final data = response.data['data'];
      List<BookingDto> bookings = [];
      
      if (data is Map && data['content'] != null) {
        bookings = (data['content'] as List)
            .map((e) => BookingDto.fromJson(e))
            .toList();
      } else if (data is List) {
        bookings = data.map((e) => BookingDto.fromJson(e)).toList();
      }

      // Tính toán stats
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final todayBookings = bookings.where((b) => b.timeSlot.date == todayStr).length;
      final pendingCount = bookings.where((b) => b.status == 'PENDING').length;
      final confirmedCount = bookings.where((b) => b.status == 'CONFIRMED').length;
      final completedCount = bookings.where((b) => b.status == 'COMPLETED').length;
      final canceledCount = bookings.where((b) => b.status == 'CANCELED').length;

      return BookingStatsDto(
        totalToday: todayBookings,
        pendingCount: pendingCount,
        confirmedCount: confirmedCount,
        completedCount: completedCount,
        canceledCount: canceledCount,
        todayChangePercent: 5.0, // Placeholder
        pendingChangePercent: -2.0, // Placeholder
        completedChangePercent: 10.0, // Placeholder
      );
    } catch (e) {
      // Return default stats if API not available
      return const BookingStatsDto();
    }
  }

  /// Xác nhận lịch hẹn (Backend dùng PUT)
  Future<BookingDto> confirmBooking(String id, String adminUserId) async {
    final response = await _client.put(
      '/bookings/$id/confirm',
      queryParameters: {'userId': adminUserId},
    );
    return BookingDto.fromJson(response.data['data']);
  }

  /// Hoàn thành lịch hẹn (Backend dùng PUT)
  Future<BookingDto> completeBooking(String id, String adminUserId, {String? doctorNotes}) async {
    final response = await _client.put(
      '/bookings/$id/complete',
      queryParameters: {
        'userId': adminUserId,
        if (doctorNotes != null) 'doctorNotes': doctorNotes,
      },
    );
    return BookingDto.fromJson(response.data['data']);
  }

  /// Hủy lịch hẹn (Backend dùng PUT)
  Future<BookingDto> cancelBooking(String id, String adminUserId, {String? reason}) async {
    final response = await _client.put(
      '/bookings/$id/cancel',
      queryParameters: {'userId': adminUserId},
      data: {'reason': reason ?? 'Cancelled by admin'},
    );
    return BookingDto.fromJson(response.data['data']);
  }

  /// Lấy danh sách bác sĩ cho dropdown filter
  Future<List<DoctorSimpleDto>> getDoctorsForFilter() async {
    try {
      final response = await _client.get('/doctors', queryParameters: {
        'size': 100, // Get all doctors for dropdown
      });
      
      if (response.data['data'] == null) return [];
      
      final data = response.data['data'];
      if (data is Map && data['content'] != null) {
        return (data['content'] as List)
            .map((e) => DoctorSimpleDto.fromJson(e))
            .toList();
      }
      
      if (data is List) {
        return data.map((e) => DoctorSimpleDto.fromJson(e)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
}

/// Simple DTO cho dropdown bác sĩ
class DoctorSimpleDto {
  final String id;
  final String fullName;

  DoctorSimpleDto({required this.id, required this.fullName});

  factory DoctorSimpleDto.fromJson(Map<String, dynamic> json) {
    return DoctorSimpleDto(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? 'N/A',
    );
  }
}
