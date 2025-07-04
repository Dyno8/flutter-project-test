# CareNow MVP – Functional Requirements

## 🎯 1. Mục tiêu

Xây dựng MVP ứng dụng **đặt lịch dịch vụ chăm sóc theo giờ tại nhà**, gồm:

- Người dùng (client): đặt dịch vụ
- Người chăm sóc (partner): nhận lịch, thực hiện job
- Admin: backend quản lý bằng Firebase

---

## 🧩 2. Modules chính

### 2.1. Người dùng (Client)

- Đăng ký / đăng nhập
- Chọn dịch vụ → đặt lịch → thanh toán
- Xem lịch sử & đánh giá

### 2.2. Người chăm sóc (Partner)

- Đăng ký / đăng nhập
- Nhận job theo thời gian rảnh
- Đánh dấu hoàn tất, xem thu nhập

---

## 🖥️ 3. UI Screens

### Client App

- Splash
- Đăng nhập/Đăng ký
- Trang chủ → chọn dịch vụ
- Chọn ngày/giờ
- Chọn người chăm sóc
- Xác nhận đặt lịch
- Lịch sử + đánh giá

### Partner App

- Đăng ký hồ sơ
- Quản lý thời gian rảnh
- Nhận job mới
- Thực hiện job
- Báo cáo thu nhập

---

## ✨ 4. Chi tiết Tính năng

### 4.1. Người dùng (Client App)

#### 🧩 1. Đăng ký / Đăng nhập

- Firebase Auth: OTP hoặc Email + Password
- Giao diện lớn, đơn giản, phù hợp người lớn tuổi

#### 🧩 2. Chọn dịch vụ

- Giao diện thẻ biểu tượng dịch vụ
- Chọn ngày & giờ
- Tùy chọn: chọn người chăm sóc cụ thể

#### 🧩 3. Xem người chăm sóc gợi ý

- Gợi ý theo vị trí & thời gian
- Hiển thị: avatar, tên, chuyên môn, sao, giá/giờ

#### 🧩 4. Đặt lịch + thanh toán

- Xác nhận chi tiết + thanh toán Momo/VNPay
- Sau khi thanh toán: trạng thái → "Đã xác nhận"

#### 🧩 5. Lịch sử đặt lịch

- Danh sách đơn hàng
- Cho phép đánh giá

#### 🧩 6. Đánh giá dịch vụ

- 1–5 sao + nhận xét
- Lưu lại để hiển thị cho người dùng khác

---

### 4.2. Người chăm sóc (Partner App)

#### 🧩 1. Đăng ký / Đăng nhập

- Firebase Auth
- Hồ sơ: ảnh, dịch vụ, khu vực

#### 🧩 2. Quản lý thời gian rảnh

- Đăng ký lịch rảnh để nhận job

#### 🧩 3. Nhận thông báo đặt lịch

- Notification khi có job phù hợp
- Xác nhận hoặc từ chối

#### 🧩 4. Thực hiện & hoàn tất job

- Chuyển trạng thái: "Bắt đầu" → "Hoàn tất"
- Gửi báo cáo nhanh (nếu cần)

#### 🧩 5. Báo cáo thu nhập

- Tổng job hoàn thành
- Doanh thu trừ chiết khấu
- Lọc theo ngày/tuần/tháng

---

### 4.3. Firebase Backend (Admin logic)

#### 🧩 1. Auth & Phân quyền

- Firebase Auth
- Gắn vai trò: `user` hoặc `partner`

#### 🧩 2. Firestore DB Collections

- `users`: thông tin người dùng
- `partners`: thông tin người chăm sóc
- `services`: loại dịch vụ
- `bookings`: lịch đặt
- `reviews`: đánh giá

#### 🧩 3. Cloud Functions

- Matching người chăm sóc
- Gửi thông báo

#### 🧩 4. Notification System

- Firebase Cloud Messaging (FCM)

#### 🧩 5. Quản lý đơn đặt lịch

- Trạng thái: `pending`, `confirmed`, `in-progress`, `completed`, `cancelled`

---

## 🔁 5. Luồng người dùng (User Flow)

### 5.1. Client

1. Mở app → Đăng ký / Đăng nhập
2. Chọn dịch vụ
3. Chọn ngày, giờ
4. Chọn người chăm sóc (nếu có)
5. Thanh toán
6. Theo dõi đơn hàng
7. Đánh giá sau dịch vụ

### 5.2. Partner

1. Mở app → Đăng ký / Đăng nhập
2. Cập nhật hồ sơ, thời gian rảnh
3. Nhận job → xác nhận / từ chối
4. Thực hiện job → Hoàn tất
5. Xem thu nhập

---

## 🗂️ 6. Cấu trúc Firestore Database (Sơ lược)

### `users` (Client)

```json
{
  "uid": "string",
  "name": "string",
  "phone": "string",
  "email": "string",
  "address": "string",
  "createdAt": "timestamp"
}


partners (Người chăm sóc)
{
  "uid": "string",
  "name": "string",
  "gender": "string",
  "services": ["elder_care", "pet_care"],
  "working_hours": {
    "monday": ["08:00–12:00"],
    "tuesday": ["14:00–18:00"]
  },
  "rating": 4.7,
  "location": {
    "lat": "float",
    "lng": "float"
  }
}

services
{
  "id": "elder_care",
  "name": "Chăm sóc người già",
  "icon": "url",
  "pricePerHour": 100000
}


bookings
{
  "id": "string",
  "userId": "string",
  "partnerId": "string",
  "serviceId": "string",
  "date": "2025-07-03",
  "timeSlot": "10:00–12:00",
  "status": "pending | confirmed | in-progress | completed | cancelled",
  "totalAmount": 200000,
  "paymentStatus": "paid | unpaid"
}

reviews
{
  "bookingId": "string",
  "userId": "string",
  "partnerId": "string",
  "rating": 5,
  "comment": "Rất hài lòng!",
  "createdAt": "timestamp"
}

```
