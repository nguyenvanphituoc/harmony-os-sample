# UI Layer traceability index

TASK-019 (R18/R19). Maps every numbered section of [`ui-layer.md`](ui-layer.md) to the real,
existing file(s) in this repo that exemplify it. A row points only at code that has actually
landed — a section no scope has built yet is marked **unmapped**, never linked to a path that
doesn't exist or was only planned. Checked against the same `run_cmd` used throughout this run
(`hvigorw assembleHap --mode module -p product=default -p buildMode=debug --no-daemon`).

Status at this round: the component layer (§1), localize data (§3) and the Enforce task (§5) are
built; the screen layer (§2) is not — the route table is still empty and no `features/*/view` or
`app/screens/*` directory exists yet (TASK-008/009/012/013 are still `ready`). Rows under §2 are
therefore unmapped except where the navigation host and composition root already exist.

## 0 · Bản đồ tầng UI

| Layer | Exemplar file(s) |
|---|---|
| `resources/` (chuỗi · màu · số đo, chưa phân giải) | `app/entry/src/main/resources/base/element/string.json`, `app/entry/src/main/resources/base/element/color.json`, `app/entry/src/main/resources/base/element/float.json` |
| `shared/uikit/` (token → primitive → pattern → registry) | `app/entry/src/main/ets/shared/uikit/tokens/color-tokens.ets`, `app/entry/src/main/ets/shared/uikit/app-button.ets`, `app/entry/src/main/ets/shared/uikit/async-boundary.ets`, `app/entry/src/main/ets/shared/uikit/registries/theme-registry.ets` |
| `features/<ctx>/components/` (organism) | unmapped — no `features/todo/components/` directory yet |
| `features/<ctx>/view/<Screen>/` · ViewModel | unmapped — no screen built yet (§2) |

## 1 · Component

### 1.1 Bốn tầng thành phần
- token: `app/entry/src/main/ets/shared/uikit/tokens/color-tokens.ets`, `app/entry/src/main/ets/shared/uikit/tokens/spacing-tokens.ets`, `app/entry/src/main/ets/shared/uikit/tokens/typography-tokens.ets`
- primitive: `app/entry/src/main/ets/shared/uikit/app-button.ets`, `app/entry/src/main/ets/shared/uikit/app-text.ets`, `app/entry/src/main/ets/shared/uikit/app-icon.ets`
- pattern: `app/entry/src/main/ets/shared/uikit/async-boundary.ets`, `app/entry/src/main/ets/shared/uikit/list-scaffold.ets`, `app/entry/src/main/ets/shared/uikit/screen-scaffold.ets`
- organism (`features/<ctx>/components/`): unmapped — not built yet

### 1.2 Hợp đồng của một component
- `@ComponentV2` / `@Param` / `@Event`: `app/entry/src/main/ets/shared/uikit/app-button.ets`
- Nội dung con, slot cố định (`@BuilderParam`, xác nhận ở spike U2): `app/entry/src/main/ets/shared/uikit/async-boundary.ets`, `app/entry/src/main/ets/shared/uikit/screen-scaffold.ets`, `app/entry/src/main/ets/shared/uikit/list-scaffold.ets`
- Nội dung con, slot chọn theo khoá (`WrappedBuilder` qua `@Param`): unmapped — no keyed-slot registry uses `WrappedBuilder` yet (existing registries resolve plain value objects, not builders — see 1.4)

### 1.3 Kiểu của prop cưỡng chế hai luật cùng lúc
- Chữ hiển thị kiểu `Resource`: `app/entry/src/main/ets/shared/uikit/app-text.ets`
- Màu kiểu `Resource`: `app/entry/src/main/ets/shared/uikit/tokens/color-tokens.ets`
- Định danh của `shared/kernel`: `app/entry/src/main/ets/shared/kernel/todo-id.ts`

### 1.4 Registry — một cơ chế cho mọi "chọn theo khoá"
- `app/entry/src/main/ets/shared/uikit/registries/status-registry.ets` (khoá `AsyncStatus` → `VisualState`, dùng bởi `app/entry/src/main/ets/shared/uikit/async-boundary.ets`)
- `app/entry/src/main/ets/shared/uikit/registries/theme-registry.ets` (khoá `ButtonVariant` → `ButtonTheme`)
- `app/entry/src/main/ets/shared/uikit/registries/field-registry.ets`, `app/entry/src/main/ets/shared/uikit/registries/overlay-registry.ets`
- `app/entry/src/main/ets/shared/uikit/modifiers/interactive-state-registry.ets` (khoá `InteractiveState` → `InteractiveStyle`)
- Lưu ý: bốn registry trên map khoá tới **giá trị dữ liệu** (token/config), chưa tới `WrappedBuilder` — hình dạng "khoá → builder" của tài liệu chưa có exemplar; phần element (leaf/dialog/list-item/theme-builder) vẫn unmapped

### 1.5 Style tái dùng là `AttributeModifier`
- unmapped — chưa có file nào implement `AttributeModifier` trong repo; style hiện áp trực tiếp trong `build()` (ví dụ `app/entry/src/main/ets/shared/uikit/app-button.ets`), chưa thăng hạng theo luật này

### 1.6 Luật thăng hạng — không bao giờ sao chép rồi sửa
- Không kiểm bằng file đơn lẻ — quy tắc tổ chức thư mục, thấy được qua chính cấu trúc `app/entry/src/main/ets/shared/uikit/` (không có bản fork nào của cùng một primitive tính tới vòng này)

### 1.7 Sáu trạng thái bắt buộc
- `app/entry/src/main/ets/shared/uikit/modifiers/interactive-state.ets` (khai sáu trạng thái)
- `app/entry/src/main/ets/shared/uikit/modifiers/interactive-state-registry.ets` (token theo từng trạng thái)
- `app/entry/src/main/ets/shared/uikit/modifiers/touch-target.ets` (vùng chạm tối thiểu)

### 1.8 Danh mục khởi đầu
- `AppText`: `app/entry/src/main/ets/shared/uikit/app-text.ets`
- `AppButton`: `app/entry/src/main/ets/shared/uikit/app-button.ets`
- `AppIcon`: `app/entry/src/main/ets/shared/uikit/app-icon.ets`
- `Avatar`: `app/entry/src/main/ets/shared/uikit/avatar.ets`
- `Chip`: `app/entry/src/main/ets/shared/uikit/chip.ets`
- `Skeleton` · `Spinner`: `app/entry/src/main/ets/shared/uikit/skeleton.ets`, `app/entry/src/main/ets/shared/uikit/spinner.ets`
- `Divider` · `Spacer`: `app/entry/src/main/ets/shared/uikit/divider.ets`, `app/entry/src/main/ets/shared/uikit/spacer.ets`
- `AsyncBoundary`: `app/entry/src/main/ets/shared/uikit/async-boundary.ets`
- `ScreenScaffold`: `app/entry/src/main/ets/shared/uikit/screen-scaffold.ets`
- `ListScaffold`: `app/entry/src/main/ets/shared/uikit/list-scaffold.ets`
- `EmptyState` · `ErrorState`: `app/entry/src/main/ets/shared/uikit/empty-state.ets`, `app/entry/src/main/ets/shared/uikit/error-state.ets`
- `Field` · `AppCard` · `OverlayHost`: unmapped — not built yet

### 1.9 Xong một component nghĩa là gì
- Checklist, không có file riêng — kiểm chéo qua các file ở 1.1–1.8

## 2 · Screen

### 2.1 Bốn phần của một màn hình
- unmapped — không màn hình nào đã có đủ bốn phần (Page · ViewModel · View · `parts/`) tính tới vòng này; TASK-008/009/012/013 còn ở trạng thái `ready`

### 2.2 route_map.json — hợp đồng khai báo
- `app/entry/src/main/resources/base/profile/route_map.json` (file tồn tại, hiện `routerMap: []` — chưa có mục nào vì chưa màn nào build xong, đúng như comment trong `app/entry/src/main/ets/pages/Index.ets`)

### 2.3 Hình dạng chuẩn của ViewModel
- unmapped — chưa có ViewModel nào trong repo

### 2.4 Bốn trạng thái và `AsyncBoundary`
- Cơ chế (pattern dùng bởi màn hình sau này): `app/entry/src/main/ets/shared/uikit/async-boundary.ets`, `app/entry/src/main/ets/shared/uikit/registries/status-registry.ets`
- Màn hình dùng nó: unmapped — chưa có

### 2.5 Vòng đời một màn hình
- unmapped — chưa có `NavDestination`/Page nào

### 2.6 Điều hướng
- Host điều hướng duy nhất: `app/entry/src/main/ets/pages/Index.ets` (giữ `Navigation` + `NavPathStack`, đúng luật "chỉ một host")
- Bảng route: `app/entry/src/main/resources/base/profile/route_map.json` (rỗng, xem 2.2)

### 2.7 Lớp phủ do ViewModel mở
- `UIContext` bắt một lần: `app/entry/src/main/ets/entryability/EntryAbility.ets` (`onWindowStageCreate`'s `loadContent` callback), cất vào `app/entry/src/main/ets/shared/runtime/ui-context-holder.ts`
- `OverlayHost` + `overlayRegistry` dùng nó: unmapped — `app/entry/src/main/ets/shared/uikit/registries/overlay-registry.ets` tồn tại nhưng chưa có component `OverlayHost` nào đọc nó

### 2.8 Màn hình gộp nhiều context
- unmapped — chưa có `adapters/readmodel/` hay `app/screens/Dashboard/`

### 2.9 Bốn nguyên mẫu màn hình
- unmapped — chưa màn nào thuộc bất kỳ nguyên mẫu nào build xong

### 2.10 Xong một màn hình nghĩa là gì
- Checklist — không áp dụng được cho tới khi có màn đầu tiên (unmapped)

## 3 · Localize

### 3.1 Chữ được phép nằm ở đâu
- `app/entry/src/main/resources/base/element/string.json` (nhãn/tiêu đề/nút)
- `app/entry/src/main/resources/base/element/plural.json` (số nhiều)
- `app/entry/src/main/ets/shared/utils/format-date.ts` (ngày giờ, hàm định dạng)
- `app/entry/src/main/ets/shared/kernel/error.ets` (mã lỗi, không dịch — `.ts`/`.ets`, không phải string.json)

### 3.2 Cây tài nguyên
- `app/entry/src/main/resources/base/element/string.json`, `app/entry/src/main/resources/base/element/plural.json`, `app/entry/src/main/resources/base/element/color.json`, `app/entry/src/main/resources/base/element/float.json`
- `app/entry/src/main/resources/vi_VN/element/string.json`, `app/entry/src/main/resources/vi_VN/element/plural.json`
- `app/entry/src/main/resources/dark/element/color.json`

### 3.3 Quy ước khoá
- `app/entry/src/main/resources/base/element/string.json` (khoá tiền tố `<màn>_<vai>`, `common_*`, `err_*`)

### 3.4 Ba tầng của một thông báo lỗi
- domain trả mã: `app/entry/src/main/ets/features/todo/domain/todo-rules.ts`
- `shared/kernel` khai `ErrorCode`: `app/entry/src/main/ets/shared/kernel/error.ets`
- bảng `ErrorCode → Resource` (một bảng cho cả app): `app/entry/src/main/ets/shared/uikit/i18n/error-resource-map.ts`
- ViewModel tra bảng: unmapped — chưa có ViewModel nào (§2)

### 3.5 Số nhiều, ngày giờ, con số
- Số nhiều theo `quantity`: `app/entry/src/main/resources/base/element/plural.json` (`todo_count`: `one`/`other`)
- Hàm định dạng nhận `locale` làm tham số: `app/entry/src/main/ets/shared/utils/format-date.ts`
- Dùng trực tiếp `$r(key, n, n)` trong `@Computed` (spike U1): unmapped — chưa có ViewModel/màn nào gọi nó (§2)

### 3.6 Đổi ngôn ngữ lúc chạy
- `getStringSync()` giới hạn trong `shared/uikit/i18n`: `app/entry/src/main/ets/shared/uikit/i18n/error-resource-map.ts` (dùng `$r`, không gọi `getStringSync`, đúng luật — không có lệnh gọi nào bị cấm trong repo)
- Điểm nhận cấu hình duy nhất (`EntryAbility.onConfigurationUpdate` → `AppearanceStore`): unmapped — `app/entry/src/main/ets/entryability/EntryAbility.ets` chưa khai `onConfigurationUpdate` (xem 4.7)

### 3.7 Hướng đọc
- unmapped — chưa có `.ets` view nào dùng `start`/`end` padding hay `Direction.Auto` (chưa có view nào ngoài `app/entry/src/main/ets/pages/Index.ets`, vốn không có nội dung căn lề)

### 3.8 Chuỗi từ máy chủ và từ người dùng
- unmapped — app chưa có lệnh gọi máy chủ (kho dữ liệu là `InMemoryTodoRepository`); không có trường hợp thật để trỏ tới

### 3.9 Kiểm chuỗi bằng máy
- Rule L3/L4/L5 tương ứng chạy trong: `app/build-src/enforce/rule-table.ts`, `app/build-src/enforce/scan.ts` (xem §5)

## 4 · Application appearance

### 4.1 Token là tài nguyên, không phải TypeScript
- `app/entry/src/main/resources/base/element/color.json`, `app/entry/src/main/resources/base/element/float.json`
- `app/entry/src/main/ets/shared/uikit/tokens/color-tokens.ets`, `app/entry/src/main/ets/shared/uikit/tokens/spacing-tokens.ets`, `app/entry/src/main/ets/shared/uikit/tokens/typography-tokens.ets` (token không biểu diễn được bằng resource: dùng hằng `.ets`, đúng luật)

### 4.2 Ba nguồn quyết định sáng hay tối
- Hệ thống (qualifier `dark/`): `app/entry/src/main/resources/dark/element/color.json`
- Người dùng chọn / ép cục bộ: unmapped — chưa có lời gọi `setColorMode` hay `WithTheme` nào (màn Settings, TASK-012, chưa build)

### 4.3 Theme đặt một lần
- `app/entry/src/main/ets/entryability/EntryAbility.ets` (`ThemeControl.setDefaultTheme(undefined)` trong callback của `loadContent`, đúng chỗ và đúng một lần)

### 4.4 Cỡ chữ hệ thống và khả năng tiếp cận
- `app/entry/src/main/ets/shared/uikit/modifiers/touch-target.ets` (vùng chạm tối thiểu)
- configuration.json khai `followSystem` (spike U3): unmapped — file chưa được tạo (đường dẫn dự kiến app/AppScope/resources/base/profile/configuration.json, không đánh dấu code vì chưa tồn tại), và `app/AppScope/app.json5` chưa có trường `configuration` (còn nằm trong TASK-007, `in-progress`)

### 4.5 Nhiều kích thước cửa sổ
- `app/entry/src/main/ets/pages/Index.ets` (`.mode(NavigationMode.Auto)` — đúng chỗ, một chỗ, mọi màn hưởng)

### 4.6 Ảnh và biểu tượng
- `app/entry/src/main/ets/shared/uikit/app-icon.ets`
- `app/entry/src/main/resources/base/media/background.png`, `app/entry/src/main/resources/base/media/foreground.png`, `app/entry/src/main/resources/base/media/startIcon.png`, `app/entry/src/main/resources/base/media/layered_image.json`
- Ảnh bitmap có bản tối riêng (`dark/media/`): unmapped — chưa có thư mục `dark/media/`

### 4.7 Một điểm nhận, một điểm áp dụng
- `AppearanceStore`: `app/entry/src/main/ets/shared/runtime/appearance-store.ets`
- Điểm nhận `EntryAbility.onConfigurationUpdate`: unmapped — chưa khai trong `app/entry/src/main/ets/entryability/EntryAbility.ets` (còn nằm trong TASK-007/TASK-012, `in-progress`/`ready`)

### 4.8 Lưu lựa chọn của người dùng
- unmapped — quyết định của pitch này là cài đặt **volatile** (không ghi `preferences`, xác nhận ở spike U4); `AppearanceService` mô tả ở tài liệu chưa có file tương ứng trong repo

## 5 · Enforce

- Bảng rule dữ liệu (L1–L11): `app/build-src/enforce/rule-table.ts`
- Logic quét/so sánh: `app/build-src/enforce/scan.ts`, `app/build-src/enforce/fs-scan.ts`
- Điểm vào chạy trong `hvigorw assembleHap`: `app/build-src/enforce/index.ts`, gọi từ cả `app/hvigorfile.ts` và `app/entry/hvigorfile.ts`

## 6 · Kiểm thử tầng UI

- Không cần thiết bị (`src/test`): `app/entry/src/test/LocalUnit.test.ets` (rule biểu mẫu + hàm định dạng, xem TASK-017)
- Cần thiết bị (`src/ohosTest`): `app/entry/src/ohosTest/ets/test/Ability.test.ets`, `app/entry/src/ohosTest/ets/test/List.test.ets`
- Bốn nhánh của `AsyncBoundary` mỗi màn / điều hướng khôi phục ngăn xếp / chế độ tối / cỡ chữ lớn nhất: unmapped — cần màn hình thật để test (§2 chưa build)

## 7 · Checklist

- Không có file riêng — checklist rà chéo qua tất cả file ở trên; item "màn mới có mục route, đủ bốn trạng thái" chưa áp dụng được (§2 unmapped)

## 8 · Cần kiểm chứng

- `shapeup/hero-todo/shaping/spike-U1-plural-via-r.md`
- `shapeup/hero-todo/shaping/spike-U2-builderparam-in-v2.md`
- `shapeup/hero-todo/shaping/spike-U3-font-scale-cap.md`
- `shapeup/hero-todo/shaping/spike-U4-language-switch-redraw.md`
- `shapeup/hero-todo/shaping/spike-U5-linter-extRuleSet.md`

## Phụ lục · Cây thư mục tầng UI

- Cây thư mục minh hoạ trong `ui-layer.md`'s phụ lục dùng ví dụ tổng quát (`features/log/…`), không phải cây thật của `hero-todo` — cây thật nằm dưới `app/entry/src/main/ets/` (xem các mục 0–5 ở trên cho file cụ thể của slice `todo`)
