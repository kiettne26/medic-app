Tên đề tài: "Xây dựng hệ thống đặt lịch khám và tư vấn trực tuyến đa nền tảng"

Các chức năng cần có:
1. Đăng nhập, đăng ký (xác thực JWT + refresh Token)
2. Quản lý hồ sơ người dùng:
+ Cập nhật thông tin cá nhân
+ Ảnh đại diện
+ Lịch sử đặt lịch
+ Quản lý danh sách lịch đã đặt
3. Quản lý dịch vụ khám / tư vấn
(Admin – Web)
Thêm / sửa / xóa dịch vụ:
Khám tổng quát
Tư vấn dinh dưỡng
Tư vấn tâm lý
4. Quản lý bác sĩ / nhân viên tư vấn
(Admin)
Thêm tài khoản bác sĩ
Cập nhật thông tin chuyên môn
Gán dịch vụ cho bác sĩ
5. QUẢN LÝ LỊCH LÀM VIỆC (STAFF/DOCTOR)
Thiết lập giờ làm việc:
Ca sáng / chiều
Ngày nghỉ
Sinh tự động các slot trống
6. Đặt lịch (Chức năng quan trọng nhất)
6.1 Xem lịch trống
Người dùng có thể:
Chọn:
Dịch vụ
Bác sĩ
Ngày
Hệ thống hiển thị các khung giờ còn trống
6.2 Đặt lịch khám (CORE)
Người dùng thực hiện:
Chọn bác sĩ
Chọn dịch vụ
Chọn thời gian
Gửi yêu cầu đặt lịch
🔐 XỬ LÝ KỸ THUẬT BẮT BUỘC
Transaction
Pessimistic Lock
Chống race condition
Không cho phép double booking
Quy tắc:
Một bác sĩ – tại một thời điểm – chỉ có một bệnh nhân
6.3 Quản lý lịch của người dùng
Xem danh sách lịch đã đặt
Xem chi tiết lịch
Hủy lịch
Đổi lịch (nếu được phép)
7. Xử lý lịch phía bác sĩ (Web)
Xem danh sách bệnh nhân trong ngày
Xác nhận lịch
Từ chối lịch
Đánh dấu “đã hoàn thành”
8. Realtime
Spring Boot WebSocket
Flutter Socket client
9. Thông báo tự động
Gửi email khi:
Đặt lịch thành công
Lịch bị hủy
Lịch được xác nhận
Nhắc lịch trước X giờ
10. Dashboard thống kê (Admin)
Tổng số lịch theo:
Ngày / tuần / tháng
Thống kê:
Bác sĩ nhiều lịch nhất
Dịch vụ phổ biến
Biểu đồ:
Bar chart
Line chart
Pie chart
11. Quản lý trạng thái lịch
Trạng thái booking:
PENDING
CONFIRMED
COMPLETED
CANCELED
Có lịch sử thay đổi trạng thái
12. Swagger API Documentation
Toàn bộ API có Swagger
Test trực tiếp trên Swagger UI
13. Microservices Architecture
Tách backend thành:
API Gateway
Auth Service
Booking Service
Notification Service
Analytics Service
👉 Thể hiện kiến trúc hiện đại
14. Audit Log
Ghi lại toàn bộ:
Ai đặt lịch
Ai hủy
Thời gian nào
Truy vết thao tác
15. Gợi ý lịch thông minh
Gợi ý giờ ít người đặt
Đề xuất bác sĩ phù hợp
16. Đánh giá bác sĩ
Sau khi hoàn thành lịch:
Rating
Comment
17. Export báo cáo
Xuất:
PDF
Excel

YÊU CẦU KỸ THUẬT PHẢI CÓ:
Spring Boot RESTful API
JWT Security
Transaction + Lock
WebSocket
Database chuẩn hóa
Swagger
Clean Architecture Flutter