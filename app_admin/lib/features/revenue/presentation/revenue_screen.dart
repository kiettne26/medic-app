import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../bookings/presentation/bookings_controller.dart';
import '../../dashboard/data/dto/dashboard_dto.dart';
import '../../dashboard/data/stats_api.dart';
import '../../dashboard/presentation/dashboard_controller.dart';
import '../../layout/admin_layout.dart';

/// Model cho tab period
class PeriodTab {
  final String label;
  final StatsPeriod period;

  const PeriodTab({required this.label, required this.period});
}

class RevenueScreen extends ConsumerStatefulWidget {
  const RevenueScreen({super.key});

  @override
  ConsumerState<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends ConsumerState<RevenueScreen> {
  /// Danh sách các tab với mapping tới StatsPeriod
  final List<PeriodTab> _tabs = const [
    PeriodTab(label: 'Hôm nay', period: StatsPeriod.today),
    PeriodTab(label: 'Tuần này', period: StatsPeriod.thisWeek),
    PeriodTab(label: 'Tháng này', period: StatsPeriod.thisMonth),
    PeriodTab(label: 'Năm nay', period: StatsPeriod.thisYear),
    PeriodTab(label: 'Tùy chỉnh', period: StatsPeriod.custom),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Set default period và fetch data
      ref.read(statsControllerProvider.notifier).changePeriod(StatsPeriod.thisMonth);
    });
  }

  /// Lấy index của tab dựa trên period hiện tại
  int get _selectedTabIndex {
    final currentPeriod = ref.watch(selectedPeriodProvider);
    return _tabs.indexWhere((tab) => tab.period == currentPeriod);
  }

  /// Xử lý khi chọn tab
  void _onTabSelected(int index) {
    final selectedTab = _tabs[index];
    
    if (selectedTab.period == StatsPeriod.custom) {
      _showDateRangePicker();
    } else {
      ref.read(statsControllerProvider.notifier).changePeriod(selectedTab.period);
    }
  }

  /// Hiển thị dialog chọn khoảng thời gian tùy chỉnh
  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();
    final customRange = ref.read(customDateRangeProvider);
    
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: customRange != null 
        ? DateTimeRange(start: customRange.start, end: customRange.end)
        : DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AdminColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(statsControllerProvider.notifier).setCustomDateRange(
        picked.start,
        picked.end,
      );
    }
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}đ';
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statsControllerProvider);
    final bookingsState = ref.watch(bookingsControllerProvider);

    return Container(
      color: AdminColors.backgroundLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),
            const SizedBox(height: 24),

            // Tabs
            _buildTabs(),
            const SizedBox(height: 24),

            statsAsync.when(
              data: (data) => Column(
                children: [
                  // KPI Grid - 4 cards
                  _buildKpiGrid(data, bookingsState),
                  const SizedBox(height: 24),

                  // Charts Section - 2 columns
                  _buildChartsSection(data),
                  const SizedBox(height: 24),

                  // Growth Chart
                  _buildGrowthChartCard(data),
                  const SizedBox(height: 24),

                  // Data Table
                  _buildDataTableCard(bookingsState),
                ],
              ),
              loading: () => const SizedBox(
                height: 400,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => SizedBox(
                height: 400,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text('Lỗi: $e'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(statsControllerProvider.notifier).refresh(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thống kê & Báo cáo',
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AdminColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Theo dõi hiệu suất vận hành và doanh thu hệ thống MediBook',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AdminColors.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_outlined, size: 18),
              label: const Text('Xuất Excel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminColors.textPrimary,
                side: const BorderSide(color: AdminColors.borderLight),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Xuất PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final selectedIndex = _selectedTabIndex;
    final customRange = ref.watch(customDateRangeProvider);
    
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AdminColors.borderLight)),
      ),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = selectedIndex == index;
          
          // Hiển thị label với date range nếu là custom và đã chọn
          String displayLabel = tab.label;
          if (tab.period == StatsPeriod.custom && customRange != null && isSelected) {
            final dateFormat = DateFormat('dd/MM');
            displayLabel = '${dateFormat.format(customRange.start)} - ${dateFormat.format(customRange.end)}';
          }
          
          return InkWell(
            onTap: () => _onTabSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              margin: const EdgeInsets.only(right: 32),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AdminColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                displayLabel,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AdminColors.primary : AdminColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKpiGrid(DashboardDto data, BookingsState bookingsState) {
    // Sử dụng doanh thu thực từ API (tính từ giá dịch vụ trong database)
    final totalRevenue = data.totalRevenue;
    final completedCount = data.completedBookings;

    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            title: 'Tổng doanh thu',
            value: _formatCurrency(totalRevenue),
            icon: Icons.payments_outlined,
            iconColor: AdminColors.primary,
            iconBgColor: const Color(0xFFEFF6FF),
            change: '+12.5%',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            title: 'Lịch hẹn hoàn thành',
            value: NumberFormat('#,###').format(completedCount),
            icon: Icons.event_available_outlined,
            iconColor: const Color(0xFF10B981),
            iconBgColor: const Color(0xFFF0FDF4),
            change: '+8.2%',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            title: 'Bệnh nhân mới',
            value: NumberFormat('#,###').format(data.totalPatients),
            icon: Icons.person_add_outlined,
            iconColor: const Color(0xFF9333EA),
            iconBgColor: const Color(0xFFFAF5FF),
            change: '+15%',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            title: 'Đánh giá trung bình',
            value: '4.8 / 5.0',
            icon: Icons.star_outline,
            iconColor: const Color(0xFFF59E0B),
            iconBgColor: const Color(0xFFFFFBEB),
            change: 'Ổn định',
            isPositive: true,
            isNeutral: true,
          ),
        ),
      ],
    );
  }

  Widget _buildChartsSection(DashboardDto data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Revenue by Service (Bar Chart) - 2/3 width
        Expanded(
          flex: 2,
          child: _buildRevenueChartCard(data),
        ),
        const SizedBox(width: 24),
        // Top Doctors - 1/3 width
        Expanded(
          flex: 1,
          child: _buildTopDoctorsCard(data),
        ),
      ],
    );
  }

  Widget _buildRevenueChartCard(DashboardDto data) {
    final services = data.popularServices.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.borderLight),
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
                    'Doanh thu theo dịch vụ',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'So sánh hiệu quả các gói khám',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz, color: AdminColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 280,
            child: services.isEmpty
                ? const Center(child: Text('Chưa có dữ liệu'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => const Color(0xFF111827),
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final serviceName = groupIndex < services.length 
                                ? services[groupIndex].serviceName 
                                : '';
                            return BarTooltipItem(
                              '$serviceName\n${rod.toY.toStringAsFixed(1)}%',
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
                              if (index >= 0 && index < services.length) {
                                String name = services[index].serviceName;
                                if (name.length > 10) name = '${name.substring(0, 8)}..';
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    name,
                                    style: GoogleFonts.manrope(
                                      color: AdminColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                            reservedSize: 32,
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (value) => const FlLine(
                          color: AdminColors.borderLight,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: services.asMap().entries.map((e) {
                        final index = e.key;
                        final service = e.value;
                        final color = index % 2 == 0
                            ? AdminColors.primary
                            : const Color(0xFF10B981);
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: service.percentage,
                              color: color.withValues(alpha: 0.7),
                              width: 48,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDoctorsCard(DashboardDto data) {
    final doctors = data.topDoctors.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top 5 Bác sĩ',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Xem tất cả',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (doctors.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Chưa có dữ liệu')),
            )
          else
            ...doctors.asMap().entries.map((e) {
              final index = e.key;
              final doc = e.value;
              Color rankColor = Colors.grey;
              if (index == 0) rankColor = const Color(0xFFFACC15);
              if (index == 1) rankColor = const Color(0xFFD1D5DB);
              if (index == 2) rankColor = const Color(0xFFFDBA74);

              return Padding(
                padding: EdgeInsets.only(bottom: index < 4 ? 16 : 0),
                child: _DoctorListItem(
                  rank: index + 1,
                  name: 'BS. ${doc.doctorName}',
                  specialty: doc.specialty ?? 'Đa khoa',
                  cases: doc.totalBookings,
                  rating: doc.rating,
                  rankColor: rankColor,
                  showRankBadge: index < 3,
                  opacity: index > 2 ? 0.7 : 1.0,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildGrowthChartCard(DashboardDto data) {
    final bookingsByDay = data.bookingsByDay;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.borderLight),
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
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Số lượng đặt lịch theo thời gian',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _LegendDot(color: AdminColors.primary, label: 'Lịch đã đặt'),
                  const SizedBox(width: 16),
                  _LegendDot(color: const Color(0xFF10B981), label: 'Hoàn thành'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: bookingsByDay.isEmpty
                ? const Center(child: Text('Chưa có dữ liệu'))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 50,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AdminColors.borderLight,
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx >= 0 && idx < bookingsByDay.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    bookingsByDay[idx].label,
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AdminColors.textSecondary,
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
                      minY: 0,
                      lineBarsData: [
                        // Blue line - Lịch đã đặt
                        LineChartBarData(
                          spots: bookingsByDay.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.count.toDouble());
                          }).toList(),
                          isCurved: true,
                          color: AdminColors.primary,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                        // Green line - Hoàn thành (giả lập ~70% của tổng)
                        LineChartBarData(
                          spots: bookingsByDay.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), (e.value.count * 0.7).toDouble());
                          }).toList(),
                          isCurved: true,
                          color: const Color(0xFF10B981),
                          barWidth: 3,
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

  Widget _buildDataTableCard(BookingsState bookingsState) {
    final bookings = bookingsState.bookings;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.borderLight),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Báo cáo lịch khám chi tiết',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: 'all',
                          isDense: true,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
                            DropdownMenuItem(value: 'completed', child: Text('Hoàn thành')),
                            DropdownMenuItem(value: 'pending', child: Text('Đang chờ')),
                            DropdownMenuItem(value: 'cancelled', child: Text('Đã hủy')),
                          ],
                          onChanged: (value) {},
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, size: 20),
                      color: AdminColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AdminColors.borderLight),

          // Table
          if (bookingsState.isLoading)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (bookingsState.error != null)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Center(child: Text('Lỗi: ${bookingsState.error}')),
            )
          else if (bookings.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Chưa có dữ liệu', style: TextStyle(color: AdminColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                dataRowMinHeight: 56,
                dataRowMaxHeight: 56,
                columnSpacing: 32,
                horizontalMargin: 24,
                columns: [
                  DataColumn(label: _TableHeader('MÃ LỊCH')),
                  DataColumn(label: _TableHeader('BÁC SĨ')),
                  DataColumn(label: _TableHeader('DỊCH VỤ')),
                  DataColumn(label: _TableHeader('NGÀY KHÁM')),
                  DataColumn(label: _TableHeader('TRẠNG THÁI')),
                  DataColumn(label: _TableHeader('DOANH THU', align: TextAlign.right)),
                ],
                rows: bookings.take(10).map((booking) {
                  final revenue = booking.status == 'COMPLETED' ? 500000 : 0;
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        '#${booking.id.length > 8 ? booking.id.substring(0, 8) : booking.id}',
                        style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13),
                      )),
                      DataCell(_DoctorCell(booking.doctorName ?? 'N/A')),
                      DataCell(Text(booking.serviceName ?? 'N/A', style: GoogleFonts.manrope(fontSize: 13))),
                      DataCell(Text(_formatDate(booking.timeSlot.date), style: GoogleFonts.manrope(fontSize: 13))),
                      DataCell(_StatusBadge(status: booking.status)),
                      DataCell(Text(
                        _formatCurrency(revenue),
                        style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13),
                        textAlign: TextAlign.right,
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),

          // Pagination
          const Divider(height: 1, color: AdminColors.borderLight),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hiển thị ${bookings.length > 10 ? 10 : bookings.length} trong ${bookingsState.totalElements} kết quả',
                  style: GoogleFonts.manrope(fontSize: 12, color: AdminColors.textSecondary),
                ),
                Row(
                  children: [
                    _PaginationButton(
                      icon: Icons.chevron_left,
                      enabled: bookingsState.currentPage > 0,
                      onTap: () => ref.read(bookingsControllerProvider.notifier).previousPage(),
                    ),
                    const SizedBox(width: 8),
                    _PaginationButton(
                      icon: Icons.chevron_right,
                      enabled: bookingsState.currentPage < bookingsState.totalPages - 1,
                      onTap: () => ref.read(bookingsControllerProvider.notifier).nextPage(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

// ============== Helper Widgets ==============

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String? change;
  final bool isPositive;
  final bool isNeutral;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.change,
    this.isPositive = true,
    this.isNeutral = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.borderLight),
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
                child: Icon(icon, color: iconColor, size: 22),
              ),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isNeutral
                        ? Colors.grey.shade100
                        : isPositive
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    change!,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isNeutral
                          ? AdminColors.textSecondary
                          : isPositive
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
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AdminColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AdminColors.textPrimary,
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
  final String specialty;
  final int cases;
  final double rating;
  final Color rankColor;
  final bool showRankBadge;
  final double opacity;

  const _DoctorListItem({
    required this.rank,
    required this.name,
    required this.specialty,
    required this.cases,
    required this.rating,
    required this.rankColor,
    this.showRankBadge = true,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                child: Icon(Icons.person, color: Colors.grey.shade400, size: 20),
              ),
              if (showRankBadge)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
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
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$specialty • $cases ca',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AdminColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${rating.toStringAsFixed(1)}★',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AdminColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  final TextAlign align;

  const _TableHeader(this.text, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: AdminColors.textSecondary,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.grey.shade200,
          child: Icon(Icons.person, size: 14, color: Colors.grey.shade400),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status.toUpperCase()) {
      case 'COMPLETED':
        color = const Color(0xFF10B981);
        label = 'Hoàn thành';
        break;
      case 'PENDING':
        color = const Color(0xFFF59E0B);
        label = 'Đang chờ';
        break;
      case 'CONFIRMED':
        color = AdminColors.primary;
        label = 'Đã xác nhận';
        break;
      case 'CANCELED':
      case 'CANCELLED':
        color = const Color(0xFFEF4444);
        label = 'Đã hủy';
        break;
      default:
        color = AdminColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PaginationButton({
    required this.icon,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: AdminColors.borderLight),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AdminColors.textPrimary : AdminColors.textSecondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
