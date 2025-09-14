# Known Issues & TDD Notes — GoREST `/users`

## Findings (current behavior observed)
| Area          | Case                                  | Expected                                                           | Observed                              | Status |
|---------------|---------------------------------------|--------------------------------------------------------------------|---------------------------------------|--------|
| Error message | `status` invalid (string/number)      | 422 with **specific** enum message (“invalid / must be one of…”)   | Sometimes “status can’t be blank”     | Tracked (observation tests). Recommendation: API should return explicit enum validation message. |
| Pagination    | `page=-1` (or non-numeric)            | 4xx or documented behavior                                         | `200`, same items as page=1           | Documented fallback (observed). Recommendation: Document officially or adjust to return error. |

> These are **not necessarily bugs** in the API, but important behaviors to document for clients.

## How tests support TDD
- Error-message quality tests run **observation-only** by default (keep runs green).  
- To enforce TDD for a fix, set `STRICT_ERROR_QUALITY=true` (env/collection). Tests will **fail** until the API returns the specific message; after a fix they turn green.
- A Postman Mock Server defines the **expected** error messages for invalid `status`.  
  - These mock tests run **independently of `STRICT_ERROR_QUALITY`** (they always expect the strict message).  
  - In observation mode: live API tests just document current behavior.  
  - In strict mode: live API tests fail until they match the enum message.  
  - The Mock folder *Error Quality – Mock Server (TDD)* acts as the **Definition of Done** reference.
  - **Note:** The DEF request is kept for reference/documentation, but is skipped in automated runs using flow control (`postman.setNextRequest`).

## Bug/Issue Template
**Title:** `/users` – invalid `status` returns generic message

**Steps to Reproduce**
1. `POST /users` with body containing `"status": 123` *(or `"abc"`)*  
2. Observe `422` with error item for `field="status"`

**Expected**
- Error message indicates invalid enum (e.g., “status is invalid; must be one of: active, inactive”).

**Observed**
- Message sometimes says “status can’t be blank” although a value was provided.

**Acceptance Criteria**
- Error message contains “invalid” or “must be one of: active, inactive”.

**Verification**
- Postman tests under **Error Quality** pass in **strict mode** (`STRICT_ERROR_QUALITY=true`).  
- Cross-checked against Mock Server reference (always strict).

