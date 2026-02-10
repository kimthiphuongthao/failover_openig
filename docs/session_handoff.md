# Session Handoff: OpenIG SSO Integration

## 1. Trạng thái Dự án (Current Status)
- **Giai đoạn**: Đã hoàn thành HA/Failover Lab. Đang bắt đầu tích hợp Keycloak SSO.
- **Nhánh Git hiện tại**: `feature/keycloak-sso`.
- **Thành tựu**: Failover chạy hoàn hảo trên MacOS bằng `JwtSession` và `Shared KeyStore`.

## 2. Thông số Kỹ thuật quan trọng (Technical Specs)
- **Shared Secret (JWT Signing)**: `Ym1hZC1zZXNzaW9uLXJlcGxpY2F0aW9uLXNlY3JldC1rZXk=`
- **KeyStore**: `configs/openig/keystore.jks` (Định dạng PKCS12, Alias: `session-key`, Pass: `changeit`).
- **Keycloak Client**: `openig-eshop-client`
- **Keycloak Secret**: `g2xnS39Eil4MN5T6zJ8wvEerjPgtfBMo`
- **Logic Routing**: `configs/openig/routes/01-session-test.json` đang ép buộc sử dụng `JwtSession`.

## 3. Cạm bẫy cần lưu ý (MacOS/Docker Gotchas)
- **Multicast**: Không dùng được trên Mac. Phải duy trì `JwtSession`.
- **Rename File**: Git trên Mac không phân biệt hoa/thường, nếu đổi tên file phải dùng `git mv` cưỡng bức.
- **Promise**: Trong Groovy OpenIG 5.4, dùng `.then { ... }` thay vì `.thenAsync` nếu trả về đối tượng `Response` trực tiếp.

## 4. Việc cần làm tiếp theo (Next Tasks)
1. Cập nhật `docker-compose.yml` để thêm service **Keycloak** (sử dụng image `quay.io/keycloak/keycloak:24.0.3`).
2. Cấu hình OpenIG `config.json` để thêm `ClientRegistration` trỏ đến Keycloak.
3. Tạo Route mới `02-sso-keycloak.json` để bảo vệ tài nguyên bằng `OAuth2ClientFilter`.
4. Thực hiện đăng nhập và test Failover ngay trong lúc đang có session SSO.

---
*Tài liệu bàn giao được lập bởi BMad Master (🧙) cho Duykim.*
