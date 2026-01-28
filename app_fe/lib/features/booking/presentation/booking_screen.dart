import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../profile/presentation/user_provider.dart';
import '../data/dto/booking_dto.dart';
import 'booking_list_controller.dart';
import 'package:intl/intl.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-refresh khi app quay lại từ background
    if (state == AppLifecycleState.resumed) {
      ref.read(bookingListControllerProvider.notifier).refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final userAvatar = userState.avatar;
    final bookingState = ref.watch(bookingListControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(userAvatar),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUpcomingList(bookingState),
                  _buildPastList(bookingState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userAvatar) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF3F4F6),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
              image: userAvatar.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(userAvatar),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: userAvatar.isEmpty
                ? const Icon(Icons.person_outline, color: Color(0xFF101418))
                : null,
          ),
          const Expanded(
            child: Text(
              'Lịch của tôi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF101418),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: const Color(0xFF297EFF),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelColor: const Color(0xFF6B7280),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Sắp tới'),
            Tab(text: 'Đã xong'),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingList(BookingListState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF297EFF)),
      );
    }

    if (state.upcomingBookings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(bookingListControllerProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.upcomingBookings.length + 1,
        itemBuilder: (context, index) {
          if (index == state.upcomingBookings.length) {
            return _buildPromoCard();
          }
          return _buildBookingCard(state.upcomingBookings[index]);
        },
      ),
    );
  }

  Widget _buildPastList(BookingListState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF297EFF)),
      );
    }

    if (state.completedBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Chưa có lịch hẹn nào đã hoàn thành',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(bookingListControllerProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.completedBookings.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(
            state.completedBookings[index],
            isPast: true,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Empty state icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF297EFF).withOpacity(0.1),
                  blurRadius: 24,
                  spreadRadius: 12,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 36,
                  color: const Color(0xFF297EFF).withOpacity(0.2),
                ),
                const Icon(
                  Icons.event_busy,
                  size: 30,
                  color: Color(0xFF297EFF),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bạn chưa có lịch hẹn nào sắp tới',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101418),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Hãy đặt lịch hẹn với bác sĩ để bắt đầu chăm sóc sức khỏe của bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          _buildPromoCard(),
          const SizedBox(height: 100), // Bottom padding for navigation
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingDto booking, {bool isPast = false}) {
    final status = booking.status?.toUpperCase() ?? '';
    Color statusColor;
    String statusText;
    Color statusBgColor;

    switch (status) {
      case 'CONFIRMED':
        statusColor = const Color(0xFF00C853);
        statusBgColor = const Color(0xFF00C853).withOpacity(0.1);
        statusText = 'Đã xác nhận';
        break;
      case 'COMPLETED':
        statusColor = const Color(0xFF6B7280);
        statusBgColor = const Color(0xFF6B7280).withOpacity(0.1);
        statusText = 'Đã hoàn thành';
        break;
      case 'CANCELED':
        statusColor = const Color(0xFFFF5252);
        statusBgColor = const Color(0xFFFF5252).withOpacity(0.1);
        statusText = 'Đã hủy';
        break;
      default:
        statusColor = const Color(0xFF297EFF);
        statusBgColor = const Color(0xFF297EFF).withOpacity(0.1);
        statusText = 'Đang chờ';
    }

    // Format date/time from time slot if available
    String dateStr = 'Chưa xác định';
    String timeStr = 'Chưa xác định';

    if (booking.timeSlot != null) {
      final ts = booking.timeSlot!;
      dateStr = DateFormat('dd MMM, yyyy', 'vi').format(ts.date);
      timeStr =
          '${ts.startTime.substring(0, 5)} - ${ts.endTime.substring(0, 5)}';
    }

    return GestureDetector(
      onTap: () {
        // Điều hướng đến chi tiết lịch hẹn
        context.push('/booking-detail', extra: booking);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar bác sĩ
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF297EFF).withOpacity(0.1),
                      image:
                          booking.doctorAvatarUrl != null &&
                              booking.doctorAvatarUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(booking.doctorAvatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child:
                        booking.doctorAvatarUrl == null ||
                            booking.doctorAvatarUrl!.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xFF297EFF),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (status == 'PENDING')
                                Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Tên bác sĩ
                        Text(
                          booking.doctorName ?? 'Bác sĩ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101418),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Tên dịch vụ
                        Text(
                          booking.serviceName ?? 'Dịch vụ khám',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Mũi tên xem chi tiết
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF9CA3AF),
                    size: 24,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Color(0xFF297EFF),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 18,
                            color: Color(0xFF297EFF),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!isPast && status != 'CANCELED')
                    TextButton(
                      onPressed: () {
                        // TODO: Implement cancel logic
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFFF5252,
                        ).withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Hủy lịch',
                        style: TextStyle(
                          color: Color(0xFFFF5252),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF297EFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              size: 32,
              color: Color(0xFF297EFF),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cần đặt lịch mới?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101418),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dễ dàng đặt lịch với hàng ngàn bác sĩ giỏi trên toàn quốc.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                context.push('/select-service');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF297EFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF297EFF).withOpacity(0.2),
              ),
              child: const Text(
                'Đặt lịch ngay',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
