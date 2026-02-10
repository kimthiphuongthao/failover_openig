# OpenIG High Availability & Failover Lab

Dự án này thiết lập một môi trường Lab hoàn chỉnh trên Docker để mô phỏng và kiểm chứng khả năng chịu lỗi (Failover) và duy trì phiên làm việc (High Availability) cho OpenIG Gateway.

## 🚀 Điểm nổi bật (Current Status)
- **Kiến trúc Active-Active**: Sử dụng 2 node OpenIG chạy song song.
- **Stateless Session (JWT)**: Vượt qua rào cản mạng Multicast trên MacOS bằng cơ chế JwtSession (Client-side).
- **Shared Security**: Đồng bộ bảo mật giữa các node bằng Shared RSA KeyStore và Shared Secret.
- **Tự động hóa hoàn toàn**: Script kiểm thử và bộ khung Docker chuẩn hóa (YAML Anchors).

## 🏗 Kiến trúc hệ thống
- **Nginx (Load Balancer)**: Đóng vai trò lớp phân phối, tự động phát hiện và chuyển hướng khi một node OpenIG gặp sự cố.
- **OpenIG Nodes (Tomcat 9)**: Chạy OpenIG 5.4.0, được cấu hình để giải mã và duy trì phiên làm việc từ Cookie JWT của người dùng.
- **Shared KeyStore**: Một file `keystore.jks` dùng chung giúp mọi node có cùng "chìa khóa" để phục vụ khách hàng.

## 🛠 Hướng dẫn thiết lập nhanh

1. **Chuẩn bị**: Đảm bảo máy đã cài Docker và Docker Compose.
2. **Khởi động toàn bộ Stack**:
   ```bash
   docker-compose up -d --build
   ```
3. **Kiểm tra trạng thái**:
   Đợi cho đến khi các node báo `healthy` (thường mất khoảng 20-30 giây).
   ```bash
   docker ps
   ```

## 🧪 Quy trình Kiểm thử Failover

### Cách 1: Chạy Script tự động (Khuyến nghị)
Chúng tôi đã cung cấp một script thông minh để giả lập thảm họa và xác nhận kết quả:
```bash
bash test_failover.sh
```
Kết quả thành công sẽ hiển thị thông báo: `SUCCESS: FAILOVER CONFIRMED!`.

### Cách 2: Kiểm thử thủ công (Để Demo)
Xem hướng dẫn chi tiết từng bước (Step-by-step) kèm giải thích log tại:
👉 [Hướng dẫn Trình diễn Failover Thủ công](docs/manual_failover_demo.md)

## 📚 Tài liệu bổ sung
- [Đặc tả Kỹ thuật Chi tiết](docs/PROJECT_TECHNICAL_SPEC.md): Giải thích sâu về Tech Stack, logic xử lý và lịch sử gỡ lỗi.
- [Báo cáo Kết quả](docs/failover_success_report.md): Tổng hợp thành quả đạt được.

## ➡️ Hướng phát triển tiếp theo
- Tích hợp **Keycloak OIDC SSO** để bảo mật Gateway.
- Kết nối với ứng dụng thực tế (**eShop**).
- Quản lý định danh và mật khẩu qua **HashiCorp Vault**.

---
*Dự án được quản lý và vận hành bởi BMad Master Agent (🧙).*