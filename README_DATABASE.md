# Al-Shifa Pharmacy — SQLite Database Reference

This documents the real, verified state of the SQLite backend built on top of
`README_UI_STATE.md`. GetX remains the only state-management library — every
controller's external API (`RxList`/`Rx`/`Rxn` fields, public method names)
is unchanged from the mock-data phase; only their internals now read/write
through a repository instead of an in-memory mock list.

## Architecture

```
lib/core/database/app_database.dart   // SQLite connection + schema (single source of truth for tables)
lib/core/di/bindings.dart             // Get.lazyPut for every repository, wired via GetMaterialApp(initialBinding:)
lib/core/utils/password_hasher.dart   // SHA-256 + per-user salt
lib/data/models/                      // Same models as the mock phase, unchanged fields except noted additions below
lib/data/seed/                        // The old lib/core/mock/ catalogs, relocated — used only to seed a fresh database once
lib/data/repositories/                // One repository per table/aggregate
```

Every repository is registered once via `Get.lazyPut` in `AppBindings`
(`lib/core/di/bindings.dart`), itself wired in via
`GetMaterialApp(initialBinding: AppBindings())` in `main.dart`. A controller
fetches its repository with `Get.find<XRepository>()` at construction time
(a field initializer, which runs before `onInit()`), since `lazyPut`
registrations exist from app start regardless of navigation order.

**Package**: `sqflite_common_ffi` (not plain `sqflite`, which has no desktop
implementation) + `sqflite` for the shared `Database`/`Batch` types, `path`
for the database file path, `crypto` for password hashing.

## The in-memory-mirror pattern (why every controller looks the same)

Every controller keeps its original `RxList<Model>` (or `Rx<Model>`) field —
the UI never talks to a repository directly. On `onInit()`, the controller
loads all rows from its repository into that list; on a fresh/empty
database, it seeds the list once from the corresponding `lib/data/seed/`
catalog (writing each seed row through the repository) so the app still
opens with realistic data instead of a blank state. Every mutation method
(`addProduct`, `updateSupplier`, etc.) updates the `RxList` synchronously
(so the UI reacts immediately, exactly as before) and fires the matching
repository write — this is why no controller's public signature changed.

The one exception is **synced-elsewhere writes**: when a transaction in one
repository already persisted a value (e.g. `PurchaseOrderRepository.receiveOrder`
already wrote the new stock into `products`), the controller that owns the
affected `RxList` must NOT write it again through its own repository method
— it would be a redundant, non-transactional second write of the same
value. For this, `ProductsController` exposes
`applyPersistedUpdate(ProductModel)`, which updates only the in-memory
mirror. `PurchasesController.markReceived()` and `PosController.completeSale()`
both use it after their transaction commits.

## Tables

| Table | Columns | Notes |
|---|---|---|
| `employees` | `id, name, username (UNIQUE), password_hash, password_salt, email, phone, role, join_date, is_active` + sync columns | Passwords are **never** stored or returned in plain text — see Security below. |
| `products` | `id, name, generic_name, concentration, category, barcode, selling_price, stock, expiry_date` + sync columns | `category` stays free text (no separate `categories` table — see Deviations below). No cost-price column yet (see Known gap below). |
| `suppliers` | `id, name, contact_person, phone, email, address` + sync columns | |
| `purchase_orders` | `id, supplier_id (FK → suppliers.id), date, status` + sync columns | `status`: `pending` / `received` / `cancelled`. |
| `purchase_order_items` | `id (autoincrement), order_id (FK → purchase_orders.id, CASCADE), product_id (FK → products.id, nullable), product_name, quantity, cost_price` | `product_id` is set for every line added through the UI; nullable only for legacy/mock rows that predate the field. |
| `sales` | `id, date, cashier_name` + sync columns | |
| `sale_items` | `id (autoincrement), sale_id (FK → sales.id, CASCADE), product_id (FK → products.id, nullable), product_name, category, quantity, unit_price, cost_price` | Same `product_id` note as above. |
| `inventory_movements` | `id, date, product_id (FK → products.id, nullable), product_name, type, quantity, reference` + sync columns | `type`: `sale` / `purchase` / `adjustment`. `quantity` is signed (+ increases stock, − decreases it). |
| `app_settings` | `id (CHECK id = 1), pharmacy_name, address, phone, tax_rate_percent, currency, low_stock_threshold, expiry_alert_lead_days, language` + sync columns | Single row, upserted via `INSERT OR REPLACE`. |

Every main table also carries `is_dirty INTEGER DEFAULT 1`, `server_id TEXT`,
`updated_at TEXT NOT NULL` for a future sync phase — nothing reads or writes
`is_dirty`/`server_id` yet.

`purchase_order_items` and `sale_items` intentionally don't carry the sync
columns — they're always loaded/written together with their parent row, so
syncing the parent is enough.

## Transactional flows (the two hard requirements)

Both run as a single `db.transaction()` using a `Batch`, verified by real
(passing) unit tests in `test/repositories/transactional_flows_test.dart`:

- **`SaleRepository.createSale()`** — inserts the sale + its items, decrements
  stock for every line's product, and inserts a `sale`-type inventory
  movement per line. Called by `PosController.completeSale()`.
- **`PurchaseOrderRepository.receiveOrder()`** — marks the order `received`,
  increases stock for every line's product, and inserts a `purchase`-type
  inventory movement per line. Called by `PurchasesController.markReceived()`.
  The exact mirror of `createSale()`.

## Security

- `EmployeeRepository` hashes with SHA-256 + a random per-user salt
  (`lib/core/utils/password_hasher.dart`) before every insert; a password is
  never written or read in plain text once persisted.
- `AuthController.login()` calls `EmployeeRepository.verifyCredentials()`,
  which loads the stored hash/salt and compares — the plaintext password
  the user typed never leaves that one function call.
- Editing an employee (`EmployeeFormDialog`) leaves the password field blank
  by default (the real password is never sent back to prefill it); leaving
  it blank on save means "keep the current password" — `EmployeeRepository.update()`
  only rehashes when a new, non-empty password is actually provided.

## Deviations from the original plan (disclosed, as agreed, before applying them)

- **No `categories` table.** Nothing in the mock-era code modeled a category
  as its own entity — it was always a free-text field on `ProductModel`.
  Adding a real `categories` table now would mean inventing a
  `CategoriesController`/UI that never existed, which is out of scope for
  "swap mock data for a real database." `products.category` stays a plain
  TEXT column.
- **`product_id` FK added** to `purchase_order_items`, `sale_items`, and
  `inventory_movements` (confirmed with you before implementing). The
  mock-era code matched these back to a product **by name string**, which
  is fragile; the models (`PurchaseOrderItem`, `SaleRecordItem`,
  `InventoryMovementModel`) gained an optional `productId` field, populated
  at both real construction sites (POS's `completeSale()`, the purchase-order
  form dialog, which now tracks the selected `ProductModel` instead of just
  its name).
- **Two controller method signatures changed from sync to async**, both
  because they now need to `await` a database transaction:
  `PurchasesController.markReceived()` and `PosController.completeSale()`
  (`void`/`SaleModel?` → `Future<void>`/`Future<SaleModel?>`). Both call
  sites (`PurchaseOrder` row's receive button, `PaymentDialog._confirm()`)
  needed a matching `await`/arrow-function tweak — mechanical, not a
  redesign.

## Known remaining gap

`ProductModel` still has no real cost-price field, so `SaleRecordItem.costPrice`
is approximated as `unitPrice * 0.65` everywhere it's produced (both the
mock seed data and live POS checkouts) — carried over unchanged from the
mock phase. Add a real `cost_price` column to `products` and a matching
model field/Products-screen input in a follow-up if accurate profit
reporting matters before this ships.

## Tests

`test/repositories/transactional_flows_test.dart` exercises both
transactional flows against a real in-memory SQLite database
(`AppDatabase.instance.openForTest()`, backed by `sqflite_common_ffi`'s
`inMemoryDatabasePath` — a test-only seam, not used anywhere in production
code). Run with:

```
flutter test test/repositories/transactional_flows_test.dart
```
