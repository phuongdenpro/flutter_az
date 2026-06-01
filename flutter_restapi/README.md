# flutter_restapi

Ứng dụng Flutter kết nối REST API — kiến trúc feature-first theo chuẩn dự án doanh nghiệp.

## Cấu trúc thư mục

```
lib/
├── main.dart                 # Entry point
├── app/                      # Lớp ứng dụng (router, shell, MaterialApp)
│   ├── app.dart
│   ├── router/
│   └── shell/
├── config/                   # Hằng số cấu hình app
├── core/                     # Hạ tầng dùng chung (network, storage, theme, DI)
├── shared/                   # Widget & tiện ích tái sử dụng
└── features/                 # Module theo nghiệp vụ
    ├── auth/
    │   ├── data/             # models, services
    │   └── presentation/     # pages, widgets
    ├── home/
    ├── catalog/
    ├── products/
    │   ├── domain/           # entities
    │   ├── data/             # services
    │   └── presentation/
    ├── cart/
    ├── orders/
    └── profile/
```

## Điều hướng

Sau đăng nhập, **Bottom Navigation** gồm 5 tab:

| Tab | Route | Mô tả |
|-----|-------|--------|
| Trang chủ | `/home` | Dashboard, banner, sản phẩm nổi bật |
| Danh mục | `/catalog` | Toàn bộ sản phẩm + tìm kiếm |
| Giỏ hàng | `/cart` | Quản lý giỏ |
| Đơn hàng | `/orders` | Lịch sử đơn (mẫu, chờ API) |
| Tài khoản | `/account` | Hồ sơ, cài đặt, đăng xuất |

Các màn full-screen (chi tiết SP, quản lý admin, sửa hồ sơ) mở trên shell qua `parentNavigatorKey`.

## Chạy ứng dụng

```bash
flutter pub get
flutter run
```
