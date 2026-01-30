import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import 'dto/booking_dto.dart';

final bookingsApiProvider = Provider(
  (ref) => BookingsApi(ref.watch(apiClientProvider)),
);

class BookingsApi {
  final ApiClient _client;

  BookingsApi(this._client);

  // Currently backend only has /patient and /doctor.
  // We need /admin/bookings or just /bookings (admin only)
  // For now using placeholder implementation that will fail until backend is updated
  Future<List<BookingDto>> getBookings({String? status}) async {
    // TODO: Update backend to support GET /bookings with filters for Admin
    // Using a temporary workaround if backend supports it, otherwise this will need backend update
    final response = await _client.get(
      '/bookings',
      queryParameters: {
        if (status != null && status != 'ALL') 'status': status,
      },
    );
    // Assuming backend returns PageResponse or List
    if (response.data['data'] == null) return [];

    if (response.data['data'] is Map &&
        response.data['data']['content'] != null) {
      final data = response.data['data']['content'] as List;
      return data.map((e) => BookingDto.fromJson(e)).toList();
    }
    final data = response.data['data'] as List;
    return data.map((e) => BookingDto.fromJson(e)).toList();
  }

  Future<BookingDto> getBookingById(String id) async {
    final response = await _client.get('/bookings/$id');
    return BookingDto.fromJson(response.data['data']);
  }
}
