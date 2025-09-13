# Test Plan — GoREST Users API (Postman)

## 1. Objective
Validate core behavior of the GoREST **Users** API using a Postman collection, ensuring:
- CRUD happy-path works (create → read → update → delete → verify 404).
- Robust error handling for 401/404/422.
- Pagination behaves deterministically (no overlap between pages; invalid page falls back to page 1 item set).
- Basic boundary checks (e.g., minimal name length).

## 2. Scope
**In scope**
- Endpoint family: `GET /users`, `GET /users/{id}`, `POST /users`, `PUT /users/{id}`, `DELETE /users/{id}`.
- Validation of response status codes, types/shapes, and key fields.
- Error-message quality checks for common failures (duplicate email, invalid enums, missing fields).

**Out of scope**
- Full email format RFC validation.
- Cross-resource dependencies (posts, comments, todos).
- Load/performance testing.

## 3. Test Items
- Postman collection: `GoREST Users Tests.postman_collection.json`
- Postman environment: `GoREST Local.postman_environment.json`

## 4. Test Approach
- Folder-level **guards** (status + light JSON schema) to minimize flaky tests against a public API.
- Request-level **assertions** per scenario.
- Pagination tests compare **ID sets** across pages for strictness.
- Negative tests assert **array-of-errors** shape for `422` and `{ message }` object for `401/404`.

## 5. Environments & Data
- `baseUrl = https://gorest.co.in/public/v2`
- `token` must be provided locally in Postman (do not commit).
- Unique email seeded via timestamp to avoid collisions, e.g., `qa_<timestamp>@example.com`.
- Duplicate-email flow uses explicit **seed → duplicate → cleanup** sequence.

## 6. Entry & Exit Criteria
**Entry**
- Collection & environment imported.
- Valid personal access token configured in the Postman environment.

**Exit**
- All **Happy Path** tests pass.
- All **Negative** tests return expected 4xx with expected shapes/messages.
- Pagination rules verified (no overlap; invalid page == page 1 set).
- Boundary checks pass as defined.

## 7. Test Execution Order (recommended)
1. **Users / Pagination**: `page=1` → `page=2` → `invalid page` (no data mutations).
2. **Users / Happy Path**: `Create (201)` → `Get by id (200)` → `Get all (200)` → `Update (200)` → `Delete (204)` → `Verify 404`.
3. **Users / Negative**:
   - **Email**: `Create seed (201)` → `Duplicate (422)` → `Cleanup (204)`; plus `missing` and `invalid format` cases.
   - **Name**: `missing`, `empty`, `space` → `422`.
   - **Gender**: `missing`, `invalid enum` → `422`.
   - **Status**: `missing`, `empty`, `space` → `422`.
   - **Token**: `missing` and `invalid` → `401`.
   - **ID**: `update non-existing id` → `404`.
4. **Users / Boundary**: `name length = 1` → `201`.

## 8. Risks & Mitigations
- **Live public data may change** → schema kept light; strict comparisons restricted to pagination IDs.
- **Duplicate-email timing** → use deterministic seed/duplicate/cleanup flow.
- **Auth rate limits or token expiry** → keep token fresh and avoid excessive runs.

## 9. Reporting
- Run history in Postman Collection Runner.
- (Optional) Newman CLI with HTML report in CI (GitHub Actions) for automated verification.

## 10. Traceability Matrix (high-level)
| Requirement / Rule | Covered By (Collection Folder / Request) |
|---|---|
| Create user returns 201 with numeric `id` and echoed `email` | Users / Happy Path / Create user - 201 + save id |
| Get user by id returns 200 and correct `id` | Users / Happy Path / Get user by id - 200 |
| Update persists fields | Users / Happy Path / Update user (name/status) - 200 |
| Delete returns 204, subsequent GET is 404 | Users / Happy Path / Delete user - 204; Verify deleted user - 404 |
| Pagination: page 1 vs page 2 have no overlap | Users / Pagination / Page 2 |
| Invalid page falls back to page 1 set | Users / Pagination / invalid page |
| 422 error array shape + field targeting | Users / Negative (Email/Name/Gender/Status) |
| 401/404 error object has `message` | Users / Negative (Token, ID) |
| Boundary: minimal name length accepted | Users / Boundary / name length = 1 |
