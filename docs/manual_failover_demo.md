# Hướng dẫn Trình diễn Failover OpenIG (Thủ công)

Tài liệu này được thiết kế để trình diễn khả năng chịu lỗi và duy trì phiên làm việc của OpenIG bằng cách sử dụng **JwtSession**.

---

## Giai đoạn 1: Chuẩn bị môi trường

### 1. Khởi động hệ thống
**Lệnh:**
```bash
docker-compose up -d --build
```
**Giải thích:** 
- `up -d`: Chạy các container (Nginx, Node1, Node2) ở chế độ nền.
- `--build`: Đảm bảo các cấu hình mới nhất trong `server.xml` và `config.json` được nạp vào Image.

### 2. Theo dõi Nhật ký (Logs)
Mở 2 cửa sổ Terminal riêng biệt để quan sát cách các node xử lý dữ liệu.

**Terminal 1 (Node 1):**
```bash
docker logs -f failover-test-environment-openig-node1-1
```

**Terminal 2 (Node 2):**
```bash
docker logs -f failover-test-environment-openig-node2-1
```
**Giải thích:** Tham số `-f` (follow) giúp bạn thấy log xuất hiện ngay lập tức khi có request đến.

---

## Giai đoạn 2: Trình diễn Failover

### Bước 1: Tạo phiên làm việc (Session) ban đầu
**Lệnh:**
```bash
curl -i http://localhost/
```
**Giải thích:** Gửi một request HTTP đến Nginx Load Balancer trên cổng 80.

**Kết quả cần quan sát:**
1.  **Header `X-OpenIG-Node`**: Xem node nào đang trả lời (ví dụ: `node2`).
2.  **Header `X-Session-Status`**: Sẽ hiển thị `NEW_SESSION_ON_node2`.
3.  **Header `Set-Cookie`**: Tìm dòng `JSESSIONID-JWT=...`. Đây chính là "hộ chiếu" chứa dữ liệu phiên đã mã hóa.
4.  **Tại log của Node xử lý**: Bạn sẽ thấy dòng log từ Groovy script xác nhận thuộc tính phiên đã được tạo thành công.

**Hành động:** Copy toàn bộ chuỗi Cookie (ví dụ: `JSESSIONID-JWT=eyJ...`).

### Bước 2: Giả lập thảm họa (Sát thủ Node)
**Lệnh (Giả sử Node 2 đang xử lý):**
```bash
docker stop failover-test-environment-openig-node2-1
```
**Giải thích:** Dừng hoàn toàn container đang giữ phiên làm việc. Trong kiến trúc cũ (Memory session), dữ liệu sẽ mất trắng tại đây.

**Kết quả cần quan sát:** Cửa sổ Terminal log của Node 2 sẽ dừng lại và báo kết nối bị ngắt.

### Bước 3: Chứng minh khả năng phục hồi (Failover)
**Lệnh:**
```bash
curl -i -H "Cookie: <CHUỖI_COOKIE_ĐÃ_COPY>" http://localhost/
```
**Giải thích:** Gửi request đến Nginx một lần nữa, nhưng mang theo "hộ chiếu" JWT lấy từ bước 1.

**Kết quả cần quan sát (Điểm mấu chốt):**
1.  **Mã phản hồi HTTP 200**: Nginx tự động chuyển hướng sang Node 1 ngay khi thấy Node 2 chết. Người dùng không hề thấy lỗi.
2.  **Header `X-OpenIG-Node`**: Bây giờ sẽ hiển thị `node1`.
3.  **Header `X-Session-Status`**: Hiển thị `RESUMED_FROM_initial-node2`.
4.  **Tại log của Node 1**: Bạn sẽ thấy log báo: *"Giải mã thành công, tìm thấy dữ liệu từ node2"*.

---

## Giai đoạn 3: Giải thích cơ chế (Dành cho người xem)

Để đạt được kết quả này, chúng ta đã áp dụng 3 kỹ thuật cốt lõi:

1.  **Nginx proxy_next_upstream**: Nginx đóng vai trò "người điều phối thông minh". Khi nó gửi yêu cầu đến Node 2 và bị từ chối, nó lập tức thử Node 1 trước khi báo lỗi cho người dùng.
2.  **JwtSession (Client-side Session)**: Thay vì lưu dữ liệu vào bộ nhớ của Server (thứ sẽ mất khi server chết), chúng ta mã hóa dữ liệu vào Cookie và gửi về cho Trình duyệt giữ.
3.  **Shared RSA KeyStore**: Để Node 1 có thể đọc được dữ liệu mà Node 2 đã viết, cả hai phải dùng chung một "chìa khóa giải mã" (Keystore) và một "chuẩn ký tên" (Shared Secret).

---
*Tài liệu trình diễn được biên soạn bởi BMad Master Agent (🧙).*
