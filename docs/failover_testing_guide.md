# Hướng dẫn Kiểm thử Failover (Step-by-Step)

Tài liệu này hướng dẫn cách kiểm tra thủ công hoặc tự động để xác nhận khả năng chịu lỗi của hệ thống.

## 1. Kiểm thử tự động (Recommended)
Sử dụng script đã được tối ưu hóa để giả lập toàn bộ quá trình.

```bash
# Chạy script kiểm thử
bash test_failover.sh
```
**Kết quả mong đợi**: Script trả về thông báo `SUCCESS: FAILOVER CONFIRMED!`.

## 2. Kiểm thử thủ công (Manual Steps)

### Bước 1: Khởi động hệ thống
```bash
docker-compose up -d --build
```
Đợi các node chuyển sang trạng thái `healthy` (kiểm tra bằng `docker ps`).

### Bước 2: Tạo phiên làm việc ban đầu
Gửi một request đến Load Balancer:
```bash
curl -v http://localhost/
```
**Quan sát**:
- Header `X-OpenIG-Node`: Cho biết node nào đang xử lý (ví dụ: `node1`).
- Header `X-Session-Status`: Phải là `NEW_SESSION_ON_node1`.
- Header `Set-Cookie`: Lấy giá trị của `JSESSIONID-JWT` (chuỗi dài).

### Bước 3: Giả lập sự cố
Dừng node đang xử lý yêu cầu ở Bước 2:
```bash
docker-compose stop openig-node1
```

### Bước 4: Kiểm tra khả năng phục hồi (Failover)
Gửi lại request kèm theo Cookie đã lấy được ở Bước 2:
```bash
curl -v -H "Cookie: JSESSIONID-JWT=<GIÁ_TRỊ_COOKIE_Ở_BƯỚC_2>" http://localhost/
```

**Kết quả thành công khi**:
1.  **Tính sẵn sàng**: Request vẫn thành công (HTTP 200) dù node1 đã chết.
2.  **Định tuyến**: Header `X-OpenIG-Node` chuyển sang `node2`.
3.  **Duy trì phiên**: Header `X-Session-Status` phải hiển thị `RESUMED_FROM_initial-node1`.

## 3. Giải thích cơ chế thành công
Khi `node1` chết, Nginx nhận thấy kết nối lỗi và lập tức thử `node2` (nhờ `proxy_next_upstream`). `node2` nhận được request kèm Cookie, sử dụng **Shared KeyStore** để giải mã và tìm thấy dữ liệu phiên mà `node1` đã ghi vào đó. Người dùng hoàn toàn không nhận ra sự gián đoạn.

---
*Tài liệu được soạn thảo bởi BMad Master Agent (🧙).*
