# Hồ sơ Kỹ thuật: OpenIG Failover & HA Lab (MacOS Optimized)

Tài liệu này ghi lại toàn bộ kiến trúc, các quyết định kỹ thuật và quy trình vận hành của dự án OpenIG High Availability (HA).

## 1. Stack Công nghệ (Tech Stack)
- **Gateway**: ForgeRock OpenIG 5.4.0.
- **Web Container**: Apache Tomcat 9.0.65 (JDK 11).
- **Load Balancer**: Nginx 1.29.5.
- **Orchestration**: Docker Compose 3.7+.
- **Scripting**: Groovy 2.4 (OpenIG ScriptableFilter).

## 2. Kiến trúc Hệ thống (Architecture)

### 2.1. Mô hình Hoạt động
- **Kiến trúc**: Active-Active.
- **Luồng dữ liệu**: Client -> Nginx (Port 80) -> OpenIG Node 1/2 (Port 8080).

### 2.2. Cơ chế Failover (Chịu lỗi)
Hệ thống sử dụng **Nginx Layer 7 Load Balancing**:
- **Next Upstream**: Cấu hình `proxy_next_upstream error timeout http_500 http_502`. Khi một node OpenIG gặp sự cố, Nginx tự động chuyển hướng yêu cầu sang node còn lại mà không gây gián đoạn cho Client.
- **Health Checks**: Sử dụng Docker Healthcheck (`curl` vào endpoint 8080) để đảm bảo chỉ các node sẵn sàng mới nhận được tải.

### 2.3. Quản lý Phiên (Session Management) - Chiến lược then chốt
Do hạn chế của Docker for Mac trong việc xử lý lưu lượng Multicast UDP (cần thiết cho Tomcat Cluster chuẩn), hệ thống đã chuyển sang **Stateless Session** dùng **`JwtSession`**:
- **Cơ chế**: Toàn bộ session được mã hóa thành JWT và lưu trữ tại Cookie (`JSESSIONID-JWT`) ở phía Client.
- **Tính nhất quán (Consistency)**: 
    - **Shared KeyStore**: Các node dùng chung một file `keystore.jks` (định dạng PKCS12) chứa cặp khóa RSA 2048-bit.
    - **Shared Secret**: Dùng chung chuỗi Secret để ký HMAC-SHA-256.
- **Kết quả**: Failover diễn ra mượt mà vì bất kỳ node nào cũng có thể giải mã và tiếp tục phiên làm việc từ Cookie của Client.

## 3. Cấu trúc Thư mục & Cấu hình (Project Structure)

```text
.
├── docker-compose.yml          # Định nghĩa Stack với YAML Anchors để chuẩn hóa
├── openig-base/                # Dockerfile và file WAR gốc
├── configs/
│   ├── nginx-lb/               # Cấu hình Nginx (Upstream, Failover logic)
│   ├── openig/                 # Cấu hình Gateway (config.json, routes)
│   │   ├── keystore.jks        # Chìa khóa bảo mật dùng chung
│   │   └── scripts/groovy/     # Logic xử lý session bằng Groovy
│   └── tomcat-nodeX/           # Cấu hình Web Server tối giản
└── docs/                       # Tài liệu hướng dẫn và báo cáo
```

## 4. Các vấn đề kỹ thuật đã xử lý (Bug Fix History)
1. **Lỗi ClassNotFound**: Đã chuyển từ `StaticMembershipInterceptor` sang cấu hình Tomcat chuẩn vì thiếu JAR trong Image.
2. **Lỗi Giải mã JWT**: Khắc phục bằng cách tách `KeyStore` thành đối tượng độc lập trong `heap` của OpenIG thay vì khai báo inline.
3. **Lỗi Promise trong Groovy**: Sửa đổi từ `thenAsync` sang `then` để khớp với kiểu trả về `Response` của script.
4. **Lỗi Nginx 502**: Xử lý bằng cách đồng bộ hóa mạng `bridge` và sử dụng `resolver 127.0.0.11` để tránh cache DNS Docker.

## 5. Hướng phát triển tiếp theo (Next Steps)
1. **Tích hợp Keycloak**: 
    - Cấu hình `ClientRegistration` trong OpenIG.
    - Sử dụng `OAuth2ClientFilter` để bảo vệ các Route.
2. **Quản lý cấu hình tập trung**: Sử dụng các biến môi trường `${env['...']}` trong các file Route JSON để dễ dàng thay đổi ứng dụng đích (e.g., WordPress, eShop).
3. **Auto-scaling**: Nhờ vào cấu hình YAML Anchors trong `docker-compose.yml`, có thể nhân bản thêm các node OpenIG chỉ bằng cách khai báo thêm dịch vụ và trỏ vào template chung.

---
*Tài liệu được cập nhật tự động bởi BMad Master Agent.*
