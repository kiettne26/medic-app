import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bookings/presentation/bookings_controller.dart';
import '../../dashboard/data/dto/dashboard_dto.dart';
import '../../dashboard/presentation/dashboard_controller.dart';

class RevenueScreen extends ConsumerStatefulWidget {
  const RevenueScreen({super.key});

  @override
  ConsumerState<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends ConsumerState<RevenueScreen> {
  String _selectedTab = 'Tháng này';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(statsControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statsControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs & Heading
          _buildHeader(),
          const SizedBox(height: 32),

          // Tabs
          _buildTabs(),
          const SizedBox(height: 32),

          statsAsync.when(
            data: (data) => Column(
              children: [
                // KPI Grid
                _buildKpiGrid(data),
                const SizedBox(height: 32),

                // Charts Section
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Revenue by Service (Bar Chart)
                        Expanded(flex: 2, child: _buildRevenueChartCard(data)),
                        const SizedBox(width: 32),
                        // Top Doctors
                        Expanded(flex: 1, child: _buildTopDoctorsCard(data)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Growth Chart
                _buildGrowthChartCard(data),
                const SizedBox(height: 32),

                // Data Table
                _buildDataTableCard(data),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Lỗi: $e')),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doanh thu',
                  style: GoogleFonts.manrope(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111418),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Theo dõi hiệu suất vận hành và doanh thu hệ thống MediBook',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5F718C),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _HeaderTextButton(
                  icon: Icons.upload_outlined,
                  label: 'Xuất Excel',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _HeaderPrimaryButton(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Xuất PDF',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final tabs = [];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return InkWell(
            onTap: () => setState(() => _selectedTab = tab),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              margin: const EdgeInsets.only(right: 32),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? const Color(0xFF2E80FA)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? const Color(0xFF2E80FA)
                      : const Color(0xFF5F718C),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKpiGrid(DashboardDto data) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            title: 'Tổng lịch hẹn',
            value: data.totalBookings.toString(),
            icon: Icons.calendar_today_outlined,
            iconColor: const Color(0xFF2E80FA),
            iconBgColor: const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _KpiCard(
            title: 'Hoàn thành',
            value: data.completedBookings.toString(),
            icon: Icons.event_available_outlined,
            iconColor: const Color(0xFF10B981),
            iconBgColor: const Color(0xFFF0FDF4),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _KpiCard(
            title: 'Chờ xử lý',
            value: data.pendingBookings.toString(),
            icon: Icons.pending_actions_outlined,
            iconColor: const Color(0xFFF59E0B),
            iconBgColor: const Color(0xFFFFFBEB),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _KpiCard(
            title: 'Bệnh nhân',
            value: data.totalPatients.toString(),
            icon: Icons.person_outline,
            iconColor: const Color(0xFF9333EA),
            iconBgColor: const Color(0xFFFAF5FF),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChartCard(DashboardDto data) {
    final services = data.popularServices;
    // Map data to chart format. Since we don't have revenue per service in DTO yet,
    // we might need to rely on bookingCount or percentage.
    // For now, let's assume we map percentage to Y axis or bookingCount.
    // Let's use percentage for "Effective comparison" as the subtitle says.

    // Sort or limit to top 5
    final topServices = services.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dịch vụ phổ biến',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111418),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tỷ lệ đặt lịch theo dịch vụ',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: const Color(0xFF5F718C),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz, color: Color(0xFF5F718C)),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100, // Percentage max 100
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => const Color(0xFF111827),
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)}%',
                        GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < topServices.length) {
                          // Truncate name if too long
                          String name = topServices[index]
                              .serviceName; // Correct property
                          if (name.length > 10)
                            name = '${name.substring(0, 8)}..';

                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 10,
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: Color(0xFF5F718C),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: const Color(0xFFF3F4F6), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: topServices.asMap().entries.map((e) {
                  final index = e.key;
                  final service = e.value;
                  return _makeGroupData(
                    index,
                    service.percentage,
                    index % 2 == 0
                        ? const Color(0xFF2E80FA)
                        : const Color(0xFF10B981),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color.withOpacity(0.8),
          width: 40,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          backDrawRodData: BackgroundBarChartRodData(show: false),
        ),
      ],
    );
  }

  Widget _buildTopDoctorsCard(DashboardDto data) {
    final doctors = data.topDoctors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top 5 Bác sĩ',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111418),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Xem tất cả',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E80FA),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (doctors.isNotEmpty)
            ...doctors.asMap().entries.map((e) {
              final index = e.key;
              final doc = e.value;
              Color rankColor = Colors.transparent;
              if (index == 0) rankColor = const Color(0xFFFACC15);
              if (index == 1) rankColor = const Color(0xFFD1D5DB);
              if (index == 2) rankColor = const Color(0xFFFDBA74);

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _DoctorListItem(
                  rank: index + 1,
                  name: doc.doctorName, // Corrected property
                  detail: '${doc.totalBookings} ca', // Corrected property
                  rating: doc.rating,
                  rankColor: rankColor,
                  isHiddenRank: index > 2,
                ),
              );
            }).toList()
          else
            const Text('Chưa có dữ liệu'),
        ],
      ),
    );
  }

  Widget _buildGrowthChartCard(DashboardDto data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tăng trưởng lịch hẹn',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111418),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Số lượng đặt lịch theo thời gian',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: const Color(0xFF5F718C),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _LegendItem(
                    color: const Color(0xFF2E80FA),
                    label: 'Lịch đã đặt',
                  ),
                  const SizedBox(width: 16),
                  _LegendItem(
                    color: const Color(0xFF10B981),
                    label: 'Hoàn thành',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFF3F4F6),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ), // Hide left titles as per design clean look or add specific
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final bookings = data.bookingsByDay;
                        if (value.toInt() >= 0 &&
                            value.toInt() < bookings.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              bookings[value.toInt()].label,
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF5F718C),
                                letterSpacing: 1,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                // maxX: 4, // Remove hardcoded maxX
                minY: 0,
                // maxY: 200, // Remove hardcoded maxY
                lineBarsData: [
                  // Blue Line
                  LineChartBarData(
                    spots: data.bookingsByDay
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(
                            e.key.toDouble(),
                            e.value.count.toDouble(),
                          ),
                        )
                        .toList(),
                    isCurved: true,
                    color: const Color(0xFF2E80FA),
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTableCard(DashboardDto data) {
    final bookingsAsync = ref.watch(bookingsControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Báo cáo lịch khám chi tiết',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111418),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Tất cả trạng thái',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111418),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list),
                      color: const Color(0xFF5F718C),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // Table
          bookingsAsync.when(
            data: (bookings) => SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF9FAFB),
                ),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                dividerThickness: 1,
                columns: const [
                  DataColumn(label: _TableTitle('MÃ LỊCH')),
                  DataColumn(label: _TableTitle('BÁC SĨ')),
                  DataColumn(label: _TableTitle('DỊCH VỤ')),
                  DataColumn(label: _TableTitle('NGÀY KHÁM')),
                  DataColumn(label: _TableTitle('TRẠNG THÁI')),
                ],
                rows: bookings.take(10).map((booking) {
                  return DataRow(
                    cells: [
                      DataCell(
                        _TableText(
                          '#${booking.id.substring(0, 8)}',
                          bold: true,
                        ),
                      ),
                      DataCell(_DoctorCell(booking.doctorName ?? 'N/A')),
                      DataCell(_TableText(booking.serviceName ?? 'N/A')),
                      DataCell(_TableText(booking.timeSlot.date)),
                      DataCell(
                        _StatusBadge(
                          _getStatusLabel(booking.status),
                          _getStatusColor(booking.status),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) => Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text('Lỗi: $e')),
            ),
          ),
          // Pagination
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          bookingsAsync.when(
            data: (bookings) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: const Color(0xFFF9FAFB).withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hiển thị ${bookings.length > 10 ? 10 : bookings.length} trong ${bookings.length} kết quả',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: const Color(0xFF5F718C),
                    ),
                  ),
                  Row(
                    children: [
                      _PaginationButton(icon: Icons.chevron_left),
                      const SizedBox(width: 8),
                      _PaginationButton(icon: Icons.chevron_right),
                    ],
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFF10B981);
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'CONFIRMED':
        return const Color(0xFF2E80FA);
      case 'CANCELLED':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF5F718C);
    }
  }
}

// --- Helper Widgets ---

class _HeaderTextButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderTextButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF111418),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        textStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _HeaderPrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderPrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E80FA),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        textStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        shadowColor: const Color(0xFF2E80FA).withOpacity(0.2),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? change;
  final bool isPositive;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const _KpiCard({
    required this.title,
    required this.value,
    this.change,
    this.isPositive = true,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    change!,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPositive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5F718C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111418),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorListItem extends StatelessWidget {
  final int rank;
  final String name;
  final String detail;
  final double rating;
  final Color rankColor;
  final bool isHiddenRank;

  const _DoctorListItem({
    required this.rank,
    required this.name,
    required this.detail,
    required this.rating,
    required this.rankColor,
    this.isHiddenRank = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              child: Icon(Icons.person, color: Colors.grey.shade400),
              // backgroundImage: NetworkImage(...) // Use actual image if available
            ),
            if (!isHiddenRank)
              Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rankColor,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  rank.toString(),
                  style: GoogleFonts.manrope(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111418),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                detail,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: const Color(0xFF5F718C),
                ),
              ),
            ],
          ),
        ),
        Text(
          '$rating★',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5F718C),
          ),
        ),
      ],
    );
  }
}

class _TableTitle extends StatelessWidget {
  final String title;
  final TextAlign align;

  const _TableTitle(this.title, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // Expanded needed for DataColumn label if we want full control, but DataColumn wraps it.
      // Actually DataColumn label is just a widget.
      child: Text(
        title,
        textAlign: align,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF5F718C),
        ),
      ),
    );
  }
}

class _TableText extends StatelessWidget {
  final String text;
  final bool bold;
  final TextAlign align;

  const _TableText(this.text, {this.bold = false, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: align,
        style: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF111418),
        ),
      ),
    );
  }
}

class _DoctorCell extends StatelessWidget {
  final String name;

  const _DoctorCell(this.name);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.grey.shade200,
          child: Icon(Icons.person, size: 16, color: Colors.grey.shade500),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF111418),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;

  const _PaginationButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF111418)),
      ),
    );
  }
}
