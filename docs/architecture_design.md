# Kiến trúc Thiết kế OpenIG Failover Lab

## 1. Tổng quan (Executive Summary)
Hệ thống được thiết kế để cung cấp khả năng chịu lỗi (High Availability) cho OpenIG Gateway bằng cách sử dụng kiến trúc cân bằng tải kết hợp với cơ chế lưu trữ phiên làm việc phía Client (Client-side Session).

## 2. Các cấu phần hệ thống (Components)

### 2.1. Nginx Load Balancer
- **Vai trò**: Cửa ngõ duy nhất tiếp nhận request từ người dùng. Thực hiện phân phối tải và phát hiện node chết.
- **Cấu hình then chốt**:
    - `upstream`: Định nghĩa nhóm các node OpenIG.
    - `proxy_next_upstream`: Tự động thử node tiếp theo nếu node hiện tại trả về lỗi (500, 502, timeout).
    - `max_fails` & `fail_timeout`: Đánh dấu node "unhealthy" một cách linh hoạt.

### 2.2. OpenIG Gateway Nodes (Node 1 & Node 2)
- **Vai trò**: Xử lý logic Gateway, thực thi các Filter/Handler và quản lý phiên làm việc.
- **Công nghệ**: OpenIG 5.4.0 chạy trên Apache Tomcat 9.
- **Cấu hình then chốt**:
    - `JwtSession`: Chuyển đổi từ session bộ nhớ sang session mã hóa trong Cookie.
    - `SharedKeyStore`: Sử dụng chung cặp khóa RSA (PKCS12) để đảm bảo mọi node đều có thể giải mã cùng một Cookie.
    - `SharedSecret`: Đảm bảo tính toàn vẹn của chữ ký số trên toàn cụm.

### 2.3. Tomcat Container
- **Vai trò**: Runtime môi trường cho OpenIG.
- **Cấu hình**: Đã tối giản hóa (Standard Server), loại bỏ nhu cầu Cluster mạng phức tạp để tối ưu hiệu suất và độ ổn định trên MacOS.

## 3. Công nghệ sử dụng (Tech Stack)
- **Containerization**: Docker & Docker Compose.
- **Gateway**: ForgeRock OpenIG 5.4.0.
- **Web Server**: Apache Tomcat 9.0.65.
- **Proxy/LB**: Nginx 1.29.5.
- **Security**: RSA 2048-bit Encryption, HMAC-SHA-256 Signing.

## 4. Workflow & Mapping (Dẫn chứng tài liệu gốc)

| Workflow | Giải pháp triển khai | Mapping với consolidated_report.md |
| :--- | :--- | :--- |
| **Phát hiện lỗi** | Nginx `proxy_next_upstream` | *"routing around any servers that become unavailable"* |
| **Sao chép phiên** | `JwtSession` (Client-side) | *"You can opt to store session data on the user-agent instead... see JwtSession"* |
| **Bảo mật phiên** | Shared Secret & RSA KeyStore | *"be sure to share the encryption keys across all servers"* |
| **Tính dính (Stickiness)** | Không bắt buộc (do session nằm ở client) | *"Session stickiness helps... but session replication helps when one server fails"* |

---
*Tài liệu được soạn thảo bởi BMad Master Agent (🧙).*
