import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../booking/data/dto/booking_dto.dart';

/// Widget biểu đồ xu hướng lịch hẹn với Area Chart
class AppointmentTrendChart extends StatefulWidget {
  final List<BookingDto> appointments;

  const AppointmentTrendChart({super.key, required this.appointments});

  @override
  State<AppointmentTrendChart> createState() => _AppointmentTrendChartState();
}

class _AppointmentTrendChartState extends State<AppointmentTrendChart>
    with SingleTickerProviderStateMixin {
  int _selectedDays = 7; // 7 hoặc 30 ngày
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Màu sắc chính
  static const Color primaryColor = Color(0xFF297EFF);
  static const Color completedColor = Color(0xFF00C853);
  static const Color pendingColor = Color(0xFFFF9800);
  static const Color cancelledColor = Color(0xFFF44336);
  static const Color confirmedColor = Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _calculateChartData();
    final stats = _calculateStats();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6ECF4)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với tiêu đề và bộ lọc
          _buildHeader(stats),
          const SizedBox(height: 8),
          // Tổng số và phần trăm thay đổi
          _buildSummaryRow(stats),
          const SizedBox(height: 24),
          // Legend trạng thái
          _buildLegend(stats),
          const SizedBox(height: 24),
          // Biểu đồ Area Chart
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return _buildChart(data, _animation.value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, int> stats) {
    final totalCurrent = stats['total'] ?? 0;
    final changePercent = _calculateChangePercent();
    final isPositive = changePercent >= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Xu hướng lịch hẹn',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0C131D),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge phần trăm thay đổi
            if (totalCurrent > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? completedColor : cancelledColor)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 12,
                      color: isPositive ? completedColor : cancelledColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${changePercent.abs().toStringAsFixed(0)}%',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? completedColor : cancelledColor,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 6),
            // Bộ chọn thời gian
            _buildTimeFilter(),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeFilter() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_buildFilterButton(7, '7N'), _buildFilterButton(30, '30N')],
      ),
    );
  }

  Widget _buildFilterButton(int days, String label) {
    final isSelected = _selectedDays == days;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDays = days;
          _animationController.reset();
          _animationController.forward();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(Map<String, int> stats) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '${stats['total']}',
          style: GoogleFonts.manrope(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'lịch hẹn trong $_selectedDays ngày qua',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(Map<String, int> stats) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem('Hoàn thành', completedColor, stats['completed'] ?? 0),
        _legendItem('Đã xác nhận', confirmedColor, stats['confirmed'] ?? 0),
        _legendItem('Chờ xác nhận', pendingColor, stats['pending'] ?? 0),
        _legendItem('Đã hủy', cancelledColor, stats['cancelled'] ?? 0),
      ],
    );
  }

  Widget _legendItem(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          '$count',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<_DayData> data, double animationValue) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Chưa có dữ liệu trong khoảng thời gian này',
          style: GoogleFonts.manrope(color: Colors.grey),
        ),
      );
    }

    final maxY = data
        .map((d) => d.total.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final adjustedMaxY = (maxY * 1.3).clamp(5.0, double.infinity);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: adjustedMaxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: adjustedMaxY / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                // Hiển thị label mỗi vài ngày để tránh chồng chéo
                final showInterval = _selectedDays > 7 ? 5 : 1;
                if (idx % showInterval != 0 && idx != data.length - 1) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data[idx].label,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: adjustedMaxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => const Color(0xFF0C131D),
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final idx = spot.x.toInt();
                if (idx < 0 || idx >= data.length) return null;
                final dayData = data[idx];
                return LineTooltipItem(
                  '${dayData.fullDate}\n',
                  GoogleFonts.manrope(color: Colors.white70, fontSize: 11),
                  children: [
                    TextSpan(
                      text: '${dayData.total} lịch hẹn',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              final animatedY = entry.value.total * animationValue;
              return FlSpot(entry.key.toDouble(), animatedY);
            }).toList(),
            isCurved: true,
            curveSmoothness: 0.35,
            color: primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2.5,
                  strokeColor: primaryColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryColor.withOpacity(0.3),
                  primaryColor.withOpacity(0.05),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 250),
    );
  }

  List<_DayData> _calculateChartData() {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _selectedDays - 1));
    final List<_DayData> result = [];

    for (int i = 0; i < _selectedDays; i++) {
      final date = startDate.add(Duration(days: i));
      final count = widget.appointments.where((a) {
        if (a.timeSlot == null) return false;
        final aDate = a.timeSlot!.date;
        return aDate.year == date.year &&
            aDate.month == date.month &&
            aDate.day == date.day;
      }).length;

      String label;
      if (_selectedDays <= 7) {
        // Hiển thị thứ (T2, T3, ...)
        final weekday = date.weekday;
        final dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
        label = dayNames[weekday - 1];
      } else {
        // Hiển thị ngày/tháng
        label = DateFormat('dd/MM').format(date);
      }

      result.add(
        _DayData(
          date: date,
          label: label,
          fullDate: DateFormat('EEEE, dd/MM', 'vi').format(date),
          total: count,
        ),
      );
    }

    return result;
  }

  Map<String, int> _calculateStats() {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _selectedDays - 1));

    final filtered = widget.appointments.where((a) {
      if (a.timeSlot == null) return false;
      final aDate = a.timeSlot!.date;
      return aDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          aDate.isBefore(now.add(const Duration(days: 1)));
    }).toList();

    return {
      'total': filtered.length,
      'completed': filtered.where((a) => a.status == 'COMPLETED').length,
      'confirmed': filtered.where((a) => a.status == 'CONFIRMED').length,
      'pending': filtered.where((a) => a.status == 'PENDING').length,
      'cancelled': filtered.where((a) => a.status == 'CANCELED').length,
    };
  }

  double _calculateChangePercent() {
    final now = DateTime.now();

    // Khoảng thời gian hiện tại
    final currentStart = now.subtract(Duration(days: _selectedDays - 1));
    final currentCount = widget.appointments.where((a) {
      if (a.timeSlot == null) return false;
      final aDate = a.timeSlot!.date;
      return aDate.isAfter(currentStart.subtract(const Duration(days: 1))) &&
          aDate.isBefore(now.add(const Duration(days: 1)));
    }).length;

    // Khoảng thời gian trước đó
    final previousStart = currentStart.subtract(Duration(days: _selectedDays));
    final previousEnd = currentStart.subtract(const Duration(days: 1));
    final previousCount = widget.appointments.where((a) {
      if (a.timeSlot == null) return false;
      final aDate = a.timeSlot!.date;
      return aDate.isAfter(previousStart.subtract(const Duration(days: 1))) &&
          aDate.isBefore(previousEnd.add(const Duration(days: 1)));
    }).length;

    if (previousCount == 0) return currentCount > 0 ? 100.0 : 0.0;
    return ((currentCount - previousCount) / previousCount * 100);
  }
}

class _DayData {
  final DateTime date;
  final String label;
  final String fullDate;
  final int total;

  _DayData({
    required this.date,
    required this.label,
    required this.fullDate,
    required this.total,
  });
}
