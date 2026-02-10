# OpenIG Failover Lab Report (MacOS/Docker Environment)

## 1. Mục tiêu (Objective)
Thiết lập môi trường Lab Docker để kiểm thử khả năng Failover (chịu lỗi) và sao chép phiên làm việc (Session Replication) của OpenIG 5.4.0 chạy trên nền Tomcat 9.

## 2. Thách thức và Vấn đề (Challenges & Issues)
Quá trình triển khai gặp nhiều trở ngại đặc thù của môi trường MacOS và phiên bản OpenIG cũ:
- **Lỗi Multicast trên Mac**: Mạng Docker Bridge trên MacOS không hỗ trợ tốt Multicast UDP, khiến Tomcat Cluster mặc định không thể đồng bộ dữ liệu session.
- **Lỗi Thư viện (ClassNotFound)**: Một số class Tribes nâng cao cho Unicast (Static Membership) không có sẵn trong Image Tomcat tiêu chuẩn.
- **Lỗi Cấu hình OpenIG**: Các vấn đề về FQCN (Fully Qualified Class Names), nạp Groovy script từ file, và cơ chế Promise không đồng bộ.
- **Lỗi Mã hóa JWT**: OpenIG mặc định dùng khóa RSA tạm thời cho mỗi node, khiến các node không thể giải mã Cookie của nhau.

## 3. Giải pháp Cuối cùng (Final Solution)
Thay vì cố gắng sửa lỗi Multicast, hệ thống đã chuyển sang sử dụng **JwtSession** (Client-side session) kết hợp với **Shared KeyStore**:
- **Cơ chế**: Toàn bộ dữ liệu session được mã hóa và lưu trong Cookie của trình duyệt (Client-side).
- **Đồng bộ hóa**: 
    - **Shared Secret**: Dùng chung chuỗi Secret cho chữ ký HMAC-SHA-256.
    - **Shared KeyStore (PKCS12)**: Chứa cặp khóa RSA dùng chung để mã hóa/giải mã nội dung JWT.
- **Cấu hình**: Tách KeyStore thành đối tượng độc lập trong `heap` của `config.json` và tham chiếu từ `JwtSession`.

## 4. Kết quả Kiểm thử (Test Results)
Script `test_failover.sh` thực hiện các bước:
1. Gửi request đến Nginx Load Balancer -> Node A phản hồi, tạo Session JWT.
2. Dừng Node A (Stop container).
3. Gửi request tiếp theo kèm Cookie JWT -> Nginx chuyển hướng sang Node B.
4. **Kết quả**: Node B giải mã thành công JWT và tiếp tục phiên làm việc với dữ liệu từ Node A.
   - **Status**: `SUCCESS: FAILOVER CONFIRMED!`
   - **Header**: `X-Session-Status: RESUMED_FROM_initial-nodeX`

## 5. Cấu hình Quan trọng (Key Configuration Artifacts)
- **OpenIG**: `configs/openig/config.json`, `configs/openig/routes/01-session-test.json`.
- **Tomcat**: `configs/tomcat-nodeX/server.xml`, `configs/tomcat-nodeX/ROOT.xml`.
- **Docker**: `docker-compose.yml` (mount volume cho config, scripts, và keystore).

---
*Báo cáo được tổng hợp bởi BMad Master Agent.*
