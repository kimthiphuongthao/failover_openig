# Phân tích Kỹ thuật Chuyên sâu: Cơ chế HA & Failover OpenIG

Tài liệu này giải thích cách hệ thống đạt được khả năng tự động chuyển đổi (Switching) và duy trì trạng thái (Persistence) dựa trên các Module lõi của OpenIG.

---

## 1. Cơ chế Tự động Chuyển đổi (Networking Failover)

**Giải pháp**: Sử dụng Nginx làm bộ điều phối chịu lỗi.
- **Tính năng**: `proxy_next_upstream`.
- **Cấu hình**: `configs/nginx-lb/nginx.conf`.
- **Nguyên lý**: Khi Nginx gửi request đến Node A và nhận được lỗi kết nối hoặc lỗi 5xx, nó sẽ không báo lỗi cho Client mà lập tức thử Node B. Điều này giúp quá trình switching diễn ra hoàn toàn trong suốt.

---

## 2. Cơ chế Duy trì Phiên làm việc (Session Persistence)

Đây là phần quan trọng nhất, giúp người dùng không phải đăng nhập lại khi Switch xảy ra.

### 2.1. Module JwtSession
- **Tính năng**: Stateless Session. Thay vì lưu session trong bộ nhớ server (HttpSession), OpenIG đóng gói toàn bộ session vào một JWT (JSON Web Token) mã hóa.
- **Mapping Mã nguồn OpenIG**:
    - **Module**: `openig-core`
    - **Class**: `org.forgerock.openig.jwt.JwtSessionManager`
    - **File vật lý**: `OpenIG/openig-core/src/main/java/org/forgerock/openig/jwt/JwtSessionManager.java`
- **Tác dụng**: Giúp biến OpenIG thành một Gateway "không trạng thái" (Stateless). Dữ liệu đi theo người dùng dưới dạng Cookie.

### 2.2. Module KeyStore (Bảo mật hợp nhất)
- **Tính năng**: Shared Security Context.
- **Mapping Mã nguồn OpenIG**:
    - **Module**: `openig-core`
    - **Class**: `org.forgerock.openig.security.KeyStoreHeaplet`
    - **File vật lý**: `OpenIG/openig-core/src/main/java/org/forgerock/openig/security/KeyStoreHeaplet.java`
- **Tác dụng**: Cho phép định nghĩa một kho khóa (Keystore) dùng chung. Nhờ lớp này, cả hai node OpenIG mới có thể nạp cùng một cặp khóa RSA để giải mã Cookie JWT của nhau.

---

## 3. Logic xử lý trạng thái bằng Scripting

Chúng ta sử dụng mã Groovy để chứng minh session được duy trì.

### 3.1. ScriptableFilter
- **Tính năng**: Cho phép can thiệp vào luồng Request/Response bằng script.
- **Mapping Mã nguồn OpenIG**:
    - **Module**: `openig-core`
    - **Class**: `org.forgerock.openig.filter.ScriptableFilter`
    - **File vật lý**: `OpenIG/openig-core/src/main/java/org/forgerock/openig/filter/ScriptableFilter.java`
- **Ứng dụng trong Lab**: 
    - File script: `configs/openig/scripts/groovy/sessionTestFilter.groovy`.
    - Script này sử dụng binding `session` (được quản lý bởi `JwtSessionManager`) để lưu trữ dấu vết node khởi tạo (`initial-nodeX`).

---

## 4. Tổng kết luồng Failover Kỹ thuật

1.  **Client** gửi yêu cầu -> **Nginx**.
2.  **Nginx** đẩy vào **Node 2** -> Node 2 gọi `JwtSessionManager` để tạo session mới -> Gửi về Cookie JWT.
3.  **User** (Duykim) dừng **Node 2**.
4.  **Client** gửi yêu cầu tiếp theo kèm Cookie -> **Nginx** thử kết nối Node 2 thất bại -> Tự động chuyển sang **Node 1**.
5.  **Node 1** gọi `JwtSessionManager` -> Nạp `SharedKeyStore` -> Giải mã Cookie -> Tìm thấy dữ liệu của Node 2.
6.  **ScriptableFilter** trên Node 1 đọc session thấy dữ liệu cũ -> Trả về header `RESUMED_FROM_initial-node2`.

---
*Phân tích được thực hiện dựa trên việc đối soát mã nguồn OpenIG 5.4.0 bởi BMad Master (🧙).*
