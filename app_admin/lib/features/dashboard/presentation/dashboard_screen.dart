import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../layout/admin_layout.dart';
import '../data/dto/dashboard_dto.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Date range selection for booking trends
  DateTimeRange? _selectedDateRange;
  String _selectedPeriod = 'week'; // 'week', 'month', 'custom'

  @override
  void initState() {
    super.initState();
    // Initialize with last 7 days
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 6)),
      end: DateTime.now(),
    );
    // Load dashboard data when screen initializes
    Future.microtask(() {
      ref.read(statsControllerProvider.notifier).refresh();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AdminColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AdminColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AdminColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _selectedPeriod = 'custom';
      });
      // TODO: Reload data with new date range
    }
  }

  void _selectPeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      final now = DateTime.now();
      switch (period) {
        case 'week':
          _selectedDateRange = DateTimeRange(
            start: now.subtract(const Duration(days: 6)),
            end: now,
          );
          break;
        case 'month':
          _selectedDateRange = DateTimeRange(
            start: DateTime(now.year, now.month - 1, now.day),
            end: now,
          );
          break;
        case '3months':
          _selectedDateRange = DateTimeRange(
            start: DateTime(now.year, now.month - 3, now.day),
            end: now,
          );
          break;
      }
    });
    // TODO: Reload data with new date range
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(statsControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth < 1200;
    final isMobile = screenWidth < 768;

    return RefreshIndicator(
      onRefresh: () => ref.read(statsControllerProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Heading
            _buildPageHeading(null), // TODO: Add lastUpdated to state

            const SizedBox(height: 32),

            // Loading or Error
            if (dashboardState.isLoading && !dashboardState.hasValue)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (dashboardState.hasError && !dashboardState.hasValue)
              _buildErrorWidget(dashboardState.error.toString())
            else ...[
              // Stats Grid - 6 cards
              _buildStatsGrid(isMobile, isTablet, dashboardState.value),

              const SizedBox(height: 24),

              // Charts Section
              _buildChartsSection(isMobile, dashboardState.value),

              const SizedBox(height: 24),

              // Doctor Performance Table
              _buildDoctorTable(dashboardState.value),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 16,
                color: AdminColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(statsControllerProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeading(DateTime? lastUpdated) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trang Tổng quan',
              style: GoogleFonts.manrope(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AdminColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            if (lastUpdated != null)
              Text(
                'Cập nhật: ${_formatTime(lastUpdated)}',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: AdminColors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$greeting, Admin. Đây là những gì đang diễn ra hôm nay.',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: AdminColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildStatsGrid(bool isMobile, bool isTablet, DashboardDto? data) {
    final stats = [
      _StatData(
        title: 'Tổng bệnh nhân',
        value: _formatNumber(data?.totalPatients ?? 0),
        change: '',
        isPositive: true,
        icon: Icons.person,
        iconBgColor: const Color(0xFFDBEAFE),
        iconColor: AdminColors.primary,
      ),
      _StatData(
        title: 'Tổng bác sĩ',
        value: _formatNumber(data?.totalDoctors ?? 0),
        change: '',
        isPositive: true,
        icon: Icons.medical_services,
        iconBgColor: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF9333EA),
      ),
      _StatData(
        title: 'Chờ xác nhận',
        value: _formatNumber(data?.pendingBookings ?? 0),
        change: '',
        isPositive: false,
        icon: Icons.pending_actions,
        iconBgColor: const Color(0xFFFFEDD5),
        iconColor: const Color(0xFFEA580C),
      ),
      _StatData(
        title: 'Tổng lịch hẹn',
        value: _formatNumber(data?.totalBookings ?? 0),
        change: '',
        isPositive: true,
        icon: Icons.book_online,
        iconBgColor: const Color(0xFFE0E7FF),
        iconColor: const Color(0xFF4F46E5),
      ),
      _StatData(
        title: 'Lịch hôm nay',
        value: _formatNumber(data?.todayBookings ?? 0),
        change: '',
        isPositive: true,
        icon: Icons.today,
        iconBgColor: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF16A34A),
      ),
      _StatData(
        title: 'Hoàn thành',
        value: _formatNumber(data?.completedBookings ?? 0),
        change: '',
        isPositive: true,
        icon: Icons.check_circle,
        iconBgColor: const Color(0xFFD1FAE5),
        iconColor: const Color(0xFF059669),
      ),
    ];

    int crossAxisCount = 6;
    if (isTablet) crossAxisCount = 3;
    if (isMobile) crossAxisCount = 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.3 : 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => _StatCard(data: stats[index]),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}K';
    }
    return number.toString();
  }

  Widget _buildChartsSection(bool isMobile, DashboardDto? data) {
    if (isMobile) {
      return Column(
        children: [
          _buildLineChartCard(data),
          const SizedBox(height: 24),
          _buildDonutChartCard(data),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildLineChartCard(data)),
        const SizedBox(width: 24),
        Expanded(child: _buildDonutChartCard(data)),
      ],
    );
  }

  Widget _buildLineChartCard(DashboardDto? data) {
    // Convert API data to bar chart data
    final bookingsByDay = data?.bookingsByDay ?? [];
    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];
    int totalBookings = 0;
    int maxBooking = 0;

    // Day name mapping
    const dayNameMap = {
      'Mon': 'T2',
      'Tue': 'T3',
      'Wed': 'T4',
      'Thu': 'T5',
      'Fri': 'T6',
      'Sat': 'T7',
      'Sun': 'CN',
    };

    if (bookingsByDay.isNotEmpty) {
      for (int i = 0; i < bookingsByDay.length && i < 7; i++) {
        final count = bookingsByDay[i].count;
        totalBookings += count;
        if (count > maxBooking) maxBooking = count;
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AdminColors.primary,
                    AdminColors.primary.withValues(alpha: 0.7),
                  ],
                ),
                width: 28,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          ),
        );
        // Map English day names to Vietnamese
        final dayLabel = bookingsByDay[i].label;
        labels.add(dayNameMap[dayLabel] ?? dayLabel);
      }
    } else {
      // Default data if no API data
      final defaultData = [
        ('T2', 12),
        ('T3', 8),
        ('T4', 15),
        ('T5', 20),
        ('T6', 18),
        ('T7', 10),
        ('CN', 5),
      ];
      for (int i = 0; i < defaultData.length; i++) {
        final count = defaultData[i].$2;
        totalBookings += count;
        if (count > maxBooking) maxBooking = count;
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AdminColors.primary,
                    AdminColors.primary.withValues(alpha: 0.7),
                  ],
                ),
                width: 28,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          ),
        );
        labels.add(defaultData[i].$1);
      }
    }

    final maxY = maxBooking == 0 ? 20.0 : (maxBooking * 1.3).ceilToDouble();
    final avgPerDay = barGroups.isEmpty
        ? 0
        : (totalBookings / barGroups.length).round();

    // Calculate stats
    final pending = data?.pendingBookings ?? 0;
    final confirmed = data?.confirmedBookings ?? 0;
    final completed = data?.completedBookings ?? 0;
    final cancelled = data?.cancelledBookings ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AdminColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: AdminColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xu hướng đặt lịch',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      Text(
                        '7 ngày gần nhất',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: AdminColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AdminColors.primary.withValues(alpha: 0.1),
                      AdminColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'custom') {
                      _selectDateRange(context);
                    } else {
                      _selectPeriod(value);
                    }
                  },
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    _buildPopupMenuItem(
                      'week',
                      '7 ngày qua',
                      Icons.view_week_rounded,
                    ),
                    _buildPopupMenuItem(
                      'month',
                      '30 ngày qua',
                      Icons.calendar_view_month_rounded,
                    ),
                    _buildPopupMenuItem(
                      '3months',
                      '3 tháng qua',
                      Icons.date_range_rounded,
                    ),
                    const PopupMenuDivider(),
                    _buildPopupMenuItem(
                      'custom',
                      'Chọn ngày...',
                      Icons.edit_calendar_rounded,
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AdminColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getDateRangeText(),
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AdminColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    'Tổng',
                    totalBookings.toString(),
                    Icons.event_note_rounded,
                    AdminColors.primary,
                  ),
                ),
                _buildStatDivider(),
                Expanded(
                  child: _buildMiniStat(
                    'TB/Ngày',
                    avgPerDay.toString(),
                    Icons.show_chart_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
                _buildStatDivider(),
                Expanded(
                  child: _buildMiniStat(
                    'Chờ duyệt',
                    pending.toString(),
                    Icons.pending_actions_rounded,
                    const Color(0xFFF59E0B),
                  ),
                ),
                _buildStatDivider(),
                Expanded(
                  child: _buildMiniStat(
                    'Hoàn thành',
                    completed.toString(),
                    Icons.check_circle_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bar Chart
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AdminColors.textPrimary,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final dayName = groupIndex < labels.length
                          ? labels[groupIndex]
                          : '';
                      return BarTooltipItem(
                        '$dayName\n',
                        GoogleFonts.manrope(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: '${rod.toY.toInt()} lịch hẹn',
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              labels[idx],
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AdminColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: maxY / 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: AdminColors.textSecondary,
                          ),
                        );
                      },
                    ),
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
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AdminColors.borderLight,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Chờ duyệt', const Color(0xFFF59E0B), pending),
              const SizedBox(width: 20),
              _buildLegendItem('Xác nhận', const Color(0xFF3B82F6), confirmed),
              const SizedBox(width: 20),
              _buildLegendItem(
                'Hoàn thành',
                const Color(0xFF10B981),
                completed,
              ),
              const SizedBox(width: 20),
              _buildLegendItem('Hủy', const Color(0xFFEF4444), cancelled),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AdminColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            color: AdminColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AdminColors.borderLight,
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: GoogleFonts.manrope(
            fontSize: 11,
            color: AdminColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getDateRangeText() {
    if (_selectedDateRange == null) return '7 ngày qua';

    switch (_selectedPeriod) {
      case 'week':
        return '7 ngày qua';
      case 'month':
        return '30 ngày qua';
      case '3months':
        return '3 tháng qua';
      case 'custom':
        final start = _selectedDateRange!.start;
        final end = _selectedDateRange!.end;
        return '${start.day}/${start.month} - ${end.day}/${end.month}';
      default:
        return '7 ngày qua';
    }
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    String value,
    String text,
    IconData icon,
  ) {
    final isSelected = _selectedPeriod == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? AdminColors.primary : AdminColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AdminColors.primary : AdminColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(Icons.check_rounded, size: 18, color: AdminColors.primary),
        ],
      ),
    );
  }

  Widget _buildDonutChartCard(DashboardDto? data) {
    // Default colors for pie chart
    final colors = [
      AdminColors.primary,
      const Color(0xFFFACC15),
      const Color(0xFF10B981),
      const Color(0xFFF43F5E),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];

    // Convert API data to chart data
    final popularServices = data?.popularServices ?? [];
    final services = <_ServiceData>[];
    int totalCount = 0;

    if (popularServices.isNotEmpty) {
      for (int i = 0; i < popularServices.length; i++) {
        final s = popularServices[i];
        totalCount += s.bookingCount;
        services.add(
          _ServiceData(s.serviceName, s.percentage, colors[i % colors.length]),
        );
      }
    } else {
      // Default data if no API data
      services.addAll([
        _ServiceData('Nha khoa', 40, AdminColors.primary),
        _ServiceData('Nhi khoa', 25, const Color(0xFFFACC15)),
        _ServiceData('Da liễu', 20, const Color(0xFF10B981)),
        _ServiceData('Khám tổng quát', 15, const Color(0xFFF43F5E)),
      ]);
      totalCount = 2400;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminColors.cardLight,
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
                    'Dịch vụ phổ biến',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tỉ lệ phần trăm theo chuyên khoa',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert,
                  color: AdminColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Donut Chart
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 50,
                          startDegreeOffset: -90,
                          sections: services.map((s) {
                            return PieChartSectionData(
                              color: s.color,
                              value: s.percentage,
                              title: '',
                              radius: 35,
                            );
                          }).toList(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatNumber(totalCount),
                            style: GoogleFonts.manrope(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                          Text(
                            'TỔNG LƯỢT',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AdminColors.textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: services.map((s) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: s.color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                s.name,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AdminColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${s.percentage.toInt()}%',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorTable(DashboardDto? data) {
    // Avatar colors for doctors
    final avatarColors = [
      const Color(0xFFDBEAFE),
      const Color(0xFFFCE7F3),
      const Color(0xFFD1FAE5),
      const Color(0xFFFEF3C7),
      const Color(0xFFE0E7FF),
    ];

    // Map API data to _DoctorData
    final doctors = data?.topDoctors != null && data!.topDoctors!.isNotEmpty
        ? data.topDoctors!.asMap().entries.map((entry) {
            final i = entry.key;
            final d = entry.value;
            return _DoctorData(
              name: d.doctorName,
              specialty: d.specialty ?? 'Chưa cập nhật',
              cases: d.totalBookings,
              rating: d.rating,
              isOnline: true, // TODO: Update backend to return online status
              avatarColor: avatarColors[i % avatarColors.length],
            );
          }).toList()
        : [
            _DoctorData(
              name: 'BS. Nguyễn Văn A',
              specialty: 'Răng Hàm Mặt',
              cases: 124,
              rating: 4.9,
              isOnline: true,
              avatarColor: avatarColors[0],
            ),
            _DoctorData(
              name: 'BS. Trần Thị B',
              specialty: 'Nhi khoa',
              cases: 98,
              rating: 4.8,
              isOnline: true,
              avatarColor: avatarColors[1],
            ),
            _DoctorData(
              name: 'BS. Lê Hoàng C',
              specialty: 'Da liễu',
              cases: 82,
              rating: 4.7,
              isOnline: false,
              avatarColor: avatarColors[2],
            ),
          ];

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thống kê lịch theo bác sĩ',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Top bác sĩ có hiệu suất cao nhất tháng này',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Xem tất cả',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border(
                top: BorderSide(color: AdminColors.borderLight),
                bottom: BorderSide(color: AdminColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'BÁC SĨ',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'CHUYÊN KHOA',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'SỐ CA KHÁM',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'ĐÁNH GIÁ',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'TRẠNG THÁI',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          ...doctors.map((doctor) => _DoctorRow(doctor: doctor)),
        ],
      ),
    );
  }
}

// Data classes
class _StatData {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  _StatData({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class _ServiceData {
  final String name;
  final double percentage;
  final Color color;

  _ServiceData(this.name, this.percentage, this.color);
}

class _DoctorData {
  final String name;
  final String specialty;
  final int cases;
  final double rating;
  final bool isOnline;
  final Color avatarColor;

  _DoctorData({
    required this.name,
    required this.specialty,
    required this.cases,
    required this.rating,
    required this.isOnline,
    required this.avatarColor,
  });
}

// Widgets
class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: data.iconBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(data.icon, color: data.iconColor, size: 16),
              ),
              if (data.change.isNotEmpty && data.change != '0%')
                Text(
                  data.change,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: data.isPositive
                        ? AdminColors.success
                        : AdminColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.title,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AdminColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            data.value,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorRow extends StatelessWidget {
  final _DoctorData doctor;

  const _DoctorRow({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AdminColors.borderLight)),
      ),
      child: Row(
        children: [
          // Doctor Info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: doctor.avatarColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.person,
                    color: AdminColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  doctor.name,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Specialty
          Expanded(
            flex: 2,
            child: Text(
              doctor.specialty,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AdminColors.textSecondary,
              ),
            ),
          ),
          // Cases
          Expanded(
            flex: 1,
            child: Text(
              doctor.cases.toString(),
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AdminColors.textPrimary,
              ),
            ),
          ),
          // Rating
          Expanded(
            flex: 1,
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFACC15), size: 16),
                const SizedBox(width: 4),
                Text(
                  doctor.rating.toString(),
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: doctor.isOnline
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                doctor.isOnline ? 'Đang online' : 'Nghỉ phép',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: doctor.isOnline
                      ? const Color(0xFF15803D)
                      : const Color(0xFF4B5563),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
