import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String _userName = 'Người dùng';
  String _userAvatar = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final name = await _storage.read(key: 'user_name');
    final avatar = await _storage.read(key: 'user_avatar');
    if (mounted) {
      setState(() {
        _userName = name ?? 'Người dùng';
        _userAvatar = avatar ?? '';
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8), // background-light
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildUpcomingScheduleCard(),
              _buildServiceCategoryList(),
              _buildFeaturedDoctorsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF297EFF).withOpacity(0.2), // primary/20
                width: 2,
              ),
              image: _userAvatar.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(_userAvatar),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _userAvatar.isEmpty
                ? const Icon(Icons.person, color: Color(0xFF297EFF), size: 28)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào,',
                  style: TextStyle(
                    color: Color(0xFF5E718D),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_getGreeting()}, $_userName!',
                  style: const TextStyle(
                    color: Color(0xFF101418),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF101418),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F2F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: const Icon(Icons.search, color: Color(0xFF5E718D)),
            ),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bác sĩ, chuyên khoa...',
                  hintStyle: TextStyle(
                    color: Color(0xFF5E718D),
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  fillColor: Color(0xFFF0F2F5),
                  filled: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingScheduleCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF297EFF), // primary
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF297EFF).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'LỊCH HẸN SẮP TỚI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853), // accent-green
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'SẮP DIỄN RA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '15 Th05, 2024',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '09:00 AM • BS. Trần Viết An',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF297EFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Chi tiết',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.directions_car, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCategoryList() {
    final services = [
      {
        'icon': Icons.medical_services,
        'label': 'Đa khoa',
        'color': Colors.blue,
      },
      {'icon': Icons.monitor_heart, 'label': 'Tim mạch', 'color': Colors.red},
      {'icon': Icons.child_care, 'label': 'Nhi khoa', 'color': Colors.green},
      {
        'icon': Icons.medical_information,
        'label': 'Răng hàm',
        'color': Colors.orange,
      },
      {'icon': Icons.visibility, 'label': 'Mắt', 'color': Colors.purple},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dịch vụ chuyên khoa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101418),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Tất cả',
                  style: TextStyle(
                    color: Color(0xFF297EFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final service = services[index];
              return Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: (service['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      service['icon'] as IconData,
                      color: service['color'] as Color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service['label'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101418),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedDoctorsList() {
    final doctors = [
      {
        'name': 'BS. Nguyễn Văn A',
        'specialty': 'Chuyên gia Tim mạch',
        'rating': 4.9,
        'reviews': 120,
        'status': 'Sẵn sàng ngay hôm nay',
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDoyIsIJyatB1_0E6ySutFFi91vaZKaQ5E-s3eMOVC0zeVtMZvSkTF8MpNK8JnFVvZYmojIDeTa1utgpooP60DGNANPLwRcRmOwN2PRm_yqw1y_MUhLykS46b9vSDvNPqngRIyi_53lluddd8jC_wtnOsAEzNdir-DFwTB514uayReHHOq5xlZveUVSur5-WrRzmrGdcwScEMsxrIOgJ2fD2DS1QJ2Zk4RQUkKE5ipE_N0ttQen-s9XWKVzFQyVbAUVD1fkiyPOhBk',
      },
      {
        'name': 'BS. Lê Thị B',
        'specialty': 'Chuyên gia Nhi khoa',
        'rating': 4.8,
        'reviews': 85,
        'status': 'Lịch trống ngày mai',
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDETy1IIeH76dXfaKcB36D9XlRmnmM4TBYGQ6W_hbTJ2gCX7QlZ17CT44G3AZtSVO5Mlow4RTW5qZQRDlkdjviBxTE4d3GanQTzTZ8SqXDkjiQHmJNeuDzQA81jYCj3wKDfIXL2C3TR62vJGZrdotOJGSEBNQwWcfRNAF_MH6QNpnSdGuqknCr5cLX_Yn3v-b_hXTS5BTBNZkACFHv30Is9Evre_Hm6ghnMB88Wdjf4hMzbQUEdywlqTYeaAdvARmBrwc1bg01iuKE',
      },
      {
        'name': 'BS. Phạm Minh C',
        'specialty': 'Chuyên gia Da liễu',
        'rating': 5.0,
        'reviews': 210,
        'status': 'Sẵn sàng ngay hôm nay',
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuB64WAZsXdZv7yM8-s5H7HxXyqUoLeOI5Gpk6qLbeICEzYdwfykWnXoNqEu8-09EkhYCePcPSlb4iKT-ES6Lmyad6Znbz4M2r0xP5iBwopeHoS-ko4wzVRAClbMcQLE_Bs-qYaOodyz5wEYueWFSjxFNOaWvMvhatYs8dLG5xrm-swEYeuzyrl445mGzed7hIhbeWMktD3CUu5AQ5mWzbquaEZSDNWm8sXDvFJk1kIva954uro-viTEgfW6SFk4dzP84B5a8tD8e3k',
      },
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bác sĩ nổi bật',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101418),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Xem thêm',
                  style: TextStyle(
                    color: Color(0xFF297EFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: doctors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(doctor['image'] as String),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor['specialty'] as String,
                          style: const TextStyle(
                            color: Color(0xFF297EFF),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor['name'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101418),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${doctor['rating']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${doctor['reviews']} đánh giá)',
                              style: const TextStyle(
                                color: Color(0xFF5E718D),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00C853),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              doctor['status'] as String,
                              style: const TextStyle(
                                color: Color(0xFF5E718D),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF297EFF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF297EFF),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
