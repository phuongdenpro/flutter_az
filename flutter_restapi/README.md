# flutter_restapi

Ứng dụng Flutter REST API — **Clean Architecture** + **Riverpod**.

## Cấu trúc thư mục

```
lib/
├── main.dart                    # ProviderScope + entry
├── app/
│   ├── app.dart                 # MaterialApp.router
│   ├── router/                  # go_router config
│   └── shell/                   # Bottom navigation shell
├── core/
│   ├── constants/               # ApiConstants, AppConstants
│   ├── network/                 # ApiClient (Dio + interceptors)
│   ├── storage/                 # TokenStorage
│   ├── errors/                  # Failure, ExceptionMapper
│   ├── providers/               # DI: tokenStorage, apiClient
│   ├── theme/                   # AppTheme, AppColors
│   ├── utils/                   # formatters
│   └── widgets/                 # Shared UI widgets
└── features/
    ├── auth/                    # Login, Register, Logout
    ├── product/                 # CRUD sản phẩm
    ├── profile/                 # Get/Update profile
    ├── settings/                # Change password
    ├── home/                    # Dashboard (presentation)
    ├── catalog/                 # Danh mục (presentation)
    ├── cart/                      # Giỏ hàng local
    └── orders/                  # Đơn hàng (mock)
```

## Luồng Clean Architecture

```
UI (pages) → Controller/Provider → UseCase → Repository (abstract) → RepositoryImpl → RemoteDataSource → Dio
                                              ↑
                                         Entity (domain)
                                         Model (data, fromJson/toEntity)
```

## Feature modules

### auth
- **UseCases:** `LoginUseCase`, `RegisterUseCase`, `LogoutUseCase`, `GetProfileUseCase` (export)
- **Providers:** `loginControllerProvider`, `registerControllerProvider`

### product
- **UseCases:** `GetProductsUseCase`, `GetProductDetailUseCase`, `CreateProductUseCase`, `UpdateProductUseCase`, `DeleteProductUseCase`, `UploadProductImageUseCase`
- **Providers:** `homeProductsProvider`, `catalogProductsProvider`, `productDetailProvider`, `productFormControllerProvider`, `productManagementControllerProvider`

### profile
- **UseCases:** `GetProfileUseCase`, `UpdateProfileUseCase`
- **Providers:** `currentUserProvider`, `editProfileControllerProvider`

### settings
- **UseCases:** `ChangePasswordUseCase`
- **Providers:** `changePasswordControllerProvider`

## Chạy ứng dụng

```bash
flutter pub get
flutter run
flutter analyze lib
```

## Ghi chú

- UI **không** gọi Dio/API trực tiếp.
- Token lưu qua `TokenStorage` sau login.
- `ApiClient` tự gắn Bearer token, xử lý 401 refresh, timeout, retry.
