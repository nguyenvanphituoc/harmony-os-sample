# Codebase Design — HarmonyOS Client

Tài liệu mô tả **codebase trông như thế nào**: có những tầng nào, mỗi tầng gồm loại file gì,
hợp đồng giữa chúng ra sao, và ai được gọi ai.

File này là **index** — mỗi phần bên dưới là bản tóm tắt đủ để bắt đầu viết code,
và trỏ tới tài liệu chi tiết tương ứng.

---

## Nền tảng

| Hạng mục | Lựa chọn |
|---|---|
| Ngôn ngữ | **ArkTS** — tập con bị siết của TypeScript |
| Khung UI | **ArkUI**, mô hình khai báo, **state management V2** |
| Đóng gói | **Một HAP kiểu `entry` duy nhất** — không HAR, không HSP |
| Phiên bản SDK | `compatibleSdkVersion` 22 · `compileSdkVersion` và `targetSdkVersion` 23 |
| Điều hướng | `Navigation` + `NavPathStack`, khai báo màn hình qua `route_map.json` |
| Khởi tạo | **AppStartup** — `startup_config.json`, khai báo qua `appStartup` trong `module.json5` |
| Lưu bền | `relationalStore` · `preferences` · `PersistenceV2` · **Asset Store Kit** |
| Mạng | **Remote Communication Kit** (`rcp`) |
| Kiểm chất lượng | **hvigor** task tự viết · `code-linter.json5` |

### Quy ước phần mở rộng file

| Phần mở rộng | Dùng cho | Vì sao |
|---|---|---|
| `.ts` | `domain/` · `data/` · `policy/` · `shared/kernel` · `shared/utils` | Không chạm được ArkUI |
| `.ets` | `state/` · `viewmodel/` · `view/` · `components/` · `shared/runtime` · `shared/uikit` · `app/` | Cần decorator ArkUI |

> **`.ts` không import được `.ets`**; chiều ngược lại thì được. Đây là ràng buộc của ngôn ngữ,
> và là lý do các tầng nghiệp vụ được đặt ở `.ts`: **trình biên dịch** — chứ không phải quy ước —
> bảo đảm chúng không bao giờ chạm ArkUI. Trong mô hình một HAP, đây là luật tầng **cứng duy nhất** còn lại.

---

## Bản đồ tầng

```
              ┌───────────────────────────────────────────────────────────┐
   UI         │  app/  ·  features/*/view  ·  features/*/viewmodel        │
              │  features/*/components  ·  shared/uikit                   │
              └───────────────────────────────────────────────────────────┘
                    │  gọi use case qua XModule của slice
                    │  không bao giờ gọi thẳng repository
                    ▼
              ┌───────────────────────────────────────────────────────────┐
   CORE       │  features/*/domain  ·  policy/                       .ts  │
   (nghiệp vụ)│  entity · rules · port · use case                         │
              └───────────────────────────────────────────────────────────┘
                    │  gọi qua port (interface); hiện thực được tiêm vào
                    ▼
              ┌───────────────────────────────────────────────────────────┐
   DATA       │  features/*/data                                    .ts   │
              │  codec · remote · dao · repository impl                   │
              │  features/*/state  — nguồn sự thật trong máy        .ets  │
              └───────────────────────────────────────────────────────────┘
                    ▲
                    │  @Trace phát tín hiệu → @Computed tính lại → View vẽ lại
                    │
              ┌───────────────────────────────────────────────────────────┐
   ADAPTER    │  adapters/       — bắc cầu ≥2 context                     │
              │  shared/runtime  — cơ chế, không biết context nào         │
              └───────────────────────────────────────────────────────────┘
```

---

## Mục lục

| # | Phần | Nội dung | Chi tiết |
|---|---|---|---|
| 1 | [Architecture](#1--architecture) | Tầng, chiều phụ thuộc, luật import | `architecture.md` 🕐 |
| 2 | [Feature organize](#2--feature-organize) | Vertical slice, cây thư mục, public API | `feature-organize.md` 🕐 |
| 3 | [Domain layer](#3--domain-layer) | Entity, rules, port | `domain-layer.md` 🕐 |
| 4 | [Usecase layer](#4--usecase-layer) | Hàm nghiệp vụ, kiểu trả về `Result` | `usecase-layer.md` 🕐 |
| 5 | [Repository layer](#5--repository-layer) | Điều phối remote · codec · DAO · store | `repository-layer.md` 🕐 |
| 6 | [Adapter](#6--adapter) | Keo dán bắc cầu context, EventBus | `adapter.md` 🕐 |
| 7 | [DI / IoC](#7--di--ioc) | Constructor injection, composition root | `di-composition-root.md` 🕐 |
| 8 | [UI layer](#8--ui-layer) | Component · Screen · Localize · Appearance | [`ui-layer.md`](ui-layer.md) ✅ |
| — | [Thuật ngữ](#thuật-ngữ-harmonyos) | Bảng tra thuật ngữ HarmonyOS | — |

🕐 = chưa viết · ✅ = đã viết

---

## 1 · Architecture

**Bốn tầng, một chiều phụ thuộc.** Mỗi tầng chỉ biết tầng dưới nó.

Trong đồ thị **gọi hàm** không có mũi tên đi lên. Dữ liệu mới quay lại màn hình bằng
**cơ chế quan sát của ArkUI state management V2**, không bằng giá trị trả về:

```
   View ──── intent ────▶ ViewModel ──▶ Use case ──▶ Repository ──▶ Store
    ▲          (@Event)                   (port)                      │
    │                                                                 │
    └── vẽ lại ◀── @Computed tính lại ◀── @Trace phát tín hiệu ◀───────┘
```

Ba khái niệm trả lời ba câu hỏi khác nhau và không cạnh tranh nhau:

| Khái niệm | Trả lời | Hiện thân trong codebase |
|---|---|---|
| Clean Architecture | *ai được import ai* | Bảng tầng import + quy ước `.ts` / `.ets` |
| MVVM | *một màn hình nói chuyện với dữ liệu thế nào* | Bộ ba Page · ViewModel · View |
| Vertical slice | *file này nằm ở đâu* | `features/<context>/` |

### Bảng tầng import

| Thư mục | Được import | Không được import | Ai giữ |
|---|---|---|---|
| `features/*/domain/**` | `shared/kernel` · `policy/` | mọi `.ets` · mọi Kit (`@kit.*`) · `data` · `state` | trình biên dịch |
| `policy/**` | `shared/kernel` | mọi thứ khác | trình biên dịch |
| `features/*/data/**` | `domain` cùng slice · `shared/kernel` · `shared/runtime` | `state` · `viewmodel` · `view` · slice khác | hvigor |
| `features/*/state/**` | `domain` cùng slice · `shared/kernel` | `data` · mạng · CSDL · slice khác | hvigor |
| `features/*/viewmodel/**` | `domain` và `state` cùng slice · `shared/uikit` · `shared/kernel` | `rcp` · `relationalStore` · `data` của slice khác | hvigor |
| `features/*/view/**` | `viewmodel` cùng slice · `shared/uikit` | `state` · `data` · `AppStorageV2` · `NavPathStack` | hvigor |
| `features/A/**` | — | `features/B/**` — bất kỳ đường nào | hvigor |
| `adapters/**` | `features/*/index.ets` · `shared/**` · `policy/` | đường dẫn sâu vào trong slice · rule nghiệp vụ · UI | hvigor |
| `app/**` | `adapters/**` · `features/*/index.ets` · `shared/uikit` | `features/*/data` · `features/*/state` | hvigor |
| `shared/**` | `shared/**` khác | `features/` · `adapters/` · `app/` · `policy/` | hvigor |

Hai dòng đầu do trình biên dịch giữ, không tắt được. Tám dòng còn lại do một **hvigor task**
so khớp tiền tố đường dẫn của mỗi câu lệnh `import` với bảng này. Nếu trường `extRuleSet` của
`code-linter.json5` dùng được thì các dòng này nên chuyển sang Code Linter để báo lỗi ngay trong
DevEco Studio thay vì chờ build.

### Ba luật xuyên suốt

1. **Chỉ repository được ghi vào store.** ViewModel chỉ đọc.
2. **Ngoài slice chỉ import `index.ets`** của slice đó.
3. **Rule nghiệp vụ chỉ nằm ở `domain/` hoặc `policy/`** — không ở adapter, không ở ViewModel.

→ `architecture.md`

---

## 2 · Feature organize

Một thư mục dưới `features/` = **một bounded context**. Mọi slice dùng chung một bộ khung,
nên vị trí của bất kỳ mảnh code nào cũng đoán được.

```
MyApp/
├── AppScope/app.json5                     bundleName · versionCode
└── entry/                                 HAP duy nhất — "type": "entry"
    ├── src/main/module.json5              "routerMap":  "$profile:route_map"
    │                                      "appStartup": "$profile:startup_config"
    ├── src/main/resources/
    │   ├── base/element/                  string.json · color.json · float.json
    │   ├── dark/element/color.json        hệ thống tự chọn khi máy đổi chế độ tối
    │   ├── vi_VN/ · en_US/element/        bản dịch theo qualifier
    │   └── base/profile/                  route_map.json · startup_config.json
    │
    ├── src/main/ets/
    │   ├── app/                           khởi động · host điều hướng · màn đa context
    │   │   ├── EntryAbility.ets              UIAbility, nạp nội dung, đặt theme
    │   │   ├── startup/                      các StartupTask
    │   │   ├── pages/Index.ets               Navigation + NavPathStack — host DUY NHẤT
    │   │   └── screens/                      màn hình gộp từ ≥2 context
    │   │
    │   ├── features/log/                  ← một slice
    │   │   ├── domain/          .ts          entity · rules · port · usecase
    │   │   ├── data/            .ts          codec · remote · dao · repository impl
    │   │   ├── state/           .ets         LogStore — @ObservedV2 + @Trace
    │   │   ├── viewmodel/       .ets
    │   │   ├── view/            .ets         Page · view · parts
    │   │   ├── components/      .ets         thành phần riêng của slice
    │   │   ├── events/          .ets         hằng chuỗi topic
    │   │   ├── migration/       .ts          bước migration của riêng slice
    │   │   ├── LogModule.ets                 composition root của slice
    │   │   └── index.ets                     PUBLIC API — ngoài slice chỉ import file này
    │   │
    │   ├── adapters/                      bắc cầu ≥2 context
    │   ├── policy/              .ts       rule nghiệp vụ bắc cầu context
    │   └── shared/
    │       ├── kernel/          .ts          Result · AppError · kiểu định danh
    │       ├── runtime/         .ets         phiên mạng · handle CSDL · Asset · EventBus
    │       ├── uikit/           .ets         token · primitive · pattern · registry
    │       └── utils/           .ts          hàm thuần, không giữ trạng thái
    │
    ├── src/test/                          Local Test — không cần thiết bị
    └── src/ohosTest/                      Instrumented Test — cần thiết bị
```

### Public API của slice

Mỗi slice có đúng một cửa: `index.ets`.

| Được công bố | Không được công bố |
|---|---|
| Lớp `XModule` (composition root của slice) | DTO |
| Entity (chỉ đọc với bên ngoài) | Codec |
| Hằng chuỗi topic sự kiện | DAO |
| Mảng bước migration | Repository impl |
| Kiểu tham số route | Store · ViewModel |

Adapter cần một thứ chưa được công bố thì việc phải làm là **công bố thêm từ slice**,
không phải đi vòng bằng đường dẫn sâu.

### Quy ước đặt tên

| Loại | Khuôn | Ví dụ |
|---|---|---|
| Slice (thư mục) | `camelCase`, danh từ số ít, bằng tên context | `log` · `collection` · `auth` |
| Entity | `PascalCase`, danh từ số ít | `Log` |
| Rules | `<Entity>Rules` | `LogRules` |
| Port | `<Entity>Ports`, chứa nhiều interface | `LogPorts` |
| Use case | `<Động từ><Entity>`, một use case một file | `CreateLog` · `UpdateLog` |
| Repository impl | `<Entity>RepositoryImpl` | `LogRepositoryImpl` |
| Store | `<Ctx>Store` | `LogStore` |
| ViewModel | `<Màn><ViewModel>` | `LogDetailViewModel` |
| Page (glue) | `<Màn>Page` | `LogDetailPage` |
| View | `<Màn>.view` | `LogDetail.view` |
| Module | `<Ctx>Module` | `LogModule` |
| Topic sự kiện | `<context>.<động từ quá khứ>` | `log.deleted` · `log.created` |
| Khoá tài nguyên chuỗi | `<màn>_<vai>` | `logDetail_title` |
| Khoá tài nguyên màu | theo **vai trò**, không theo màu | `backgroundEmphasize` |
| Tên route | `PascalCase`, trùng tên hàm dựng | `LogDetail` |

Hậu tố `.view` không phải trang trí: nó cho hvigor task nhận diện file View bằng tên
mà không phải phân tích cú pháp.

→ `feature-organize.md`

---

## 3 · Domain layer

`features/<ctx>/domain/` — **`.ts` thuần**. Không ArkUI, không Kit nào của HarmonyOS,
không chuỗi hiển thị, không locale. Chạy được ở Local Test (`src/test`) mà không cần thiết bị.

| Loại file | Là gì | Hợp đồng |
|---|---|---|
| **Entity** | Lớp mang dữ liệu và bất biến của nghiệp vụ | Trường chỉ đọc; dựng qua constructor; không có phương thức chạm hạ tầng |
| **Rules** | Hàm thuần kiểm tính hợp lệ | Nhận giá trị, trả về **mã lỗi** dạng chuỗi ngắn hoặc rỗng — **không trả chuỗi hiển thị** |
| **Port** | Interface mà tầng data phải hiện thực | Chỉ khai chữ ký; không có hiện thực; đặt cùng chỗ với entity |
| **Use case** | Hàm nghiệp vụ — xem phần 4 | — |

### Vì sao rules trả mã lỗi

Tầng domain không được biết ngôn ngữ hiển thị. Mã lỗi đi qua ba tầng, mỗi tầng một trách nhiệm:

```
   domain            resources                    viewmodel
   LogRules   ──▶    string.json           ──▶    ánh xạ mã → $r('app.string.*')
   trả 'required'    logEdit_title_required        rồi đưa xuống Field của form
```

Thêm một ngôn ngữ = thêm một thư mục qualifier trong `resources/`, không sửa một dòng nào ở `domain/`.

### Port cho thời gian, định danh, ngẫu nhiên

Use case **không** gọi thẳng đồng hồ hệ thống hay bộ sinh định danh — chúng đi vào qua port
(`Clock`, `IdGen`). Đây là điều kiện để test nghiệp vụ ở Local Test cho kết quả tất định.

### Ràng buộc ngôn ngữ đáng nhớ

| Ràng buộc ArkTS | Hệ quả ở tầng domain |
|---|---|
| Cấm structural typing; `implements` là cách duy nhất thoả interface | Quan hệ giữa repository và port **phải viết ra**, không còn "trùng hình dạng nên dùng được" |
| Cấm `any`, `unknown`, chỉ thị bỏ qua kiểu | Không có lối thoát kiểu ở ranh giới dữ liệu |
| Cấm destructuring và object spread | Entity là **lớp có trường**, không phải object literal dựng lại mỗi lần |

→ `domain-layer.md`

---

## 4 · Usecase layer

`features/<ctx>/domain/usecase/` — **một use case một file**. Là **hàm**, không phải lớp.

| | |
|---|---|
| **Nhận vào** | Các port cần dùng, cộng một đối tượng input đã được kiểm ở tầng trên |
| **Trả về** | `Result` — kiểu tổng của hai lớp `Ok` và `Err` |
| **Được làm** | Chạy rule nghiệp vụ · dựng entity · gọi port |
| **Không được** | Biết ArkUI · biết có mạng hay CSDL · ném ngoại lệ qua ranh giới tầng · chứa chuỗi hiển thị |

### Kiểu `Result`

ArkTS **cấm type predicate** (dạng `arg is T`), nên khuôn discriminated union quen thuộc bên
TypeScript không thu hẹp kiểu được. Thay vào đó `Result` là kiểu tổng của **hai lớp**,
và việc thu hẹp đi qua toán tử `instanceof`:

```
   Result<T>
     ├── Ok<T>   giữ giá trị thành công
     └── Err     giữ AppError
```

`AppError` mang bốn thông tin: **loại lỗi** (mạng · xác thực · dữ liệu không hợp lệ · không tìm thấy ·
lỗi máy chủ · không rõ), **mã kỹ thuật**, **bản đồ lỗi theo trường** (chỉ có khi là lỗi dữ liệu),
và **nguyên nhân để ghi log**. Nó **không** mang chuỗi hiển thị và **không** biết ngôn ngữ.

### Luồng đặt use case trong toàn chuỗi

```
ViewModel ──▶ Use case ──▶ Port (interface) ──▶ Repository impl ──▶ Store
              │                                                        │
              └── rule nghiệp vụ chạy ở ĐÂY và chỉ ở đây               │
                                                                        ▼
ViewModel ◀── Result (chỉ để rẽ nhánh) ────────────────────────────── @Trace
```

**Luật quan trọng nhất của tầng này:** ViewModel đọc `Result` để **rẽ nhánh** — điều hướng, hiện
thông báo, gắn lỗi vào trường của form — rồi **vứt nó đi**. Gán giá trị trong `Ok` vào trường của
ViewModel là tạo ra nguồn sự thật thứ hai, và lỗi sinh ra chỉ lộ khi có hai màn hình cùng mở.

→ `usecase-layer.md`

---

## 5 · Repository layer

`features/<ctx>/data/` — **`.ts`**. Đây là adapter phạm vi slice: nơi **duy nhất** trong slice
biết rằng mạng và cơ sở dữ liệu cùng tồn tại.

| Thành phần | Vai | Dựa trên |
|---|---|---|
| **Remote** | Gọi API | Phiên `rcp` dùng chung, lấy từ `shared/runtime` |
| **Codec** | Dịch dữ liệu thô thành entity | **Sinh tự động** từ hợp đồng API |
| **DAO** | Đọc/ghi bảng | `relationalStore` + `RdbPredicates` |
| **Repository impl** | **Điều phối** cả ba, rồi ghi vào Store | `implements` port khai ở `domain/` |

### Chiến lược mặc định: ưu tiên mạng, dự phòng CSDL

```
ĐƯỜNG ĐỌC
   Remote ──── thành công ────▶ Codec ──▶ DAO ──▶ Store
      │
      └─────── gãy mạng ──────────────▶ DAO ──▶ Store      (người dùng thấy dữ liệu cũ,
                                                             không thấy màn trắng)

ĐƯỜNG GHI
   Remote ──▶ Codec ──▶ DAO ──▶ Store
                         │
                         └── lỗi ở bước này bị NUỐT: remote đã thành công
                             thì thao tác vẫn thành công, chỉ mất khả năng đọc offline
```

Hai đường **dùng chung nửa dưới**, nên mọi cải thiện ở codec, bộ chặn HTTP hay store đều có lợi
cho cả hai chiều.

### Store là điểm khép vòng

`features/<ctx>/state/` là **`.ets`** vì nó dùng `@ObservedV2` và `@Trace` — nguồn sự thật
trong máy. Nó là một cấu trúc dữ liệu quan sát được, đồng bộ, trong bộ nhớ:

- **Không** chứa rule nghiệp vụ.
- **Không** gọi mạng hay CSDL. Nếu một phương thức của store cần chờ bất đồng bộ thì đã sai tầng.
- **Chỉ repository được ghi.** Optimistic update cũng nằm trong repository, vì nó là một
  chiến lược điều phối chứ không phải một tiện ích của UI.

### Codec chịu lỗi

ArkTS cấm `any` và `unknown`, nên mọi dữ liệu từ mạng về buộc phải qua phân tích tường minh.
Bộ sinh codec phải giữ hai tính chất:

1. Trường sai kiểu hoặc thiếu → trả **giá trị rỗng**, **không ném ngoại lệ**.
2. Một bản ghi hỏng trong danh sách → **bỏ qua bản ghi đó, giữ phần còn lại**.

### Vì sao phải sinh codec

Thư viện kiểu Zod **không thể tồn tại** trong ArkTS: nó dựng trên conditional type, mapped type
và `infer` — cả ba đều bị cấm. Đây không phải chuyện "chưa ai chuyển đổi", mà là bộ máy kiểu đó
không có trong ngôn ngữ.

Trên **ohpm** có gói kiểm dữ liệu lúc chạy, nên phần **kiểm** mua sẵn được; nhưng không gói nào
sinh ra **kiểu**. ArkTS không cho suy kiểu lúc biên dịch, nhưng không cấm **sinh mã trước khi
biên dịch** — bộ sinh gắn vào hvigor và chạy trước bước biên dịch.

### Việc nặng đẩy sang TaskPool

Chờ bất đồng bộ không chặn luồng UI, nhưng đoạn xử lý **sau** khi có kết quả thì có.
Phân tích một danh sách hàng nghìn phần tử ngay trên luồng UI là một khung hình bị rớt.

Ranh giới đúng là **một hàm thuần** (đánh dấu `@Concurrent`), không phải cả tầng: đưa hàm codec
sang TaskPool — vào là chuỗi, ra là mảng entity, cả hai đều sao chép qua biên thread được.
Handle `relationalStore` và phiên `rcp` thì **không** qua được, nên **không** đưa cả repository sang.

→ `repository-layer.md`

---

## 6 · Adapter

"Adapter" là một **vai**, không phải một thư mục. Có ba phạm vi, và chỉ một phạm vi cần thư mục riêng:

| Phạm vi | Biết gì | Ví dụ | Sống ở |
|---|---|---|---|
| **slice** | đúng **một** context | codec · remote · DAO · repository impl | `features/<ctx>/data/` |
| **app** | **không** context nào | gắn thông tin xác thực · thử lại khi hết hạn phiên · ánh xạ lỗi · khung form | `shared/runtime` · `shared/uikit` |
| **bắc cầu** | **vài** context | phản ứng chéo · đồng bộ đa tài nguyên · migration chung · dọn phiên · read model | **`adapters/`** |

### Sáu cư dân hợp lệ của `adapters/`

| Cư dân | Việc | Vì sao không ở chỗ khác được |
|---|---|---|
| `readmodel/` | Gộp ≥2 context thành một đối tượng cho màn hình | Không context nào sở hữu kết quả |
| `reactions/` | Bảng nối: topic nào tác động tới store nào | Nếu rải ra từng slice thì slice phải biết nhau |
| `sync/` | Kéo dữ liệu thay đổi cho nhiều tài nguyên | Sẽ nhân bản logic đồng bộ vào từng slice |
| `migration/` | Gom bước migration mọi slice, giữ version tổng | Chỉ có **một** CSDL nên phải có **một** version tổng |
| `session/` | Xoá store và bảng của **mọi** slice khi đăng xuất | Không thuộc `auth` (chạm mọi thứ), không vào `shared/` (gọi tên từng context) |
| `wiring/` | Dựng mọi `XModule`, nối bus | Composition root cấp app — xem phần 7 |

Danh sách này **đóng**. Thêm loại cư dân thứ bảy thì phải sửa tài liệu — đó là thứ duy nhất
giữ `adapters/` không thành ngăn kéo tạp.

### Tiêu chí loại trừ

> Thấy một nhánh rẽ **nghiệp vụ** trong adapter thì nó thuộc use case, không thuộc adapter.

Phép thử khi review: *"người làm sản phẩm có thể tranh luận về dòng này không?"*
Có → nó là nghiệp vụ, chuyển sang `domain/` (một context) hoặc `policy/` (bắc cầu context).

### Phản ứng chéo

Không có tầng cache tự động thì cũng không có cơ chế làm mất hiệu lực cache theo nhãn.
Khi một slice xoá bản ghi mà slice khác đang giữ số đếm liên quan, phải có thứ báo cho nó.
Tách làm hai theo đúng phạm vi:

```
features/log/data          shared/runtime           adapters/reactions       features/collection/state
────────────────────       ──────────────────       ───────────────────      ────────────────────────
 Repository impl  ──phát──▶   EventBus   ──topic──▶     Bảng Reactions  ──▶     CollectionStore
 (sau khi ghi store)          (cơ chế,                  (biết topic nào          (tự sửa mình)
                               không biết                tác động store nào)
                               context nào)

 Sự kiện mang: một TOPIC và một ĐỊNH DANH — không mang entity.
```

Ba thứ đạt được khi đặt bảng nối ở adapter thay vì để mỗi module tự đăng ký nghe:

1. Slice hoàn toàn không biết slice khác tồn tại, kể cả qua tên topic.
2. Toàn bộ quan hệ chéo của app đọc được trong **một** file.
3. Khi xoá một context, trình biên dịch chỉ vào đúng những dòng phải xoá.

Quy ước topic: `<context>.<động từ quá khứ>`. Hằng chuỗi khai trong `features/<ctx>/events/`
và công bố qua `index.ets` — bảng nối **không** được viết chuỗi trực tiếp.

→ `adapter.md`

---

## 7 · DI / IoC

**Không có IoC container, và không thể có.**

ArkTS cấm `Reflect`, `Proxy`, `Object.defineProperty`, index signature và truy cập thuộc tính
bằng khoá động trên instance. Không có cơ chế nào tra phụ thuộc theo tên lúc chạy, nên
**không có DI theo token dạng chuỗi**.

**Constructor injection là cách duy nhất** — và kết quả là đồ thị phụ thuộc của cả ứng dụng
đọc được trong **hai** file.

### Hai cấp lắp ráp

```
                       shared/runtime
                    ┌────────────────────┐
                    │   PlatformPorts    │   phiên rcp · handle relationalStore
                    │  (cơ chế hạ tầng)  │   EventBus · Clock · IdGen · Asset
                    └────────┬───────────┘
                             │ tiêm qua constructor
        ┌────────────────────┼────────────────────┐
        ▼                    ▼                    ▼
   ┌──────────┐        ┌──────────────┐     ┌───────────┐
   │LogModule │        │CollectionMod.│     │AuthModule │   ← cấp SLICE
   ├──────────┤        └──────────────┘     └───────────┘
   │ dựng     │                                    ▲
   │ · Repository impl                             │
   │ · Store (AppStorageV2.connect)                │
   │ · Use cases (nhận port, không nhận impl)      │
   └──────────┘                                    │
        └──────────────────┬─────────────────────  ┘
                           ▼
                 ┌──────────────────────┐
                 │     AppModules       │              ← cấp APP
                 │  adapters/wiring/    │                (adapters/)
                 ├──────────────────────┤
                 │ giữ mọi XModule      │
                 │ nối bảng Reactions   │
                 │ gom migration        │
                 └──────────────────────┘
```

Không có cấp thứ ba. Không có phép khởi tạo phụ thuộc nào ở ngoài hai file này.

### Khởi động — AppStartup

Thứ tự do **cấu hình** quyết định, không do thứ tự import. Mỗi task khai trong
`startup_config.json` với `dependencies`, `runOnThread` và `waitOnMainThread`.

| Task | `runOnThread` | Chặn khung hình đầu | Việc |
|---|---|---|---|
| Khởi tạo runtime | `mainThread` | có | Dựng phiên `rcp`, mở `relationalStore`, khởi tạo EventBus, đọc thông tin xác thực |
| Lắp ráp module | `mainThread` | không | Dựng mọi `XModule`, kết nối store, nối bảng Reactions |
| Làm ấm dữ liệu | `taskPool` | không | Đọc CSDL, phân tích dữ liệu — việc nặng |

> **Vì sao lắp ráp phải ở luồng chính.** Module dựng repository — thứ giữ handle
> `relationalStore` và phiên `rcp` — và gọi `AppStorageV2.connect()`, vốn là trạng thái của
> luồng UI. Cả hai đều không qua được biên TaskPool. Chạy trên `taskPool` thì hoặc lỗi lúc chạy,
> hoặc tệ hơn: dựng được một **bản sao** mà luồng UI không bao giờ nhìn thấy, và không có gì
> báo cho bạn biết. Nó vẫn không chặn khung hình đầu vì `waitOnMainThread` đặt là sai.

### Trình tự tới khung hình đầu tiên

```
 1  Khởi tạo runtime         (mainThread, chặn)
 2  EntryAbility nạp nội dung → app/pages/Index.ets dựng Navigation + NavPathStack
 3  Đặt theme mặc định        (ThemeControl, trong callback của bước nạp nội dung)
 4  Lắp ráp module           (mainThread, không chặn)
 5  Màn đầu vẽ ở trạng thái Loading
 6  Làm ấm dữ liệu           (taskPool)
 7  ViewModel khởi phát nạp → use case → repository → store → @Trace → vẽ lại
```

Bước 5 xảy ra **trước** bước 7 — đó là lý do mọi màn hình phải có trạng thái chờ và không được
giả định dữ liệu đã sẵn sàng.

### Luật

- Chỉ `XModule` và ViewModel được gọi `AppStorageV2.connect()`. View thì không.
- Use case nhận **port**, không nhận hiện thực — đây là điều kiện để thay bằng bản giả trong Local Test.
- `EntryAbility` giữ mỏng: chỉ nạp nội dung và đặt theme, không dựng module, không gọi mạng.

→ `di-composition-root.md`

---

## 8 · UI layer

Tầng UI trả lời bốn câu hỏi: màn hình **dựng bằng gì** (component), **một màn hình** gồm gì
(screen), **chữ** từ đâu ra (localize), **màu và cỡ** từ đâu ra (appearance).

### Bốn phần của một màn hình

```
   route_map.json                 khai { name, pageSourceFile, buildFunction }
        │  name
        ▼
   XPage.ets                      hàm dựng toàn cục + NavDestination
        │                         KHÔNG màn nào import file này trực tiếp
        ▼
   X.view.ets                     @ComponentV2 · nhận ViewModel qua @Param
        │                         vẽ qua AsyncBoundary, chọn nhánh theo trạng thái
        ├──▶ parts/*.ets          nhận @Param, KHÔNG chạm store
        │
        └──▶ XViewModel.ets       @ObservedV2 · nơi duy nhất có tác dụng phụ
                                  không có hàm dựng giao diện
```

Tài nguyên chuỗi nằm ở `string.json` với khoá tiền tố theo màn. Tên file trong `element/`
là **tập đóng** (`string.json`, `color.json`, `float.json`, `plural.json`…), file tên tự đặt
không được biên dịch thành tài nguyên — nên một file dùng chung cộng khoá có tiền tố là **luật**,
không phải giải pháp tạm.

### Hợp đồng ViewModel

| Thành phần | Decorator | Vai |
|---|---|---|
| Cờ đang tải, lỗi, dữ liệu | `@Trace` | Trạng thái quan sát được |
| Trạng thái màn hình | `@Computed` | Suy ra từ ba trường trên, không tự đặt |
| Hành vi | phương thức bất đồng bộ | Gọi use case, điều hướng qua `NavPathStack`, mở lớp phủ |

Trạng thái màn hình có **bốn** giá trị — đang tải · lỗi · rỗng · sẵn sàng — và `AsyncBoundary`
trong `shared/uikit` chọn một trong bốn nhánh để vẽ.

> Dùng `@Computed` chứ không phải các cờ boolean rời rạc, vì cờ rời rạc cho phép tồn tại trạng
> thái vô nghĩa (vừa đang tải vừa có lỗi), và trạng thái đó sẽ xuất hiện trong một tình huống
> tranh chấp nào đó. `@Computed` làm nó **không biểu diễn được**.

### `shared/uikit` — ba tầng

```
   token       →   primitive   →   pattern
   ────────        ─────────       ────────
   color.json      Button          AsyncBoundary
   float.json      Text            Form
   AppColors       Field           Overlay
   (CustomColors)  Icon            các khuôn danh sách

                   registry: enum → WrappedBuilder
```

Thành phần riêng của slice **chỉ ghép lại**, không bao giờ sao chép rồi sửa. Cần một biến thể
thì thêm vào `shared/uikit`.

### Luật của tầng UI

| Luật | Vì sao |
|---|---|
| Màu luôn là tài nguyên (`$r`), không viết mã hex trong `.ets` | Chế độ tối có sẵn: hệ thống tự lấy `resources/dark/element/color.json` khi máy đổi chế độ, không cần một dòng rẽ nhánh nào |
| Style tái dùng phải là `AttributeModifier`, không dùng `@Styles` / `@Extend` | Lý do kỹ thuật: hai decorator đó **không công bố được qua file**, nên design system dùng chúng thì không dùng chung được |
| Token semantic đặt tên theo **vai trò** | Tên theo màu không nói nó dùng để làm gì |
| Theme đặt một lần ở composition root qua `ThemeControl` | Đổi theme cục bộ cho một màn thì bọc bằng `WithTheme` |
| Danh sách dài dùng `Repeat`, không dùng `LazyForEach` | `Repeat` tự nghe thay đổi của state V2, không phải gọi thông báo thêm/bớt bằng tay |
| Registry khoá bằng `enum`, giá trị là `WrappedBuilder` | ArkTS cấm `as const` nên không suy được kiểu từ mảng; khoá `enum` biến lỗi gõ sai thành lỗi biên dịch |
| Mọi strategy nhận **đúng một** tham số dạng object | Hàm dựng của ArkUI chỉ truyền tham chiếu — và do đó chỉ phản ứng với thay đổi trạng thái — khi nhận đúng một tham số object; hai tham số rời là mất tính phản ứng |
| Tham số route là **định danh**, không phải object | Ngăn xếp điều hướng được hệ thống khôi phục sau khi tiến trình bị thu hồi; object đi kèm khi đó đã cũ |

Cùng một registry dùng cho: lớp phủ · trường form · bộ vẽ phần tử danh sách · ranh giới bất đồng bộ ·
theme. **Một cơ chế cho năm chỗ, thay vì năm cách làm cùng một việc.**

### Điều View không được làm

Không gọi repository · không đọc store · không gọi `AppStorageV2.connect()` ·
không chứa nhánh rẽ nghiệp vụ · không giữ chuỗi hiển thị · không thao tác `NavPathStack`.
Trạng thái giao diện thuần (tab đang chọn, panel mở) thì dùng `@Local` ngay trong struct.

### Localize

**Không có chuỗi hiển thị nào trong `.ets` hay `.ts`.** Đây không phải mục tiêu đạo đức mà là
điều kiện để hệ thống kiểm làm hộ: prop chữ khai kiểu `Resource` — **không** `string`, **không**
`ResourceStr` — nên chuỗi cứng trở thành **lỗi biên dịch**, không phải việc phải nhớ khi review.

| Loại chữ | Sống ở |
|---|---|
| Nhãn, tiêu đề, nút, nhãn tiếp cận | `string.json`, khoá `<màn>_<vai>` |
| Thông báo lỗi | `string.json`, tra bằng **mã lỗi** từ `domain/` |
| Số nhiều | `plural.json` — không ghép bằng `if (n === 1)` |
| Ngày, số, tiền tệ | Hàm ở `shared/utils/format`, **nhận `locale` làm tham số** |

Ba luật giữ cho việc đổi ngôn ngữ không cần khởi động lại: `$r(...)` là giá trị **lười** nên ArkUI tự
phân giải lại lúc vẽ; `getStringSync()` bị cấm ngoài `shared/uikit/i18n` vì nó đóng băng chuỗi;
và chuỗi đã định dạng **không** được cất vào `@Trace` — giữ giá trị thô, phơi qua `@Computed`.

### Application appearance

Token màu và số đo là **tài nguyên**, đặt tên theo **vai trò** (`backgroundEmphasize`, `space_m`),
nên bảng token thứ hai cho chế độ tối không phải đổi tên gì. Ba nguồn quyết định sáng/tối xếp chồng,
nguồn dưới ghi đè nguồn trên trong phạm vi của nó:

| Nguồn | Cách | Phạm vi |
|---|---|---|
| Hệ thống | qualifier `dark/element/color.json` — **mặc định**, không một dòng code | cả app |
| Người dùng chọn | `applicationContext.setColorMode(...)`, áp ở task khởi động **đầu tiên** | cả app |
| Ép cục bộ | `WithTheme({ colorMode })` — màn xem ảnh luôn tối | một cây component |

Cấu hình có **một điểm nhận duy nhất**: `EntryAbility.onConfigurationUpdate` → `AppearanceStore` →
`@Computed`. Không component nào tự đọc `Configuration` — cùng lý do với luật chỉ repository được ghi
vào store. Chữ dùng `fp`, khung dùng `vp`; đệm và lề dùng `start`/`end` chứ không `left`/`right`.

→ [`ui-layer.md`](ui-layer.md) — component · screen · localize · appearance, kèm 11 rule enforce

---

## Thuật ngữ HarmonyOS

### Đóng gói và cấu hình

| Thuật ngữ | Nghĩa |
|---|---|
| **HAP** | Harmony Ability Package — đơn vị cài đặt. Dự án này có đúng một HAP kiểu `entry` |
| **HAR** / **HSP** | Thư viện tĩnh / thư viện chia sẻ. **Không dùng** trong dự án này |
| `AppScope/app.json5` | Cấu hình cấp ứng dụng: `bundleName`, `versionCode` |
| `module.json5` | Cấu hình cấp module: kiểu module, `routerMap`, `appStartup`, quyền |
| **ohpm** | Trình quản lý gói của hệ sinh thái OpenHarmony |
| **hvigor** | Hệ thống build. Task tự viết đặt trong `hvigorfile.ts` |
| `code-linter.json5` | Cấu hình Code Linter của DevEco Studio |

### Ngôn ngữ và giao diện

| Thuật ngữ | Nghĩa |
|---|---|
| **ArkTS** | Ngôn ngữ ứng dụng — tập con bị siết của TypeScript |
| **ArkUI** | Khung giao diện khai báo |
| **state management V2** | Thế hệ decorator trạng thái thứ hai của ArkUI |
| `@ObservedV2` · `@Trace` | Đánh dấu lớp quan sát được và trường phát tín hiệu khi đổi |
| `@Computed` | Giá trị suy ra, tự tính lại khi phụ thuộc đổi |
| `@ComponentV2` · `@Param` · `@Event` · `@Local` | Struct giao diện · tham số vào · callback ra · trạng thái nội bộ |
| `@Monitor` | Chạy hàm khi một đường dẫn trạng thái cụ thể đổi |
| `@Builder` · `wrapBuilder` · `WrappedBuilder` | Hàm dựng giao diện, và cách đóng gói nó thành giá trị |
| `AttributeModifier` | Cách gói style tái dùng, công bố được qua file |
| `Repeat` | Bộ dựng danh sách của state V2 |
| `AppStorageV2` · `PersistenceV2` | Kho trạng thái toàn ứng dụng, có/không lưu bền |
| `ThemeControl` · `WithTheme` · `CustomColors` | Đặt theme toàn cục · theme cục bộ · bảng token màu tuỳ biến |

### Điều hướng và vòng đời

| Thuật ngữ | Nghĩa |
|---|---|
| **UIAbility** | Thành phần có giao diện. `EntryAbility` là điểm vào của ứng dụng |
| `WindowStage` | Vật chứa cửa sổ; nội dung được nạp trong `onWindowStageCreate` |
| `Navigation` · `NavPathStack` · `NavDestination` | Vật chứa điều hướng · ngăn xếp · một đích đến |
| `route_map.json` | Bảng khai báo màn hình: `name`, `pageSourceFile`, `buildFunction` |
| **AppStartup** | Cơ chế khai báo task khởi tạo trong `startup_config.json` |

### Dữ liệu, mạng, đồng thời

| Thuật ngữ | Nghĩa |
|---|---|
| `relationalStore` · `RdbPredicates` | Cơ sở dữ liệu quan hệ và bộ dựng điều kiện truy vấn |
| `preferences` | Kho khoá–giá trị nhẹ, dùng cho cấu hình ứng dụng |
| **Asset Store Kit** | Kho bí mật cấp hệ thống — nơi duy nhất giữ thông tin xác thực |
| **Remote Communication Kit** (`rcp`) | Thư viện HTTP. Hỗ trợ ghim chứng chỉ ở mức phiên và mức request |
| **TaskPool** · `@Concurrent` · `@Sendable` | Thực thi đa luồng · hàm chạy được trên luồng khác · lớp qua được biên thread |

### Tài nguyên

| Thuật ngữ | Nghĩa |
|---|---|
| `resources/base/element/` | Tài nguyên mặc định. Tên file là **tập đóng** |
| Thư mục qualifier | `dark/`, `vi_VN/`, `en_US/`… — hệ thống tự chọn theo ngữ cảnh máy |
| `rawfile/` | Tài nguyên thô, tên file tự do, không được biên dịch thành khoá |
| `$r()` | Cách tham chiếu tài nguyên đã biên dịch |

### Kiểm thử

| Thuật ngữ | Nghĩa |
|---|---|
| **Local Test** (`src/test`) | Chạy trên máy phát triển, **không cần thiết bị**. Nơi test `domain`, `data`, `policy`, `adapters` |
| **Instrumented Test** (`src/ohosTest`) | Chạy trên thiết bị hoặc máy ảo. Nơi test ViewModel, View, luồng đầu-cuối |

---

## Lộ trình

| Thứ tự | Tài liệu | Vì sao viết trước |
|---|---|---|
| 1 | `architecture.md` | Bảng tầng import là thứ chặn PR — cần có trước khi có code |
| 2 | `feature-organize.md` | Khuôn slice để bắt đầu feature đầu tiên |
| 3 | `domain-layer.md` · `usecase-layer.md` | Nghiệp vụ viết và test được ngay, không cần thiết bị |
| 4 | `repository-layer.md` | Gồm cả bộ sinh codec — khoản chi phí lớn nhất nếu bỏ mặc |
| 5 | `di-composition-root.md` | Cần khi có slice thứ hai |
| 6 | [`ui-layer.md`](ui-layer.md) ✅ | Cần khi dựng màn hình đầu tiên |
| 7 | `adapter.md` | Chỉ cần khi có quan hệ chéo giữa ≥2 context |
