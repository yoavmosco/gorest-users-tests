# Test Plan — GoREST Users API (Postman)

## 0. Assumptions & Versions
- API base: `https://gorest.co.in/public/v2` (GoREST v2).
- Tooling: Node 18.x, Newman 6.x, newman-reporter-htmlextra 1.x.
- OS: Windows/Ubuntu (CI runs on `ubuntu-latest`).
- Network: open internet access (required for GoREST API and Postman Mock Server).
- Repo: no secrets are committed to version control; secrets (e.g., API token, mockBaseUrl) are injected via local environment or CI only.
- Execution: tests can be run locally (Postman UI / Newman CLI) or automatically in CI (GitHub Actions workflow).

## 1. Objective
Validate core behavior of the GoREST **Users** API using a Postman collection, ensuring:
- CRUD happy-path works (create → read → update → delete → verify 404).
- Robust error handling for 401/404/422.
- Pagination behaves deterministically (no overlap between pages; invalid page falls back to page 1 item set).
- Basic boundary checks (e.g., minimal name length).
- Error message quality is clear and specific (not vague).
- Error message quality validated against both the live API (observation mode) and a Postman Mock Server (Definition of Done, TDD strict baseline).

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
- Error quality tests (status invalid) run in TDD style — toggleable strictness.
- Mock Server defines the expected strict messages and serves as the TDD baseline, independent of live API behavior.

## 5. Environments & Data
- `baseUrl = https://gorest.co.in/public/v2`
- `token` — required locally and in CI, never committed to the repo.
- `mockBaseUrl` — Postman Mock Server URL used for Error Quality (TDD) folder.
- **Secret management**
  - Local: `postman/env/GoREST Local.postman_environment.json` (do not commit real secrets).
  - CI: `GOREST_TOKEN`, `MOCK_BASE_URL` (GitHub Actions secrets).
- **Test data**
  - Unique email per run: `qa_<timestamp>@example.com`.
  - Deterministic duplicate-email flow: **seed (201) → duplicate (422) → cleanup (204)**.

## 6. Entry & Exit Criteria
**Entry**
- Collection & environment imported.
- Valid personal access token configured in the Postman environment.

**Exit**
- All **Happy Path** tests pass.
- All **Negative** tests return expected 4xx with expected shapes/messages.
- Pagination rules verified (no overlap; invalid page == page 1 set).
- Boundary checks pass as defined.
- Mock-based Error Quality tests always pass (baseline strict expectation), while live API runs pass in observation mode unless strict mode is enabled.

## 7. Test Execution Order (recommended)
1. **Happy Path**: `Create (201)` → `Get by id (200)` → `Get all (200)` → `Update (200)` → `Delete (204)` → `Verify 404`.
2. **Negative**:
   - **Email**: `Create seed (201)` → `Duplicate (422)` → `Cleanup (204)`; plus `missing` and `invalid format` cases.
   - **Name**: `missing`, `empty`, `space` → `422`.
   - **Gender**: `missing`, `invalid enum` → `422`.
   - **Status**: `missing`, `empty`, `space` → `422`.
   - **Token**: `missing` and `invalid` → `401`.
   - **ID**: `update non-existing id` → `404`.
3. **Boundary**: `name length = 1` → `201`.
4. **Pagination**: `page=1` → `page=2` → `invalid page` (no data mutations).
5. **Error Quality**: invalid `status` (string/number) → `422` with specific message.
6. **Error Quality — Mock Server (TDD)**: `{{mockBaseUrl}}/users` — invalid `status` (string/number) → `422` with **specific** enum message (strict).

### 7a. Flow Control
- Certain reference requests (e.g., DEF requests) are **kept in the collection** for documentation/manual runs, but are **skipped automatically** during collection runs.
- Implemented via `pm.execution.setNextRequest()` to jump directly to the next relevant test.
- Purpose: maintain a clean automated run in Runner/Newman, while preserving useful reference requests in the repo.

### 7b. CLI Profiles (Runner / Newman)
- **Full**: All folders (default). Produces HTML report.
- **Smoke**: `Happy Path`, `Negative`, `Boundary`, `Pagination` only — **no Mock**, with `--bail` enabled (fail fast).
- **CI**: Full run with secrets injected; publishes HTML + JUnit as artifacts.
  - Local shortcuts:
    - `npm run test:api` → Full with HTML report.
    - `npm run test:smoke` → Smoke subset, no Mock, `--bail`.

## 8. Risks & Mitigations
- **Live public data may change** → schema kept light; strict comparisons limited to pagination IDs.
- **Duplicate-email timing** → deterministic seed/duplicate/cleanup flow.
- **Orphaned test data (leftover users)** → avoided via cleanup steps in Negative tests.
- **Auth rate limits or token expiry** → keep token fresh; avoid excessive runs.
- **Vague error messages in live API** → mitigated by Mock Server baseline (strict expected messages).

## 9. Reporting
- Postman Runner: run history for manual executions.
- Newman:
  - Console output (CLI).
  - HTML (htmlextra) — saved to `reports/newman.html`.
  - JUnit XML — saved to `reports/junit.xml` (for CI analytics).
- CI (GitHub Actions):
  - Triggers on every push/PR to `main`.
  - **Artifacts**: `newman-reports` bundle with `newman.html` + `junit.xml` downloadable from each run.
  - Live **status badge** shown in README.

## 10. Traceability Matrix (high-level)
| Requirement / Rule | Covered By (Collection Folder / Request) |
|---|---|
| Create user returns 201 with numeric `id` and echoed `email` | Happy Path / Create user - 201 + save id |
| Get user by id returns 200 and correct `id` | Happy Path / Get user by id - 200 |
| Update persists fields | Happy Path / Update user (name/status) - 200 |
| Delete returns 204, subsequent GET is 404 | Happy Path / Delete user - 204; Verify deleted user - 404 |
| 422 error array shape + field targeting | Negative (Email/Name/Gender/Status) |
| 401/404 error object has `message` | Negative (Token, ID) |
| Boundary: minimal name length accepted | Boundary / name length = 1 |
| Pagination: collect IDs for Page 1 | Pagination / Page 1 |
| Pagination: page 2 has no overlap with page 1 | Pagination / Page 2 |
| Invalid page falls back to page 1 set | Pagination / invalid page |
| Error quality: invalid `status` has clear, specific message (TDD) | Error Quality / status invalid (string, number) — Live API (observation/strict) + Mock Server (baseline) |

## 11. Automation & CI
- **Local**:
  - `npm run test:api` — full run with HTML report.
  - `npm run test:smoke` — main subsets only (no Mock), with `--bail` enabled.
- **CI (GitHub Actions)**:
  - Runs on every push/PR to `main`.
  - Secrets: `GOREST_TOKEN`, `MOCK_BASE_URL`.
  - Artifacts: Newman HTML + JUnit reports available for download from each workflow run.
  - Selective runs supported via CLI flags: `--folder` for subsets, `--bail folder` to stop early at folder level.
