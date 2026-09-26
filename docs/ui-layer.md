# UI Layer — Component · Screen · Localize · Appearance

Bản chi tiết của [phần 8 trong index](index.md#8--ui-layer). Tài liệu này trả lời bốn câu hỏi,
và mỗi câu là một phần bên dưới:

| Câu hỏi | Phần | Đơn vị công việc |
|---|---|---|
| Màn hình được **dựng bằng gì**? | [1 · Component](#1--component) | `shared/uikit` · `features/*/components` |
| **Một màn hình** gồm những gì, sống ra sao? | [2 · Screen](#2--screen) | `features/*/view` · `features/*/viewmodel` · `app/screens` |
| **Chữ** trên màn hình từ đâu ra? | [3 · Localize](#3--localize) | `resources/**/element/string.json` |
| **Màu, cỡ, chế độ sáng tối** từ đâu ra? | [4 · Appearance](#4--application-appearance) | `resources/**/element/color.json` · `float.json` · theme |

Ba phần cuối là hạ tầng cho cả bốn:

| | |
|---|---|
| [5 · Enforce](#5--enforce) | Rule của hvigor task / Code Linter riêng cho tầng UI |
| [6 · Kiểm thử](#6--kiểm-thử-tầng-ui) | Cái gì test không cần thiết bị, cái gì thì cần |
| [7 · Checklist](#7--checklist) · [8 · Cần kiểm chứng](#8--cần-kiểm-chứng) | Danh sách rà PR · những chỗ tài liệu chưa dám chốt |

---

## 0 · Bản đồ tầng UI

```
   resources/                      chuỗi · màu · số đo · media — KHÔNG phải TypeScript
        │  $r(...)   → giá trị kiểu Resource, CHƯA phân giải
        ▼
   shared/uikit/     token ──▶ primitive ──▶ pattern ──▶ registry
        │                                                   │
        │  (không biết context nào tồn tại)                  │
        ▼                                                   ▼
   features/<ctx>/components/      organism riêng slice — chỉ GHÉP, không fork
        │
        ▼
   features/<ctx>/view/<Screen>/   XPage.ets ─▶ X.view.ets ─▶ parts/*.ets
        ▲
        │  @Param vm  (một chiều)          ▲  @Event  (một chiều, ngược lại)
        │                                  │
   features/<ctx>/viewmodel/XViewModel.ets     ← nơi DUY NHẤT của tầng UI có tác dụng phụ
```

**Một câu tóm tắt cả tầng:** mọi thứ đi xuống là `Resource` và `@Param`, mọi thứ đi lên là `@Event`,
và không có nhánh nào rẽ ngang sang store hay repository.

---

## 1 · Component

### 1.1 Bốn tầng thành phần

| Tầng | Ở đâu | Biết gì | Ví dụ | Được import bởi |
|---|---|---|---|---|
| **token** | `resources/**/element/` + `uikit/token/` | không gì cả | `space_m` · `backgroundEmphasize` · `Motion.standard` | mọi tầng trên |
| **primitive** | `uikit/primitive/` | token | `AppButton` · `AppText` · `Field` · `AppIcon` | pattern · organism · view |
| **pattern** | `uikit/pattern/` | primitive + registry | `AsyncBoundary` · `FormFrame` · `ListScaffold` · `OverlayHost` | organism · view |
| **organism** | `features/<ctx>/components/` | **entity của đúng slice đó** | `LogCard` · `LogMediaGallery` | view của cùng slice |

Mũi tên một chiều. `shared/uikit` **không bao giờ** import `features/` — đó là dòng cuối trong
[bảng tầng import](index.md#bảng-tầng-import), và nó là thứ giữ cho uikit dùng lại được ở slice thứ hai.

> **Vì sao organism nằm trong slice chứ không nằm ở uikit.** `LogCard` nhận một `Log` — nó buộc phải
> biết entity, nên nó không thể sống ở tầng không biết context nào. Đưa nó lên uikit thì phải kéo
> theo `Log`, và uikit lập tức phụ thuộc ngược vào feature.

### 1.2 Hợp đồng của một component

| Thành phần | Cách khai | Luật |
|---|---|---|
| Struct | `@ComponentV2` | **Không** trộn `@Component` (V1) vào cùng dự án — hai thế hệ quan sát khác nhau, trộn là nguồn lỗi "không vẽ lại" khó tìm nhất |
| Prop bắt buộc | `@Require @Param` | Thiếu khi gọi là lỗi **biên dịch**, không phải `undefined` lúc chạy |
| Prop tuỳ chọn | `@Param` + giá trị mặc định | Chỉ đọc — không gán lại `this.xxx` của một `@Param` |
| Prop chỉ nhận giá trị khởi tạo | `@Param @Once` | Dùng cho giá trị "hạt giống" mà component tự quản sau đó (ví dụ giá trị mở đầu của một ô nhập) |
| Sự kiện ra | `@Event` | Tên `onX`. **Không trả giá trị** — component không hỏi, nó báo |
| State giao diện thuần | `@Local` | Tab đang chọn · panel mở · đang focus. Không lộ ra ngoài |
| Nội dung con — slot cố định (đúng một vùng, không chọn theo khoá) | `@Require @BuilderParam` | `ScreenScaffold.body` · `AppCard.content` · `FormFrame.fields` — xác nhận ở spike U2 |
| Nội dung con — slot chọn theo khoá (ô biểu mẫu, thân lớp phủ, phần tử danh sách, nhánh trạng thái, theme) | `WrappedBuilder<[XParams]>` truyền qua `@Param` | `@Builder` **toàn cục** + `wrapBuilder()` — xem 1.4 |
| Style tái dùng | `AttributeModifier` | Không `@Styles`, không `@Extend` — xem 1.5 |

**Component không được:** gọi use case · đọc store · gọi `AppStorageV2.connect()` · chạm `NavPathStack` ·
tự mở overlay · chứa nhánh rẽ nghiệp vụ · chứa chuỗi hiển thị.

Cần một trong số đó thì phát `@Event` lên trên. Component là **hàm thuần từ props ra hình ảnh**,
cộng đúng một chút state giao diện của riêng nó.

> **`@Provider` / `@Consumer` bị cấm trong dự án này.** Một component đọc `@Consumer` chỉ dựng được
> khi có đúng cây cha bọc ngoài — nó hết dùng lại được, hết test được độc lập, và quan hệ phụ thuộc
> biến mất khỏi chữ ký hàm. Truyền qua `@Param`, kể cả khi phải xuyên hai cấp.

### 1.3 Kiểu của prop cưỡng chế hai luật cùng lúc

Đây là chỗ hệ thống kiểu làm hộ việc mà bình thường phải nhờ người review:

| Vai của prop | Kiểu **được** dùng | Kiểu **bị cấm** | Cưỡng chế được gì |
|---|---|---|---|
| Chữ hiển thị | `Resource` | `string` · `ResourceStr` | Không thể truyền chuỗi cứng vào → **localize thành lỗi biên dịch** |
| Màu | `Resource` | `Color` · `string` · `number` · `ResourceColor` | Không thể viết hex → **chế độ tối luôn đúng** |
| Số đo | `Resource` (từ `float.json`) | số trần | Không có số ma thuật rải trong feature |
| Định danh | kiểu định danh của `shared/kernel` | `string` | Không truyền nhầm id của entity khác |
| Lựa chọn hữu hạn | `enum` | chuỗi liên hợp | `as const` bị cấm nên `enum` là cách duy nhất còn kiểu hẹp |

`ResourceStr` và `ResourceColor` là kiểu tổng **có chứa `string`** — dùng chúng là mở lại đúng cái cửa
vừa đóng. Chỉ `shared/uikit/primitive` được nhận `ResourceStr`, và cũng chỉ ở chỗ phải nói chuyện
với API của ArkUI.

Ngoại lệ duy nhất là **nội dung do người dùng nhập** (tiêu đề một log, tên một bộ sưu tập).
Nó là dữ liệu, không phải chữ của giao diện — kiểu `string`, và đi kèm luật ở [3.8](#38-chuỗi-từ-máy-chủ-và-từ-người-dùng).

### 1.4 Registry — một cơ chế cho mọi "chọn theo khoá"

`as const` bị cấm nên không suy được kiểu từ mảng literal. Thay bằng **`enum` làm khoá** và
**`WrappedBuilder` làm giá trị**:

```ts
export enum FieldType { Text, Number, Date, Select, Toggle, Media }

@Builder function TextFieldLeaf(p: FieldParams) { /* … */ }   // phải là @Builder TOÀN CỤC
@Builder function DateFieldLeaf(p: FieldParams) { /* … */ }

export const fieldRegistry: Map<FieldType, WrappedBuilder<[FieldParams]>> = new Map([
  [FieldType.Text, wrapBuilder(TextFieldLeaf)],
  [FieldType.Date, wrapBuilder(DateFieldLeaf)],
])

@Builder export function Field(p: FieldParams) {   // MỘT tham số object → truyền THAM CHIẾU
  fieldRegistry.get(p.type)?.builder(p)            // khoá là enum → gõ sai là lỗi biên dịch
}
```

Hai cái bẫy, cả hai đều im lặng khi mắc phải:

1. **`@Builder` chỉ truyền tham chiếu — và do đó chỉ phản ứng với thay đổi state — khi nhận đúng một
   tham số dạng object.** Hai tham số rời là mất tính phản ứng, kể cả khi mỗi cái đều là object.
   Vì vậy mọi strategy trong dự án có chữ ký `(p: XParams)`.
2. **Gán lại kết quả `wrapBuilder()` vào cùng một biến state lần thứ hai không làm UI vẽ lại** —
   lần gán đầu thắng. Muốn đổi strategy lúc chạy thì đổi **khoá**, đừng đổi giá trị builder.

Năm chỗ dùng chung đúng cơ chế này:

| Chỗ dùng | Khoá | Giá trị |
|---|---|---|
| Ô của biểu mẫu | `FieldType` | leaf của ô |
| Lớp phủ | `OverlayId` | thân dialog · sheet · toast |
| Phần tử danh sách | discriminant của entity | bộ vẽ phần tử |
| Ranh giới bất đồng bộ | `ScreenStatus` | bốn nhánh loading · error · empty · ready |
| Theme | `ThemeId` | bảng token màu |

**Một cơ chế cho năm chỗ, thay vì năm cách làm cùng một việc.**

### 1.5 Style tái dùng là `AttributeModifier`

Lý do là kỹ thuật, không phải thẩm mỹ: `@Styles` và `@Extend` **không công bố được qua file**.
Một design system dùng chúng thì không dùng chung được — nó chỉ tồn tại trong đúng file khai ra nó.

```ts
// shared/uikit/modifier/CardModifier.ets
export class CardModifier implements AttributeModifier<ColumnAttribute> {
  applyNormalAttribute(a: ColumnAttribute): void {
    a.padding($r('app.float.space_m'))
    a.borderRadius($r('app.float.radius_m'))
    a.backgroundColor($r('app.color.surface'))
  }
}
```

`AttributeModifier` còn có `applyPressedAttribute` / `applyDisabledAttribute` / `applyFocusedAttribute` —
đó là chỗ đúng để khai các trạng thái ở [1.7](#17-sáu-trạng-thái-bắt-buộc), thay vì rải `if` trong `build()`.

### 1.6 Luật thăng hạng — không bao giờ sao chép rồi sửa

```
   dùng ở 1 chỗ         →  view/<Screen>/parts/
   dùng ở 2 màn 1 slice →  features/<ctx>/components/
   dùng ở 2 slice       →  shared/uikit/  (PR phải sửa CẢ HAI nơi dùng sang bản chung)
   chỉ còn 1 nơi dùng   →  hạ xuống, đừng để lại ở uikit
```

**Cần một biến thể thì thêm tham số vào bản chung, không fork.** Bản fork không có ai bảo trì:
lần sửa lỗi tiếp theo chỉ vá một trong hai bản, và không có gì báo cho bạn biết.

Nếu tham số thứ năm làm component khó hiểu hơn là hai component riêng — đó là dấu hiệu **hai thứ
khác nhau đang bị ép chung tên**, và lời giải là tách theo tên gọi đúng, không phải fork.

### 1.7 Sáu trạng thái bắt buộc

Mỗi primitive tương tác được phải khai đủ sáu trạng thái. Thiếu trạng thái không làm build gãy —
nó chỉ lộ ra ở tay người dùng.

| Trạng thái | Khai ở đâu | Hay quên vì |
|---|---|---|
| Mặc định | `applyNormalAttribute` | — |
| Nhấn | `applyPressedAttribute` | Máy phát triển bấm chuột, không thấy thiếu phản hồi chạm |
| Vô hiệu | `applyDisabledAttribute` + `.enabled(false)` | Thường bị làm bằng cách giấu component đi |
| Đang bận | `@Param loading: boolean` — khoá tương tác **và** hiện dấu hiệu | Nút gửi bấm được hai lần là lỗi hay gặp nhất |
| Focus | `applyFocusedAttribute` | Bàn phím ngoài và điều khiển từ xa không phải trường hợp hiếm trên HarmonyOS |
| Rỗng | chỉ với component chứa danh sách | Danh sách rỗng và danh sách đang tải trông giống nhau nếu không tách |

Cộng thêm hai ràng buộc đo được: vùng chạm ≥ token `touchTarget_min`, và mọi component tương tác có
`.accessibilityText($r('app.string.*'))` — nhãn tiếp cận **cũng là chuỗi dịch được**, xem [3.1](#31-chữ-được-phép-nằm-ở-đâu).

### 1.8 Danh mục khởi đầu

Danh sách này **đóng cho tới khi có PR sửa tài liệu**. Đó là thứ duy nhất ngăn `uikit` phình thành
ngăn kéo tạp — cùng một luật đã áp cho [`adapters/`](index.md#sáu-cư-dân-hợp-lệ-của-adapters).

| Primitive | Vai |
|---|---|
| `AppText` | Chữ + bậc kiểu chữ (`TypeScale`), chỉ nhận `Resource` |
| `AppButton` | Bốn biến thể: chính · phụ · chữ · nguy hiểm. Có `loading` |
| `AppIcon` | Bọc `SymbolGlyph`, tô màu theo token |
| `Field` | Khung một ô nhập: nhãn · dấu bắt buộc · trợ giúp · lỗi · vô hiệu. Thân do registry chọn |
| `AppCard` | Mặt phẳng có nền, bo góc, đệm theo token |
| `Chip` · `Badge` | Nhãn trạng thái ngắn |
| `Avatar` | Ảnh đại diện + dự phòng khi thiếu ảnh |
| `Skeleton` · `Spinner` | Hai kiểu chờ: có khung sẵn và không |
| `Divider` · `Spacer` | Chia và giãn theo token |

| Pattern | Vai |
|---|---|
| `AsyncBoundary` | Chọn 1 trong 4 nhánh theo `ScreenStatus` — [2.4](#24-bốn-trạng-thái-và-asyncboundary) |
| `ScreenScaffold` | `NavDestination` + thanh tiêu đề + vùng an toàn + xử lý back |
| `FormFrame` | Bố cục biểu mẫu + tóm tắt lỗi + nút gửi khoá theo `isValid` |
| `ListScaffold` | `Repeat` + kéo làm mới + nạp thêm + trạng thái rỗng |
| `OverlayHost` | Dialog · sheet · toast qua registry — [2.7](#27-lớp-phủ-do-viewmodel-mở) |
| `EmptyState` · `ErrorState` | Hai màn hình rỗng chuẩn: nội dung + hành động gợi ý |

### 1.9 Xong một component nghĩa là gì

- [ ] `@ComponentV2`, prop `@Param`/`@Require`, sự kiện `@Event`, state riêng `@Local`
- [ ] Prop chữ và màu kiểu `Resource` — không `string`, không hex
- [ ] Đủ sáu trạng thái ở [1.7](#17-sáu-trạng-thái-bắt-buộc)
- [ ] Không đọc store, không gọi module, không chạm `NavPathStack`
- [ ] Style qua `AttributeModifier`
- [ ] Có `.id()` theo quy ước `<màn>_<vai>` để test giao diện bắt được — [6](#6--kiểm-thử-tầng-ui)
- [ ] Nhìn đúng ở chế độ tối và ở cỡ chữ hệ thống lớn nhất

---

## 2 · Screen

### 2.1 Bốn phần của một màn hình

```
   route_map.json                 { name, pageSourceFile, buildFunction }
        │  name — cửa vào DUY NHẤT
        ▼
   XPage.ets                      @Builder toàn cục + NavDestination
        │                         KHÔNG file nào import XPage trực tiếp
        │  dựng ViewModel, truyền xuống
        ▼
   X.view.ets                     @ComponentV2 · @Param vm
        │                         vẽ qua AsyncBoundary
        ├──▶ parts/*.ets          nhận @Param, KHÔNG chạm store
        │
        └──▶ XViewModel.ets       @ObservedV2 · nơi duy nhất có tác dụng phụ
                                  KHÔNG có hàm build()
```

Bốn phần này bất biến qua mọi màn hình. Đó là lý do màn thứ bốn mươi đọc giống màn đầu tiên,
và là điều kiện để sinh khung màn mới bằng template thay vì chép tay.

| File | Vai | Luật |
|---|---|---|
| `XPage.ets` | Keo dán | Chỉ dựng ViewModel và gọi `XView({ vm })`. Tên `@Builder` **trùng** `buildFunction` trong route map |
| `XViewModel.ets` | ViewModel | `@ObservedV2`. Mọi tác dụng phụ ở đây. Không có `build()` |
| `X.view.ets` | View | `@ComponentV2`, nhận `@Param vm`, vẽ qua `AsyncBoundary` |
| `parts/*.ets` | Mảnh của View | Nhận `@Param`, phát `@Event`. Không biết ViewModel là gì |
| `string.json` | Chữ | Khoá tiền tố theo màn — [3.3](#33-quy-ước-khoá) |
| `route_map.json` | Route | Một mục cho một màn |

### 2.2 `route_map.json` — hợp đồng khai báo

```json
{
  "routerMap": [
    {
      "name": "LogDetail",
      "pageSourceFile": "src/main/ets/features/log/view/LogDetail/LogDetailPage.ets",
      "buildFunction": "LogDetailPageBuilder",
      "data": { "requiresAuth": "true" }
    }
  ]
}
```

| Luật | Vì sao |
|---|---|
| `name` là `PascalCase`, trùng tên màn | Nó là chuỗi duy nhất được viết ra khi điều hướng — đặt tên sai thì lỗi chỉ lộ lúc chạy |
| Một màn một mục, không mục nào dư | hvigor task đối chiếu hai chiều: mục không có file và file không có mục đều là lỗi build |
| Giữ file này dù chỉ có một HAP | Nó cho **nạp trang theo nhu cầu** — trang chưa vào thì chưa nạp |
| Tham số route là **định danh** | Ngăn xếp được hệ thống khôi phục sau khi tiến trình bị thu hồi; object đi kèm khi đó đã cũ — [2.6](#26-điều-hướng) |

### 2.3 Hình dạng chuẩn của ViewModel

```ts
@ObservedV2
export class LogDetailViewModel {
  @Trace private loading: boolean = true
  @Trace private failure: AppError | null = null
  @Trace data: Log | null = null

  @Computed get status(): ScreenStatus {          // → AsyncBoundary chọn 1 trong 4 nhánh
    if (this.loading) { return ScreenStatus.Loading }
    if (this.failure !== null) { return ScreenStatus.Error }
    return this.data === null ? ScreenStatus.Empty : ScreenStatus.Ready
  }

  async onSave(): Promise<void> { /* intent — không phải setter */ }
}
```

ViewModel **sở hữu** những thứ này và không chia cho ai:

| Sở hữu | Ghi chú |
|---|---|
| Cờ `loading` · `failure` · dữ liệu của màn | `@Trace`, để riêng — `@Computed status` suy ra từ chúng |
| Biểu mẫu (`FormViewModel`) | Kể cả màn chỉ có một ô nhập |
| Tham chiếu `NavPathStack` | View **không** giữ |
| Tay cầm `OverlayHost` | View **không** gọi dialog |
| Đăng ký cần huỷ (nếu có) | Huỷ trong `dispose()` — [2.5](#25-vòng-đời-một-màn-hình) |
| Ánh xạ mã lỗi → `$r('app.string.*')` | [3.4](#34-ba-tầng-của-một-thông-báo-lỗi) |

ViewModel **không** được: trả về thành phần giao diện · viết rule nghiệp vụ · gọi thẳng `rcp` hay
`relationalStore` · ghi vào store · **gán dữ liệu lấy từ `Ok` vào trường của mình**
(lý do ở [phần 4 của index](index.md#4--usecase-layer): nó tạo ra nguồn sự thật thứ hai).

### 2.4 Bốn trạng thái và `AsyncBoundary`

```
   Loading    chưa có gì để vẽ            → khung xương, không phải vòng xoay giữa màn trống
   Error      có lỗi, không có dữ liệu    → nội dung theo AppError.kind + nút thử lại
   Empty      gọi xong, dữ liệu rỗng      → lời mời hành động, không phải "không có dữ liệu"
   Ready      có dữ liệu để vẽ            → nội dung thật
```

Dùng `@Computed` chứ không phải ba cờ boolean rời rạc, vì cờ rời rạc cho phép tồn tại trạng thái
vô nghĩa (vừa đang tải vừa có lỗi), và trạng thái đó **sẽ** xuất hiện trong một tình huống tranh chấp
nào đó. `@Computed` làm nó **không biểu diễn được**.

Hai luật đi kèm, cả hai đều xuất phát từ [trình tự khởi động](index.md#trình-tự-tới-khung-hình-đầu-tiên) —
màn đầu vẽ **trước** khi dữ liệu về:

1. **Không màn nào được giả định dữ liệu đã sẵn sàng.** Trạng thái mở đầu luôn là `Loading`.
2. **Làm mới khi quay lại màn không được đưa về `Loading`** nếu store đã có dữ liệu. Nó là "làm mới im lặng":
   giữ nội dung cũ, cập nhật tại chỗ khi có dữ liệu mới. Đưa về `Loading` là làm màn hình nháy trắng
   mỗi lần bấm back.

### 2.5 Vòng đời một màn hình

`NavDestination` có đủ callback; việc là chọn đúng chỗ cho mỗi thứ:

| Callback | Việc đặt ở đây | Đừng đặt ở đây |
|---|---|---|
| `onWillAppear` | — | Gọi mạng: màn chưa hiện, người dùng có thể vuốt ngược lại ngay |
| `onAppear` | `vm.onEnter()` — nạp **lần đầu**, có cờ chặn gọi lại | — |
| `onShown` | Làm mới im lặng khi quay lại (xem 2.4) | Nạp lại từ đầu |
| `onWillHide` | Tạm dừng thứ tiêu tài nguyên: video, định vị, đo đạc | Huỷ request đang bay — nó ghi vào store, và store là của cả app |
| `onWillDisappear` | `vm.dispose()` — huỷ đăng ký, dừng timer | — |
| `onBackPressed` | Hỏi xác nhận khi biểu mẫu còn dở (`isDirty`), trả `true` để chặn | Logic nghiệp vụ |

> **Vì sao không huỷ request khi rời màn.** Đích của request là **store**, không phải màn hình.
> Huỷ nó là vứt đi một lần ghi mà màn khác đang chờ. Thứ phải huỷ là **đăng ký** và **timer** —
> tức những thứ trỏ ngược vào ViewModel đã chết.

### 2.6 Điều hướng

| Luật | Chi tiết |
|---|---|
| Chỉ **một** host điều hướng | `app/pages/Index.ets` giữ `Navigation` + `NavPathStack`. Không có `NavPathStack` thứ hai |
| Chỉ **ViewModel** đẩy/rút | `pathStack.pushPathByName(name, param)` · `pop()`. View gọi `@Event` |
| Tham số là **định danh**, không phải object | Ngăn xếp được khôi phục sau khi tiến trình bị thu hồi — object đi kèm khi đó đã cũ, id thì không bao giờ cũ |
| Kết quả trả về đi qua **store** | Màn con ghi qua repository; màn cha thấy vì nó đang quan sát store |
| `onPop` chỉ mang **id** | Trường hợp duy nhất được dùng: màn chọn (picker) trả về id vừa chọn. Không mang entity |
| Deep link ánh xạ ở `app/` | Một bảng `want` → `{ name, id }`. Bảng này biết nhiều context nên nó thuộc `app/`, không thuộc slice nào |

### 2.7 Lớp phủ do ViewModel mở

Dialog, sheet và toast **không** phải là thành phần được đặt trong `build()` của View — chúng là
**hành động**, và hành động thuộc ViewModel:

```ts
// trong XViewModel
async onDelete(): Promise<void> {
  const ok: boolean = await this.overlay.confirm(OverlayId.ConfirmDelete)
  if (!ok) { return }
  const r = await this.useCases.deleteLog(this.id)
  if (r instanceof Ok) { this.overlay.toast($r('app.string.logDetail_deleted')); this.stack.pop() }
}
```

`OverlayHost` sống ở `shared/uikit/overlay/`, tra `overlayRegistry` bằng `OverlayId`, và dựng thân
lớp phủ bằng `ComponentContent` + `wrapBuilder` — đúng cơ chế registry ở [1.4](#14-registry--một-cơ-chế-cho-mọi-chọn-theo-khoá).

Nó cần `UIContext`, mà **`@Builder` toàn cục không gọi được `getUIContext()`**. Chỗ bắt `UIContext`
đúng là nơi đã có nó sẵn: callback của `loadContent()` trong `EntryAbility` — cùng chỗ đặt theme
([4.3](#43-theme-đặt-một-lần)). Bắt một lần, cất vào `shared/runtime`, `OverlayHost` đọc từ đó.

### 2.8 Màn hình gộp nhiều context

Màn cần dữ liệu của ≥2 slice **không** được import hai slice vào một view.

```
   features/log/index.ets ──┐
                            ├──▶ adapters/readmodel/DashboardRead.ets ──▶ app/screens/Dashboard/
   features/collection/… ───┘         (gộp, không có rule nghiệp vụ)        Page · view · ViewModel
```

| Luật | Vì sao |
|---|---|
| Read model ở `adapters/readmodel/` | Không context nào **sở hữu** kết quả gộp |
| Màn ở `app/screens/`, không ở slice nào | Đặt nó vào `log` thì `log` phải biết `collection` tồn tại |
| Read model **không** có store riêng | Nó tính từ store của các slice; thêm store là thêm nguồn sự thật thứ hai |
| Thấy nhánh rẽ nghiệp vụ trong read model | Nó thuộc `policy/` — [tiêu chí loại trừ](index.md#tiêu-chí-loại-trừ) |

### 2.9 Bốn nguyên mẫu màn hình

| Nguyên mẫu | Nguồn dữ liệu | Pattern | Trạng thái rỗng nói gì | Lỗi hay gặp |
|---|---|---|---|---|
| **Danh sách** | Store của slice, qua `@Computed` lọc/sắp | `ListScaffold` + `Repeat` | Lời mời tạo mục đầu tiên | Lọc/sắp làm trong `build()` thay vì `@Computed` |
| **Chi tiết** | Một entity tra theo id từ tham số route | `AsyncBoundary` | "Mục này đã bị xoá" + đường về | Nhận entity qua tham số route thay vì id |
| **Biểu mẫu** | `FormViewModel` + rule của domain | `FormFrame` + `Field` | Không có — luôn `Ready` | Nút gửi bấm được hai lần vì thiếu trạng thái bận |
| **Tổng hợp** | Read model ở `adapters/` | Ghép nhiều `AsyncBoundary` | Từng khối rỗng riêng, không rỗng cả màn | Một khối lỗi làm hỏng cả màn |

Nguyên mẫu tổng hợp có luật riêng: **mỗi khối có `ScreenStatus` của chính nó.** Một khối gọi hỏng
không được kéo cả màn về `Error` — người dùng vẫn đọc được ba khối còn lại.

### 2.10 Xong một màn hình nghĩa là gì

- [ ] Có mục trong `route_map.json`, tên trùng `@Builder` của `XPage`
- [ ] Đủ bốn file: `XPage.ets` · `XViewModel.ets` · `X.view.ets` · khoá chuỗi trong `string.json`
- [ ] `status` là `@Computed`, và cả bốn nhánh đều đã vẽ thật — kể cả `Empty`
- [ ] Tham số route là id; mở lại màn sau khi tiến trình bị thu hồi vẫn đúng
- [ ] Biểu mẫu dở dang chặn back bằng hỏi xác nhận
- [ ] Không có chuỗi hiển thị, không có hex, không có số đo trần trong `.ets`
- [ ] `dispose()` huỷ hết đăng ký; rời màn rồi không còn gì trỏ vào ViewModel
- [ ] Chạy đúng ở chế độ tối và ở cỡ chữ hệ thống lớn nhất

---

## 3 · Localize

### 3.1 Chữ được phép nằm ở đâu

| Loại chữ | Sống ở | Không bao giờ ở |
|---|---|---|
| Nhãn, tiêu đề, nút, trợ giúp | `string.json` | `.ets` · `.ts` |
| Thông báo lỗi cho người dùng | `string.json`, tra bằng **mã lỗi** | `domain/` — nó không được biết ngôn ngữ |
| Nhãn tiếp cận (`accessibilityText`) | `string.json` | Bỏ trống, hoặc chép lại nhãn tiếng Anh |
| Số nhiều | `plural.json` | Ghép chuỗi bằng `if (n === 1)` |
| Ngày, số, tiền tệ | Hàm định dạng ở `shared/utils/format` | Chuỗi đã định dạng sẵn từ máy chủ |
| Mã kỹ thuật (`ERR_RATE_LIMIT`) | `.ts` — nó **không** dịch | `string.json` |
| Tên thương hiệu | Hằng trong `shared/kernel` | `string.json`, trừ khi thật sự có bản dịch |
| Nội dung người dùng nhập | Dữ liệu, đi qua entity | `string.json` |

**Luật gốc: không có chuỗi hiển thị nào trong `.ets` hay `.ts`.** Nó không phải mục tiêu đạo đức —
nó là điều kiện để [1.3](#13-kiểu-của-prop-cưỡng-chế-hai-luật-cùng-lúc) hoạt động: prop kiểu `Resource`
làm việc vi phạm trở thành **lỗi biên dịch**, không phải việc phải nhớ.

### 3.2 Cây tài nguyên

```
resources/
├── base/element/          BẮT BUỘC — bản dự phòng cuối cùng, phải ĐỦ MỌI KHOÁ
│   ├── string.json
│   ├── plural.json
│   ├── color.json
│   └── float.json
├── en_US/element/string.json      qualifier ngôn ngữ
├── vi_VN/element/string.json
├── dark/element/color.json        qualifier chế độ màu — xem phần 4
└── zh_CN/element/string.json
```

| Luật | Vì sao |
|---|---|
| `base/` phải có **đủ mọi khoá** | Máy dùng ngôn ngữ chưa dịch sẽ rơi về `base`. Thiếu khoá ở đó là màn trắng chữ, không phải chữ tiếng Anh |
| Tên file trong `element/` là **tập đóng** | `string.json` · `plural.json` · `color.json` · `float.json`… File tên tự đặt **không** được biên dịch thành tài nguyên |
| Không tách `string.json` theo màn | Hệ quả trực tiếp của dòng trên. Một file + khoá có tiền tố là **luật**, không phải giải pháp tạm |
| Tên tự do là chuyện của `rawfile/` | Và `rawfile/` không tra được bằng `$r` |

### 3.3 Quy ước khoá

| Khuôn | Dùng cho | Ví dụ |
|---|---|---|
| `<màn>_<vai>` | Chữ của một màn | `logDetail_title` · `logEdit_submit` |
| `common_<vai>` | Chữ dùng ở ≥3 màn | `common_cancel` · `common_retry` |
| `err_<miền>_<mã>` | Thông báo lỗi | `err_log_titleRequired` |
| `empty_<màn>_<vai>` | Nội dung màn rỗng | `empty_logList_title` |
| `a11y_<màn>_<vai>` | Nhãn tiếp cận | `a11y_logList_addButton` |
| `unit_<đơn vị>` | Đơn vị đo | `unit_megabyte` |

> **Không tái dùng khoá giữa hai màn chỉ vì tiếng Việt trùng chữ.** "Lưu" ở màn sửa hồ sơ và "Lưu"
> ở màn ghim bài viết là cùng một chữ trong tiếng Việt và **hai chữ khác nhau** trong phần lớn ngôn ngữ
> khác. Gộp khoá là quyết định không rút lại được mà không lần lại từng chỗ dùng.
> `common_*` chỉ dành cho chữ mà **nghĩa** dùng chung, không phải cho chữ mà **mặt chữ** trùng nhau.

### 3.4 Ba tầng của một thông báo lỗi

```
   domain (.ts)          shared/kernel (.ts)        shared/uikit/i18n (.ets)      resources
   ───────────────       ────────────────────       ────────────────────────      ─────────────
   LogRules.title()  ──▶  ErrorCode.Required   ──▶  errorText: Map<             ──▶ err_log_titleRequired
   trả MÃ, không                enum                  ErrorCode, Resource>          "Tiêu đề là bắt buộc"
   trả chuỗi                                        (bảng DUY NHẤT của app)
                                                             │
                                                             ▼
                                                     XViewModel gắn vào Field
```

| Tầng | Trách nhiệm | Cấm |
|---|---|---|
| `domain/` | Trả **mã lỗi** dạng `enum` | Chuỗi hiển thị, locale, `$r` |
| `shared/kernel` | Khai `ErrorCode` — `.ts` nên domain dùng được | — |
| `shared/uikit/i18n` | Bảng `ErrorCode → Resource`. **Một bảng cho cả app** | Rẽ nhánh nghiệp vụ |
| `viewmodel/` | Tra bảng, gắn `setFieldError()` hoặc mở toast | Tự viết chuỗi |

Thêm một ngôn ngữ = thêm một thư mục qualifier. **Không sửa một dòng nào ở `domain/`.**

Bảng ánh xạ phải **phủ hết** `ErrorCode`: `Map` trong ArkTS không được trình biên dịch kiểm đầy đủ,
nên đây là việc của hvigor task ([5](#5--enforce), rule L4) — đối chiếu thành viên của `enum` với
khoá của bảng, và với khoá thật trong `string.json`. Lỗi thiếu ánh xạ mà không kiểm sẽ hiện ra ở tay
người dùng dưới dạng một dòng trống.

`AppError` từ máy chủ đi cùng đường: `AppError.kind` + mã kỹ thuật → tra cùng bảng đó.
Trường `fields` của lỗi 422 ánh xạ ngược về đúng `setFieldError()` của từng ô.

### 3.5 Số nhiều, ngày giờ, con số

**Số nhiều** khai trong `plural.json`, không ghép bằng `if`:

```json
{ "plural": [
  { "name": "logList_itemCount", "value": [
    { "quantity": "one",   "value": "%d mục" },
    { "quantity": "other", "value": "%d mục" } ] } ] }
```

Tiếng Việt chỉ có nhánh `other`, tiếng Anh có `one`/`other`, tiếng Ả Rập có sáu. Đó chính là lý do
quy tắc số nhiều phải là **dữ liệu theo ngôn ngữ**, không phải `if` trong code — một `if` viết theo
tiếng Việt sẽ sai ở mọi ngôn ngữ còn lại, và không ai phát hiện cho tới lúc dịch.

**Dùng trực tiếp qua `$r`** (đã xác nhận — spike U1 ở [8](#8--cần-kiểm-chứng)):
`Text($r('app.plural.todoList_itemCount', n, n))`, dựng bên trong một `@Computed` getter của
ViewModel — tham số đầu chọn nhánh số nhiều, tham số sau điền vào `%d`. Không cần lớp bọc trong
`shared/uikit/i18n`; `count` vẫn ở lại `@Trace`, chỉ `Resource` mới được suy ra lúc vẽ.

**Ngày giờ, số, tiền tệ, thời gian tương đối** đi qua `shared/utils/format` (`.ts` thuần, dùng `intl`):

| Luật | Vì sao |
|---|---|
| Hàm định dạng **nhận `locale` làm tham số**, không tự đọc ngôn ngữ hệ thống | Nó thành hàm thuần → test được ở Local Test, không cần thiết bị |
| ViewModel định dạng **lúc vẽ**, không lúc nạp | Đổi ngôn ngữ lúc chạy phải cập nhật được — [3.6](#36-đổi-ngôn-ngữ-lúc-chạy) |
| Chuỗi đã định dạng **không** được cất vào `@Trace` | Cất là đóng băng ngôn ngữ tại thời điểm nạp |
| Máy chủ trả **giá trị thô** (ISO 8601, số), không trả chuỗi đã định dạng | Máy chủ không biết ngôn ngữ và múi giờ của máy |

Cụ thể: giữ `@Trace createdAt: number` và phơi `@Computed get createdAtText()`. Đây là cùng một luật
với `status` ở [2.3](#23-hình-dạng-chuẩn-của-viewmodel) — thứ suy ra được thì không cất.

### 3.6 Đổi ngôn ngữ lúc chạy

| Nguồn | Cách đặt | Ghi ở đâu |
|---|---|---|
| Ngôn ngữ hệ thống | Mặc định, không làm gì | — |
| Người dùng chọn trong app | `i18n.System.setAppPreferredLanguage(tag)` — **đã xác nhận (spike U4 ở [8](#8--cần-kiểm-chứng))**: đặt một **tag cụ thể** áp ngay cho mọi màn đang mở; đặt `default` chỉ có hiệu lực ở lần khởi động nguội kế tiếp | Cài đặt của app này là volatile — **không** ghi `preferences`; khởi động nguội luôn là "theo hệ thống". Bộ chọn ở Settings vì vậy chỉ có English / Tiếng Việt |

Ba luật để việc đổi ngôn ngữ không cần khởi động lại:

1. **`$r(...)` là giá trị lười.** Component giữ `Resource`, ArkUI phân giải lúc vẽ. Đổi ngôn ngữ →
   cấu hình đổi → vẽ lại → ra chuỗi mới, **không một dòng code nào tham gia**.
2. **`getStringSync()` bị cấm ngoài `shared/uikit/i18n`.** Nó phân giải **ngay**, và giá trị trả về là
   `string` — đúng thứ bị đóng băng. Chỗ duy nhất buộc phải dùng nó là nơi phải nói chuyện với API
   nhận `string` (ví dụ nội dung thông báo hệ thống), và nơi đó thì gọi lại mỗi lần dùng.
3. **Cấu hình có đúng một điểm nhận.** `EntryAbility.onConfigurationUpdate` → `AppearanceStore`
   ([4.7](#47-một-điểm-nhận-một-điểm-áp-dụng)). Không component nào tự đọc `Configuration`.

### 3.7 Hướng đọc

Áp ngay cả khi hôm nay chưa có ngôn ngữ viết phải-sang-trái — chi phí bằng không lúc viết mới,
và bằng một lần rà toàn bộ codebase nếu để sau:

| Luật | Thay cho |
|---|---|
| Đệm và lề dùng `start` / `end` (`LocalizedPadding`, `LocalizedMargin`, `LengthMetrics`) | `left` / `right` |
| Căn chữ `TextAlign.Start` | `TextAlign.Left` |
| Hướng của vật chứa: `.direction(Direction.Auto)` | Cố định `Ltr` |
| Icon có hướng (mũi tên back, "tiếp theo") bật lật gương | Dùng chung một ảnh cho cả hai hướng |
| Icon **không** có hướng (máy ảnh, tim) **không** lật | Lật tất cho tiện |

### 3.8 Chuỗi từ máy chủ và từ người dùng

| Nguồn | Cách xử |
|---|---|
| Thông báo lỗi của máy chủ | **Không hiện thô.** Ánh xạ qua mã ([3.4](#34-ba-tầng-của-một-thông-báo-lỗi)); mã lạ → chuỗi chung `err_common_unknown`, mã thật ghi vào log |
| Nội dung do người dùng nhập | Hiện thô — nó là dữ liệu. Không đưa vào `string.json`, không dịch |
| Nội dung do máy chủ soạn để hiển thị (thông báo đẩy, banner) | Máy chủ phải chọn ngôn ngữ theo tuỳ chọn tài khoản; client gửi ngôn ngữ hiện hành khi đăng ký |

### 3.9 Kiểm chuỗi bằng máy

| Kiểm | Cách |
|---|---|
| Khoá thiếu ở một qualifier | So khớp tập khoá của mọi `string.json` với `base/` — thiếu là **lỗi build** |
| Khoá thừa (đã dịch nhưng không ai dùng) | Đối chiếu khoá với các lần `$r('app.string.…')` — cảnh báo, không chặn |
| Chuỗi cứng trong `.ets` | Chặn chuỗi literal ở vị trí chữ hiển thị — [5](#5--enforce), rule L3 |
| `ErrorCode` không có bản dịch | Rule L4 |
| Chữ dài làm vỡ bố cục | Bản giả lập kéo dài ~30% dựng từ `base/` vào một qualifier thử — chạy tay trước mỗi lần phát hành |

---

## 4 · Application appearance

### 4.1 Token là tài nguyên, không phải TypeScript

| Nhóm | File | Khuôn tên | Ví dụ |
|---|---|---|---|
| Màu | `color.json` | theo **vai trò** | `background` · `backgroundEmphasize` · `surface` · `onSurface` · `border` · `brand` · `danger` · `warning` · `success` · `disabled` |
| Khoảng cách | `float.json` | `space_<bậc>` | `space_xs` `space_s` `space_m` `space_l` `space_xl` |
| Bo góc | `float.json` | `radius_<bậc>` | `radius_s` `radius_m` `radius_full` |
| Cỡ chữ | `float.json` | `font_<bậc>` | `font_body` `font_title` `font_caption` — đơn vị **`fp`** |
| Kích thước | `float.json` | `size_<vai>` | `size_icon_m` · `touchTarget_min` |

```
base/element/color.json                       base/element/float.json
─────────────────────────                     ─────────────────────────
{ "color": [                                  { "float": [
  { "name": "background", "value": "#FFF4F6F6" },   { "name": "space_m",   "value": "16vp" },
  { "name": "surface",    "value": "#FFFFFFFF" },   { "name": "radius_m",  "value": "12vp" },
  { "name": "onSurface",  "value": "#FF14191A" }    { "name": "font_body", "value": "16fp" }
] }                                           ] }

   Màu là ARGB 8 chữ số · số đo mang đơn vị trong chuỗi: vp cho khung, fp cho chữ
```

`gray100` không nói nó dùng để làm gì; `backgroundEmphasize` thì có. Tên theo vai trò còn là điều kiện
để có bảng token thứ hai cho chế độ tối mà **không** phải đổi tên gì.

**Thứ không làm được bằng tài nguyên** — đường cong chuyển động, bóng đổ, dải màu — sống ở
`shared/uikit/token/*.ets` dưới dạng hằng. Chúng vẫn là token: luật "không viết giá trị trần trong
feature" áp y hệt, chỉ khác chỗ cất.

### 4.2 Ba nguồn quyết định sáng hay tối

| Nguồn | Cách | Phạm vi | Khi nào dùng |
|---|---|---|---|
| Hệ thống | qualifier `dark/element/color.json` | Cả app | **Mặc định.** Không một dòng code nào |
| Người dùng chọn trong app | `applicationContext.setColorMode(ConfigurationConstant.ColorMode.*)` | Cả app | Khi sản phẩm cần mục "Sáng · Tối · Theo hệ thống" |
| Ép cục bộ một màn | `WithTheme({ colorMode: ThemeColorMode.DARK })` | Một cây component | Màn xem ảnh, trình phát video — luôn tối bất kể cài đặt |

Ba nguồn xếp chồng theo đúng thứ tự đó: nguồn dưới ghi đè nguồn trên, và **chỉ trong phạm vi của nó**.

Lựa chọn của người dùng lưu ở `preferences` và được áp trong **task khởi động đầu tiên**, trước khung
hình đầu ([trình tự khởi động](index.md#trình-tự-tới-khung-hình-đầu-tiên), bước 1). Áp muộn hơn thì
người dùng thấy một nháy sáng trước khi màn chuyển tối — lỗi này không gãy gì cả, và ai cũng nhận ra.

### 4.3 Theme đặt một lần

```ts
// shared/uikit/token/AppColors.ets
export class AppColors implements CustomColors {
  brand: ResourceColor = $r('app.color.brand')          // chỉ ghi đè token cần đổi
  backgroundEmphasize: ResourceColor = $r('app.color.backgroundEmphasize')
}

// app/EntryAbility.ets — trong callback của loadContent, cùng chỗ bắt UIContext (2.7)
ThemeControl.setDefaultTheme(appTheme)
```

| Luật | Vì sao |
|---|---|
| `ThemeControl.setDefaultTheme()` gọi **một lần** ở composition root | Gọi rải rác thì thứ tự quyết định kết quả, và thứ tự thay đổi theo lần build |
| Theme cục bộ dùng `WithTheme`, không gọi lại `setDefaultTheme` | `WithTheme` có phạm vi rõ ràng và tự trả lại khi ra khỏi cây |
| Nhiều thương hiệu thì khoá bằng `ThemeId` qua registry ([1.4](#14-registry--một-cơ-chế-cho-mọi-chọn-theo-khoá)) | Vẫn một cơ chế, không thêm cách làm mới |
| **Không** đọc token màu vào biến TypeScript rồi truyền đi | Biến đóng băng giá trị; `Resource` thì không |

### 4.4 Cỡ chữ hệ thống và khả năng tiếp cận

| Luật | Chi tiết |
|---|---|
| Chữ dùng **`fp`**, khung dùng **`vp`** | `fp` co giãn theo cài đặt cỡ chữ của máy, `vp` thì không |
| Không đặt `height` cứng cho vật chứa có chữ | Cỡ chữ lớn → chữ bị cắt. Dùng `constraintSize` với `minHeight` |
| Chữ dài phải khai `maxLines` + `textOverflow` | Không khai thì bố cục vỡ ở ngôn ngữ dài hơn |
| Vùng chạm ≥ `touchTarget_min` | Icon 16vp vẫn cần vùng chạm lớn hơn nó |
| Mọi thứ bấm được có `accessibilityText` | Và nhãn đó là `Resource` — [3.1](#31-chữ-được-phép-nằm-ở-đâu) |
| Không dùng **riêng** màu để mang thông tin | Trạng thái lỗi cần cả icon hoặc chữ, không chỉ viền đỏ |

Bài kiểm rẻ nhất và bắt được nhiều lỗi nhất: mở máy, kéo cỡ chữ hệ thống lên mức lớn nhất, đi qua
mọi màn. Bố cục vỡ ở đây là bố cục có `height` cứng ở chỗ không nên có.

**`fp` chỉ co giãn khi `configuration.json` khai `followSystem`** — mặc định của hệ thống là
**không** theo cỡ chữ hệ thống (`nonFollowSystem`), đã xác nhận ở spike U3 ([8](#8--cần-kiểm-chứng)).
App hero-todo khai `followSystem` trong `AppScope/resources/base/profile/configuration.json` và
không đặt trần (`fontSizeMaxScale: 3.2`) — R12 yêu cầu không cắt chữ ở mức lớn nhất, một trần thấp
hơn sẽ che đúng lỗi mà luật này tồn tại để bắt.

### 4.5 Nhiều kích thước cửa sổ

| Việc | Cách | Đặt ở đâu |
|---|---|---|
| Bậc chiều rộng | `GridRow`/`GridCol` với `sm` · `md` · `lg`, hoặc `onBreakpointChange` | Trong View — đây là bố cục thuần, **không** phải nghiệp vụ |
| Danh sách + chi tiết cạnh nhau | `Navigation` đặt `NavigationMode.Auto` | `app/pages/Index.ets` — một chỗ, mọi màn hưởng |
| Máy gập, đa cửa sổ | Nghe thay đổi kích thước cửa sổ, đưa vào `AppearanceStore` | `shared/runtime` → `@Computed` ở ViewModel nếu cần |
| Xoay màn | Bố cục co giãn thay vì bố cục cố định | View |

> Rẽ nhánh theo bậc màn hình **được phép nằm trong View** — nó không phải nhánh rẽ nghiệp vụ.
> Phép thử ở [tiêu chí loại trừ](index.md#tiêu-chí-loại-trừ) vẫn dùng được: người làm sản phẩm
> tranh luận về "màn rộng thì hiện hai cột" là tranh luận **thiết kế**, không phải nghiệp vụ.

### 4.6 Ảnh và biểu tượng

| Loại | Cách | Vì sao |
|---|---|---|
| Biểu tượng giao diện | `SymbolGlyph` với `$r('sys.symbol.*')` | Tô màu bằng token → tự đúng ở chế độ tối, không cần hai bộ ảnh |
| Ảnh minh hoạ | `$r('app.media.*')`, ưu tiên vector | Một file cho mọi mật độ màn hình |
| Ảnh bitmap cần bản tối riêng | Cùng tên, đặt thêm ở `dark/media/` | Hệ thống tự chọn, không có `if` trong code |
| Ảnh từ mạng | Có ảnh giữ chỗ **và** ảnh dự phòng khi hỏng | Ô trống là lỗi hay gặp nhất của màn danh sách |

### 4.7 Một điểm nhận, một điểm áp dụng

```
   Hệ điều hành ──▶ EntryAbility.onConfigurationUpdate(cfg)      ← ĐIỂM NHẬN DUY NHẤT
                          │   ngôn ngữ · chế độ màu · cỡ chữ · hướng · kích thước
                          ▼
                    AppearanceStore  (AppStorageV2 — @ObservedV2 + @Trace)
                          │
                          ▼
                    @Computed ở ViewModel  ──▶  View vẽ lại
```

**Không component nào tự đọc `Configuration`.** Lý do giống hệt lý do chỉ repository được ghi vào
store: nhiều điểm đọc thì có nhiều bản sao, và các bản sao lệch nhau trong đúng lúc cấu hình đổi —
tức lúc duy nhất chuyện này quan trọng.

Phần lớn màn hình **không cần biết** cấu hình đã đổi: `$r` tự phân giải lại khi vẽ. `AppearanceStore`
chỉ dành cho thứ code thật sự phải rẽ nhánh — bậc màn hình, trạng thái gập.

### 4.8 Lưu lựa chọn của người dùng

| Thứ | Lưu ở | Áp lúc nào | Ai giữ |
|---|---|---|---|
| Sáng · Tối · Theo hệ thống | `preferences` | Task khởi động **đầu tiên**, trước khung hình đầu | `AppearanceService` ở `shared/runtime` |
| Ngôn ngữ trong app | `preferences` | Cùng chỗ | `AppearanceService` |
| Cỡ chữ | Không lưu — theo hệ thống | — | — |

`AppearanceService` là một **port hạ tầng**, đi vào ViewModel của màn cài đặt bằng constructor
injection qua `AppModules`, đúng như mọi port khác ([DI](index.md#7--di--ioc)). Màn cài đặt sống ở
`app/screens/Settings/` vì nó chạm cấu hình cấp ứng dụng chứ không thuộc context nghiệp vụ nào.

---

## 5 · Enforce

Bảng tầng import ở [phần 1 của index](index.md#bảng-tầng-import) đã chặn chuyện "ai import ai".
Mười rule dưới đây là phần còn lại, riêng của tầng UI — kiểm được bằng quét văn bản, nên chúng thuộc
cùng hvigor task, và chuyển sang `code-linter.json5` nếu `extRuleSet` dùng được.

| # | Rule | Cách kiểm | Mức |
|---|---|---|---|
| L1 | Không mã màu trần trong `.ets` | Quét `#[0-9a-fA-F]{3,8}` | lỗi |
| L2 | Không `@Styles` / `@Extend` trong `shared/uikit` | Quét decorator | lỗi |
| L3 | Không chuỗi literal ở vị trí chữ hiển thị | Quét `Text('…')`, `.label('…')`, `.placeholder('…')` | lỗi |
| L4 | Mọi `ErrorCode` có ánh xạ và có khoá thật trong `string.json` | Đối chiếu `enum` ↔ bảng ↔ khoá | lỗi |
| L5 | Mọi khoá của `base/` có mặt ở mọi qualifier ngôn ngữ | So khớp tập khoá | lỗi |
| L6 | `route_map.json` ↔ file `XPage.ets` khớp hai chiều | Đối chiếu `buildFunction` với `@Builder` toàn cục | lỗi |
| L7 | `getStringSync` chỉ xuất hiện trong `shared/uikit/i18n` | Quét tiền tố đường dẫn | lỗi |
| L8 | Không `LazyForEach` — dùng `Repeat` | Quét định danh | lỗi |
| L9 | Không `@Provider` / `@Consumer` | Quét decorator | lỗi |
| L10 | Không số đo trần ngoài `shared/uikit` | Quét `.padding(16)`, `.width(200)`… | cảnh báo |
| L11 | Khoá chuỗi không ai dùng | Đối chiếu khoá ↔ `$r('app.string.…')` | cảnh báo |

L1 và L3 cùng nhau khoá lại hai luật lớn nhất của tài liệu này: **màu luôn dịch được sang chế độ tối,
chữ luôn dịch được sang ngôn ngữ khác** — và cả hai thành lỗi build thay vì việc phải nhớ khi review.

---

## 6 · Kiểm thử tầng UI

| Chỗ | Không cần thiết bị (`src/test`) | Cần thiết bị (`src/ohosTest`) |
|---|---|---|
| Hàm định dạng ngày/số | ✅ vì nhận `locale` làm tham số ([3.5](#35-số-nhiều-ngày-giờ-con-số)) | — |
| Rule của biểu mẫu | ✅ — chúng ở `domain/`, là hàm thuần | — |
| ViewModel | — | ✅ `@ObservedV2` cần môi trường ArkUI |
| Bốn nhánh của `AsyncBoundary` | — | ✅ mỗi màn phải có test cho **cả bốn**, kể cả `Empty` |
| Điều hướng và khôi phục ngăn xếp | — | ✅ gồm cả lần mở lại sau khi tiến trình bị thu hồi |
| Chế độ tối · cỡ chữ lớn nhất | — | ✅ rà tay trước mỗi lần phát hành |

Test giao diện tìm phần tử qua `.id()`, nên quy ước đặt `id` là **hợp đồng test**, không phải trang trí:
`<màn>_<vai>` — `logList_addButton`, `logEdit_titleField`. Trùng khuôn với khoá chuỗi ở
[3.3](#33-quy-ước-khoá) để một màn chỉ có một bộ từ vựng.

---

## 7 · Checklist

**Component** → [1.9](#19-xong-một-component-nghĩa-là-gì) · **Màn hình** → [2.10](#210-xong-một-màn-hình-nghĩa-là-gì)

**Trước khi mở PR có đụng tầng UI:**

- [ ] Không hex, không chuỗi hiển thị, không số đo trần trong `.ets` mới
- [ ] Khoá chuỗi mới có mặt ở `base/` **và** mọi qualifier ngôn ngữ
- [ ] Component mới ở đúng tầng theo [1.6](#16-luật-thăng-hạng--không-bao-giờ-sao-chép-rồi-sửa) — không có bản fork nào
- [ ] Màn mới có mục route, đủ bốn trạng thái, tham số là id
- [ ] Đã xem ở chế độ tối và ở cỡ chữ hệ thống lớn nhất
- [ ] Đệm/lề dùng `start`/`end`, không `left`/`right`

---

## 8 · Cần kiểm chứng

Cùng quy ước với [phần 13 của artifact nguồn](index.md): ghi rõ chỗ nào tài liệu chưa dám chốt,
và cách kiểm mất bao lâu.

**Cả năm mục dưới đây đã chốt** — mỗi hàng trích nguồn spike đã ghi quyết định, xem file spike để
đọc phần Investigation/Decision đầy đủ.

| # | Câu hỏi | Kết luận (đã chốt) | Nguồn |
|---|---|---|---|
| U1 | `$r('app.plural.x', n)` dùng trực tiếp được, hay phải qua `resourceManager.getPluralStringValue`? | **Có.** Dùng thẳng `$r('app.plural.todoList_itemCount', n, n)` trong một `@Computed` getter của ViewModel — không cần lớp bọc trong `shared/uikit/i18n`. Cập nhật [3.5](#35-số-nhiều-ngày-giờ-con-số): ví dụ số nhiều nay có thêm dạng `$r(key, n, n)`. | `shapeup/hero-todo/shaping/spike-U1-plural-via-r.md` |
| U2 | `@BuilderParam` có dùng được trong `@ComponentV2` không? | **Có**, cho **slot cố định** (đúng một vùng nội dung con, không chọn theo khoá): `@Require @BuilderParam`. **Slot chọn theo khoá** (ô biểu mẫu, thân lớp phủ, phần tử danh sách, nhánh trạng thái, theme) vẫn giữ registry — `WrappedBuilder` qua `@Param`, đúng cơ chế ở [1.4](#14-registry--một-cơ-chế-cho-mọi-chọn-theo-khoá). Cập nhật [1.2](#12-hợp-đồng-của-một-component): hàng "Nội dung con" nay tách hai trường hợp. | `shapeup/hero-todo/shaping/spike-U2-builderparam-in-v2.md` |
| U3 | Có chặn được mức co giãn cỡ chữ ở mức ứng dụng không? | **Có, chặn được** (`AppScope/resources/base/profile/configuration.json` — `fontSizeScale` · `fontSizeMaxScale`) — nhưng mặc định của hệ thống là **`nonFollowSystem`** (không theo hệ thống) trừ khi app tự khai `followSystem`. App hero-todo khai `followSystem` và **không** đặt trần (`fontSizeMaxScale: 3.2`) vì R12 yêu cầu không cắt chữ ở mức lớn nhất. Cập nhật [4.4](#44-cỡ-chữ-hệ-thống-và-khả-năng-tiếp-cận): thêm dòng về mặc định không theo hệ thống. | `shapeup/hero-todo/shaping/spike-U3-font-scale-cap.md` |
| U4 | `setAppPreferredLanguage` có làm mọi màn đang mở vẽ lại ngay, hay cần dựng lại UI? | **Có, với tag cụ thể** — mọi `$r` đang mở vẽ lại ngay, không cần dựng lại `NavPathStack`. Đặt lại `default` chỉ có hiệu lực ở lần khởi động nguội tiếp theo. Vì cài đặt của app này là volatile (không ghi `preferences`), màn hình khởi động nguội luôn *là* "theo hệ thống", nên bộ chọn ngôn ngữ ở Settings chỉ có hai lựa chọn: English / Tiếng Việt. Cập nhật [3.6](#36-đổi-ngôn-ngữ-lúc-chạy): hàng "Người dùng chọn trong app" nay ghi rõ tag cụ thể áp ngay, `default` chờ khởi động nguội. | `shapeup/hero-todo/shaping/spike-U4-language-switch-redraw.md` |
| U5 | `extRuleSet` của `code-linter.json5` dùng được từ bản DevEco nào? | **Có, từ DevEco Studio 5.1.0 Release** — nhưng pitch này vẫn giữ L1–L11 là hvigor task (build-time); port sang Code Linter là raw idea riêng cho Betting Table, không nằm trong appetite này. | `shapeup/hero-todo/shaping/spike-U5-linter-extRuleSet.md` |

Bốn mục đầu **không** làm thay đổi kiến trúc dù kết quả ra sao — chúng chỉ quyết định có phải viết
thêm một lớp bọc mỏng trong `shared/uikit/i18n` hay không, và không mục nào trong bốn mục đó cần
lớp bọc. Mục U5 quyết định rule chạy **lúc gõ** hay **lúc build**, và pitch này giữ nguyên lúc build.

---

## Phụ lục · Cây thư mục tầng UI

```
entry/src/main/
├── resources/
│   ├── base/element/            string.json · plural.json · color.json · float.json   ← ĐỦ MỌI KHOÁ
│   ├── dark/element/color.json  chỉ token màu đổi theo chế độ tối
│   ├── vi_VN/element/string.json · en_US/… · zh_CN/…
│   ├── base/media/ · dark/media/
│   └── base/profile/route_map.json
│
└── ets/
    ├── app/
    │   ├── EntryAbility.ets              loadContent → ThemeControl + bắt UIContext + onConfigurationUpdate
    │   ├── pages/Index.ets               Navigation + NavPathStack — host DUY NHẤT
    │   └── screens/
    │       ├── Dashboard/                màn gộp ≥2 context, dữ liệu từ adapters/readmodel
    │       └── Settings/                 màn cài đặt: chế độ màu · ngôn ngữ
    │
    ├── features/log/
    │   ├── viewmodel/LogDetailViewModel.ets
    │   ├── view/LogDetail/
    │   │   ├── LogDetailPage.ets         @Builder toàn cục + NavDestination
    │   │   ├── LogDetail.view.ets        @ComponentV2 · @Param vm · AsyncBoundary
    │   │   └── parts/LogHeader.ets       @Param vào · @Event ra
    │   └── components/LogCard.ets        organism riêng slice
    │
    └── shared/uikit/
        ├── token/       AppColors.ets (CustomColors) · Motion.ets · Shadows.ets
        ├── primitive/   AppText · AppButton · AppIcon · Field · AppCard · Skeleton…
        ├── modifier/    CardModifier · PressableModifier…
        ├── pattern/     AsyncBoundary · ScreenScaffold · FormFrame · ListScaffold · OverlayHost
        ├── registry/    fieldRegistry · overlayRegistry · statusRegistry · themeRegistry
        └── i18n/        ErrorText.ets (ErrorCode → Resource) · chỗ DUY NHẤT được getStringSync
```
