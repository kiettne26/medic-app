import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorsScreen extends ConsumerStatefulWidget {
  const DoctorsScreen({super.key});

  @override
  ConsumerState<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends ConsumerState<DoctorsScreen> {
  final _searchController = TextEditingController();

  // Mock data - sẽ thay bằng API thực
  final List<Map<String, dynamic>> _doctors = [
    {
      'id': '1',
      'name': 'BS. Trần Thị B',
      'email': 'tran.b@hospital.com',
      'specialty': 'Nội khoa',
      'experience': 10,
      'rating': 4.8,
      'totalBookings': 156,
      'active': true,
    },
    {
      'id': '2',
      'name': 'BS. Phạm Văn D',
      'email': 'pham.d@hospital.com',
      'specialty': 'Dinh dưỡng',
      'experience': 8,
      'rating': 4.6,
      'totalBookings': 124,
      'active': true,
    },
    {
      'id': '3',
      'name': 'BS. Nguyễn Văn F',
      'email': 'nguyen.f@hospital.com',
      'specialty': 'Tâm lý',
      'experience': 12,
      'rating': 4.9,
      'totalBookings': 89,
      'active': true,
    },
    {
      'id': '4',
      'name': 'BS. Lê Thị G',
      'email': 'le.g@hospital.com',
      'specialty': 'Tim mạch',
      'experience': 15,
      'rating': 4.7,
      'totalBookings': 201,
      'active': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Bar
          Row(
            children: [
              // Search
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm bác sĩ...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Add Button
              ElevatedButton.icon(
                onPressed: () => _showDoctorDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Thêm bác sĩ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3949AB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Doctors Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.4,
              ),
              itemCount: _doctors.length,
              itemBuilder: (context, index) {
                return _DoctorCard(
                  doctor: _doctors[index],
                  onEdit: () => _showDoctorDialog(context, _doctors[index]),
                  onToggle: () {
                    setState(() {
                      _doctors[index]['active'] = !_doctors[index]['active'];
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDoctorDialog(BuildContext context, [Map<String, dynamic>? doctor]) {
    final isEdit = doctor != null;
    final nameController = TextEditingController(text: doctor?['name'] ?? '');
    final emailController = TextEditingController(text: doctor?['email'] ?? '');
    final specialtyController = TextEditingController(
      text: doctor?['specialty'] ?? '',
    );
    final experienceController = TextEditingController(
      text: doctor?['experience']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEdit ? 'Chỉnh sửa bác sĩ' : 'Thêm bác sĩ mới',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ tên',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: specialtyController,
                      decoration: const InputDecoration(
                        labelText: 'Chuyên khoa',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: experienceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kinh nghiệm (năm)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              if (!isEdit) ...[
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Save doctor via API
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3949AB),
              foregroundColor: Colors.white,
            ),
            child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _DoctorCard({
    required this.doctor,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = doctor['active'] as bool;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF3949AB).withValues(alpha: 0.1),
                child: Text(
                  doctor['name'].toString().split(' ').last[0],
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3949AB),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name & Specialty
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name'],
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        doctor['specialty'],
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00897B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Status toggle
              Switch(
                value: isActive,
                onChanged: (_) => onToggle(),
                activeColor: const Color(0xFF3949AB),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              _StatItem(
                icon: Icons.star,
                value: doctor['rating'].toString(),
                label: 'Đánh giá',
                color: Colors.amber,
              ),
              const SizedBox(width: 16),
              _StatItem(
                icon: Icons.calendar_today,
                value: doctor['totalBookings'].toString(),
                label: 'Lịch hẹn',
                color: const Color(0xFF3949AB),
              ),
              const SizedBox(width: 16),
              _StatItem(
                icon: Icons.work,
                value: '${doctor['experience']} năm',
                label: 'Kinh nghiệm',
                color: const Color(0xFF7B1FA2),
              ),
            ],
          ),

          const Spacer(),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Chỉnh sửa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3949AB),
                    side: const BorderSide(color: Color(0xFF3949AB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.manrope(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
