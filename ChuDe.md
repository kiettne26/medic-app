Xây dựng hệ thống đặt lịch khám và tư vấn trực tuyến đa nền tảng
 1. Mục tiêu hệ thống
Hệ thống được xây dựng nhằm hỗ trợ người dùng đặt lịch khám và tư vấn trực tuyến, giúp kết nối bệnh nhân với bác sĩ một cách thuận tiện, đồng thời hỗ trợ quản trị viên quản lý dịch vụ, bác sĩ và lịch khám một cách hiệu quả trên nền tảng web và ứng dụng di động.
 2. Phân quyền người dùng
Hệ thống gồm 3 vai trò chính:
Patient (Bệnh nhân): đặt lịch, quản lý lịch khám, đánh giá bác sĩ
Doctor (Bác sĩ / Nhân viên tư vấn): quản lý lịch làm việc, xử lý lịch hẹn
Admin (Quản trị viên): quản lý hệ thống, dịch vụ, bác sĩ và thống kê
 3. Chức năng hệ thống
 3.1. Xác thực và phân quyền
Đăng ký, đăng nhập người dùng
Xác thực bằng JWT và Refresh Token
Phân quyền truy cập theo vai trò (Admin, Doctor, Patient)
 3.2. Quản lý hồ sơ người dùng
Người dùng có thể:
Cập nhật thông tin cá nhân
Quản lý ảnh đại diện
Xem lịch sử đặt lịch
Quản lý danh sách lịch đã đặt
 3.3. Quản lý dịch vụ khám và tư vấn (Admin)
Quản trị viên có thể:
Thêm, sửa, xóa dịch vụ
Quản lý thông tin dịch vụ như giá, thời lượng, mô tả
Ví dụ dịch vụ:
Khám tổng quát
Tư vấn dinh dưỡng
Tư vấn tâm lý
 3.4. Quản lý bác sĩ và nhân viên tư vấn (Admin)
Quản trị viên có thể:
Tạo tài khoản bác sĩ
Cập nhật thông tin chuyên môn (chuyên khoa, kinh nghiệm)
Gán dịch vụ cho bác sĩ
 3.5. Quản lý lịch làm việc của bác sĩ
Bác sĩ có thể:
Thiết lập khung giờ làm việc (ca sáng, ca chiều)
Cấu hình ngày nghỉ
Hệ thống tự động sinh các khung giờ trống (time slots)
 3.6. Hệ thống đặt lịch khám (Chức năng cốt lõi)
3.6.1. Xem lịch trống
Người dùng có thể chọn:
Dịch vụ
Bác sĩ
Ngày khám
Hệ thống hiển thị các khung giờ còn trống tương ứng.
3.6.2. Đặt lịch khám
Người dùng thực hiện:
Chọn bác sĩ
Chọn dịch vụ
Chọn thời gian
Gửi yêu cầu đặt lịch
 Xử lý kỹ thuật bắt buộc
Transaction quản lý giao dịch
Pessimistic Lock để khóa khung giờ
Chống race condition
Ngăn chặn double booking
Quy tắc nghiệp vụ:
Một bác sĩ tại một thời điểm chỉ được khám cho một bệnh nhân.
3.6.3. Quản lý lịch của người dùng
Xem danh sách lịch đã đặt
Xem chi tiết lịch
Hủy lịch
Đổi lịch (nếu được phép)
 3.7. Xử lý lịch phía bác sĩ
Bác sĩ có thể:
Xem danh sách bệnh nhân trong ngày
Xác nhận hoặc từ chối lịch hẹn
Đánh dấu lịch đã hoàn thành
 3.8. Cập nhật dữ liệu thời gian thực
Sử dụng Spring Boot WebSocket phía backend
Flutter Socket client phía mobile
Cập nhật trạng thái lịch và thông báo realtime

 3.9. Thông báo tự động
Hệ thống gửi email khi:
Đặt lịch thành công
Lịch bị hủy
Lịch được xác nhận
Nhắc lịch trước thời điểm khám X giờ
 3.10. Dashboard thống kê (Admin)
Hiển thị thống kê:
Tổng số lịch theo ngày / tuần / tháng
Bác sĩ có nhiều lịch nhất
Dịch vụ phổ biến nhất
Biểu đồ:
Biểu đồ cột (Bar chart)
Biểu đồ đường (Line chart)
Biểu đồ tròn (Pie chart)
 3.11. Quản lý trạng thái lịch hẹn
Các trạng thái:
PENDING
CONFIRMED
COMPLETED
CANCELED
Lưu lịch sử thay đổi trạng thái của từng lịch hẹn.
 3.12. Tài liệu hóa API
Tích hợp Swagger OpenAPI
Kiểm thử API trực tiếp trên Swagger UI
 3.13. Ghi nhật ký hệ thống (Audit Log)
Hệ thống ghi lại:
Người thực hiện thao tác
Hành động (đặt lịch, hủy lịch, cập nhật)
Thời gian thao tác
Thông tin chi tiết
 3.14. Đánh giá bác sĩ
Sau khi hoàn thành lịch:
Người dùng có thể đánh giá (rating)
Viết nhận xét (comment)
 3.15. Xuất báo cáo
Xuất báo cáo lịch khám và thống kê ra Excel hoặc PDF
 4. Yêu cầu kỹ thuật
Backend: Spring Boot RESTful API
Bảo mật: JWT Authentication + Refresh Token
Xử lý đồng thời: Transaction và Pessimistic Lock
Realtime: WebSocket
Cơ sở dữ liệu: PostgreSQL chuẩn hóa (supabase)
Tài liệu API: Swagger OpenAPI
Mobile App: Flutter theo Clean Architecture
 5. Hướng phát triển (Future Work)
Thiết kế hệ thống theo kiến trúc hướng microservices (API Gateway, Auth Service, Booking Service, Notification Service, Analytics Service)
Gợi ý lịch thông minh dựa trên dữ liệu lịch sử và mức độ ưu tiên của bác sĩ
Tích hợp AI hỗ trợ đề xuất bác sĩ phù hợp