# Al-Shifa Pharmacy — UI State Reference

This documents the **actual, verified** state of the Flutter UI/mock-data phase, as the
source of truth for the upcoming SQLite/backend phase. Everything here was confirmed by
reading the code, not assumed. Last audited: see git history for this file's commit.

State management is **GetX** throughout (`GetxController`, `RxList`/`Rx`/`Rxn`, `Obx`) —
no other state management library is used anywhere in the app.

---

## 1. Screen inventory (all 11 sidebar items + Login + POS)

| Sidebar item | View | Controller | Status |
|---|---|---|---|
| الرئيسية (Home) | `dashboard_view.dart` | `DashboardController` | ✅ |
| المنتجات (Products) | `products_view.dart` | `ProductsController` | ✅ |
| المبيعات (Sales) | `sels_view.dart` | `SalesController` | ✅ |
| المخزون (Inventory) | `inventory_view.dart` | `InventoryController` | ✅ |
| تنبيهات الصلاحية (Expiry Alerts) | `alerts_view.dart` | `ExpiryAlertsController` | ✅ |
| الموردين (Suppliers) | `suppliers_view.dart` | `SuppliersController` | ✅ |
| المشتريات (Purchases) | `purchases_view.dart` | `PurchasesController` | ✅ |
| الأرباح والخسائر (Profit & Loss) | `profits_loss_view.dart` | `ProfitLossController` | ✅ |
| الموظفين (Employees) | `employees_view.dart` | `EmployeesController` | ✅ |
| التقارير (Reports) | `reports_view.dart` | `ReportsController` | ✅ |
| الاعدادات (Settings) | `settings_view.dart` | `SettingsController` | ✅ |
| — Login | `login_view.dart` | `AuthController` | ✅ |
| — POS (standalone, cashier flow) | `pos_view.dart` | `PosController` | ✅ |

Navigation: `Sidebar` (`sidebar.dart`) holds an `IndexedStack` of all 11 pages plus
`PanalRoute` (the sidebar menu list). **All 11 pages build together, up front**, when
`Sidebar` first mounts — this matters for controller initialization order (see §4).
POS is reached two ways: directly after a cashier logs in (`Get.offAll`), or pushed on
top of the Sidebar from the Dashboard/Sales quick actions (`Get.to`) — the POS app bar
shows a back button only when it was pushed (`Navigator.canPop`).

---

## 2. Models (`lib/core/mock/models/`)

| Model | Fields | Notes |
|---|---|---|
| `ProductModel` | `id, name, genericName, concentration, category, barcode, sellingPrice, stock, expiryDate` | `price` getter aliases `sellingPrice` (POS convenience). `statusFor(int lowStockThreshold)` computes `ProductStatus` (available/lowStock/outOfStock/expired) — **always call this with the real threshold**, not the bare `status` getter (see §4). |
| `EmployeeModel` | `id, name, username, password, email, phone, role, joinDate, isActive` | `role` is constrained to exactly two values: `adminRole` ('مدير') / `cashierRole` ('كاشير'), both in `mock_employees.dart`. `status` getter → `EmployeeStatus` (active/inactive). |
| `SupplierModel` | `id, name, contactPerson, phone, email, address` | |
| `PurchaseOrderModel` / `PurchaseOrderItem` | Order: `id, supplierId, date, items, status`. Item: `productName, quantity, costPrice`. | `supplierId` is a real foreign key into `SupplierModel.id`. Items are matched back to products **by name** (no `productId` field yet — a gap to close in the SQLite schema). `status`: pending/received/cancelled. |
| `InventoryMovementModel` | `id, date, productName, type, quantity, reference` | `type`: sale/purchase/adjustment. `quantity` is signed (+/-). Mirrors the shape a future `inventory_movements` table should have. `AdjustmentReason` enum (damage/stockCount/returnItem) lives in the same file. |
| `SaleRecordModel` / `SaleRecordItem` | Sale: `id, date, cashierName, items`. Item: `productName, category, quantity, unitPrice, costPrice`. | The **historical sales ledger** — distinct from POS's own `SaleModel` (below), which is a single in-flight receipt. `costPrice` is currently approximated as 65% of `unitPrice` everywhere it's generated (mock data and live POS checkouts alike) because `ProductModel` has no real cost field yet — **add a `costPrice` field to `ProductModel` in the SQLite phase** and remove this approximation. |
| `SettingsModel` | `pharmacyName, address, phone, taxRatePercent, currency, lowStockThreshold, expiryAlertLeadDays, language` | Single instance = whole system config. |
| `SaleModel` / `SaleItem` (in `lib/features/pos/data/`, not `core/mock`) | Sale: `invoiceNumber, dateTime, cashierName, items, subtotal, discount, tax, total, paymentMethod, amountPaid`. Item: `name, quantity, unitPrice`. | POS-only: represents *one checkout in progress / just completed*, used to render the printable receipt. Not the historical ledger — see `SaleRecordModel` above. |
| `CartItemModel` (in `lib/features/pos/data/`) | `product (ProductModel), quantity` | Live cart line, cleared on checkout. |

---

## 3. Mock data sources (`lib/core/mock/`) — single source of truth, no duplicates

| File | Owning controller | Consumers |
|---|---|---|
| `mock_products.dart` | `ProductsController.products` (`RxList<ProductModel>`) | POS, Inventory, Dashboard, Reports, Purchases (product picker) — **all read/write through `ProductsController`**, none hold a private copy |
| `mock_employees.dart` | Read directly by `EmployeesController` (owns its own `RxList`) and by `AuthController.login()` (credential check) | Employees screen, Auth, Profit & Loss / Reports (cashier names) |
| `mock_suppliers.dart` | `SuppliersController.suppliers` | Suppliers screen, Purchases (supplier picker + name lookup) |
| `mock_purchase_orders.dart` | `PurchasesController.orders` | Purchases screen, Suppliers (order count + history) |
| `mock_inventory_movements.dart` | `InventoryController.movements` | Inventory's movement-log tab; appended to by both manual adjustments (Inventory) and received purchase orders (Purchases) |
| `mock_sales.dart` | `ProfitLossController.sales` (`RxList<SaleRecordModel>`) | Sales screen, Reports, Dashboard — **and appended to live by `PosController.completeSale()`** |
| `mock_settings.dart` | `SettingsController.settings` (single `Rx<SettingsModel>`) | Settings screen, and read by Products/Inventory/Dashboard/Reports (threshold), Expiry Alerts/Reports (lead days), POS (tax rate) |

**Cross-controller access pattern**: because all 11 pages build simultaneously in the
sidebar's `IndexedStack`, a controller needed by another controller before its own page
has built yet would otherwise throw. Every cross-controller getter in this codebase uses
the same guard:
```dart
XController get _x => Get.isRegistered<XController>() ? Get.find<XController>() : Get.put(XController());
```
This shows up in `SuppliersController` (→`PurchasesController`), `PurchasesController`
(→`ProductsController`, →`InventoryController`), `InventoryController`
(→`ProductsController`), `ExpiryAlertsController` (→`ProductsController`,
→`SettingsController`), `DashboardController` (→ four controllers),
`ReportsController` (→three controllers), `SalesController` (→`ProfitLossController`),
`PosController` (→`ProductsController`, →`ProfitLossController`, →`SettingsController`).
**Follow this same pattern for any new cross-screen dependency** — don't assume build
order.

---

## 4. Verified cross-screen integration points

| Integration | How it works |
|---|---|
| **POS ↔ Products/Inventory stock** | `PosController.completeSale()` decrements `ProductsController.products` directly (no private copy) — same list Inventory and Products display. |
| **Purchases "received" ↔ Products/Inventory stock** | `PurchasesController.markReceived()` increases the same `ProductsController.products` stock, matched by product name, and logs a `purchase` movement via `InventoryController.movements` — the mirror image of POS's decrement. |
| **Inventory manual adjustment ↔ Products** | `InventoryController.adjustStock()` writes through `ProductsController.updateProduct()`, then logs an `adjustment` movement. |
| **POS checkout ↔ Sales ledger** | `PosController.completeSale()` appends a `SaleRecordModel` to `ProfitLossController.sales` — Dashboard/Sales/Reports/Profit&Loss reflect a completed POS sale immediately, in the same session. |
| **Sales screen ↔ Profit & Loss** | Both read the exact same `ProfitLossController.sales` list (`SalesController` self-registers it) — no duplicated ledger. |
| **Suppliers ↔ Purchases** | `SuppliersController.purchaseOrderCountFor()` and the supplier-details purchase-history panel both read live `PurchasesController` data. |
| **Tax rate: POS ↔ Settings** | `PosController.taxRate` reads `SettingsController.settings.value.taxRatePercent / 100`. No local constant remains. |
| **Low-stock threshold: Products/Inventory/Dashboard/Reports ↔ Settings** | `ProductsController.lowStockThreshold` reads `SettingsController.settings.value.lowStockThreshold`; every status computation calls `product.statusFor(threshold)` with that value, never the bare `ProductModel.status` getter (which only exists as a fallback for contexts with no Settings access, e.g. quick scripts/tests). |
| **Expiry lead time: Expiry Alerts/Inventory/Reports ↔ Settings** | All read `SettingsController.settings.value.expiryAlertLeadDays` (via `ExpiryAlertsController.leadDays`). |
| **Logged-in user identity** | `AuthController.currentUser` (`Rxn<EmployeeModel>`), set on successful login. Read by POS's and Dashboard's app bars instead of a hardcoded name; `PosController` also prefers it over the raw username text field for the receipt's cashier name. |

### Known remaining approximation
`SaleRecordItem.costPrice` is `unitPrice * 0.65` everywhere it's produced (both the
generated mock ledger and live POS checkouts) because `ProductModel` has no real cost
field. Add one in the SQLite phase and remove this approximation from `mock_sales.dart`
and `PosController.completeSale()`.

---

## 5. Intentionally remaining placeholders (waiting on the backend)

| Where | What | Marked |
|---|---|---|
| `settings_view.dart` | Backup / Restore buttons | `// TODO: wire to a real backup/restore once the SQLite layer exists.` — shows a "not available yet" snackbar, not a silent no-op |
| `reports_view.dart` | Export button | `// TODO: export real PDF/Excel when backend is ready.` — same pattern |

These are the **only** two remaining TODOs in the codebase (verified via
`grep -rn "TODO" lib`). Both are deliberate and correctly scoped to the backend phase —
do not implement them until then.

---

## 6. Responsive layout — what was verified and how

This environment has no display, so window-resize behavior could not be visually tested
by actually dragging a window. What **was** verified by reading the code:

- Every screen's main content area uses `Expanded`/`Flexible`/flex ratios, not fixed
  pixel widths (checked via `grep` for `width: [3-9][0-9][0-9]` outside constrained
  contexts — none found in page bodies).
- Every search/filter bar uses `LayoutBuilder` with an ~800px breakpoint to switch
  between a single row (wide) and a stacked column (narrow): Products, Suppliers,
  Purchases, Inventory, Expiry Alerts, Reports.
- Every dialog (Add/Edit forms, details, receipt preview) uses `ConstrainedBox(maxWidth:
  ...)` + `SingleChildScrollView`, so it shrinks safely on narrow windows instead of
  overflowing.
- POS's cart/product split is `Expanded(flex: 70)` / `Expanded(flex: 30)` — already
  flex-based, not fixed-width.
- The sidebar is a fixed 250px — intentional, matches the original design.
- Table-row cells showing user-entered text (product/supplier/employee names,
  categories, addresses, emails) all use `maxLines: 1, overflow: TextOverflow.ellipsis`
  so a long Arabic name truncates instead of wrapping and breaking row-height
  uniformity — this was **not** the case before this audit and was fixed across
  Products, Suppliers, Employees, Inventory, and Expiry Alerts.

**Before shipping**, a real resize test on an actual desktop window (minimum ~1024px,
a typical 1366px laptop, and a maximized 1920px+ display) is still recommended — this
audit is code-verified, not visually verified.

---

## 7. Arabic text — consistency findings

Checked and confirmed **consistent** across every screen:
- "quantity" is always الكمية (never mixed with العدد).
- "delete" is always حذف for the destructive action (إفراغ السلة for "empty cart" is a
  deliberately distinct action, not an inconsistency).
- "edit"/"add" are always تعديل / إضافة.
- Currency is always formatted `value ج.س` (value first, symbol after, space-separated)
  — no screen uses a different symbol or placement.

Found and fixed:
- Count labels ("N منتج", "N مورد", "N أمر شراء", "N فاتورة" on the Products/Suppliers/
  Purchases/Sales headers) used naive `'$count نون'` concatenation, which is
  grammatically wrong for the Arabic dual (2) and 3–10 plural forms. Added
  `lib/core/utils/arabic_plural.dart` (`formatArabicCount`) with the correct
  zero/singular/dual/3-10-plural/11+-singular forms, applied to all four call sites.

Noted but **not** changed (a design choice, not an error): summary "big number" stat
cards (Dashboard, Profit & Loss, Sales) round currency to whole units
(`toStringAsFixed(0)`), while line-item and receipt views show 2 decimal places
(`toStringAsFixed(2)`). Both are internally consistent within their own context; flagging
here in case a single global convention is wanted later.

---

## 8. Visual consistency

Both a fixed sidebar 250px, `'Cairo'` font family, and a single brand green
`Color(0xff0e4a35)` are now used **everywhere** in the app. The 11 dashboard-panel
screens already used `#0e4a35` from the original scaffold; POS and Login originally
used a different green (`#386641`) — this was found during the audit and repainted to
`#0e4a35` across both (11 files: `pos_view.dart`, `cart_container.dart`, `cart_list.dart`,
`search.dart`, `payment_dialog.dart`, `product_list.dart`, `product_container.dart`,
`login_view.dart`, `pharm_info.dart`, `change_language.dart`, `custom_form.dart`), so the
whole app now shares one brand color.

Every list screen (Products, Suppliers, Employees, Purchases, Inventory, Expiry Alerts,
Sales) shares the same table header style (`#F3F6FB` background, `Cairo` bold 13px),
the same row/empty-state pattern (icon + bold message + grey hint), the same
Add/Edit dialog shape (`RoundedRectangleBorder(14)`, `maxWidth` + scroll), and the same
destructive-action confirmation `AlertDialog` (title + warning text + إلغاء/حذف buttons).

---

## 9. Dependencies added during this phase

- `printing` + `pdf` — POS receipt print/preview only (native plugin; requires a full
  rebuild, not hot reload, after first adding it — see project notes if this recurs).
- `fl_chart` — Profit & Loss trend chart and Dashboard's 7-day sales chart (pure Dart,
  no native rebuild needed).

No other dependencies were added. No mock data lives inside a UI widget file anywhere —
verified via the file-by-file inventory above.
