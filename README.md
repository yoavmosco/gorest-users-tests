# GoREST – Users API Tests (Postman)

Tests for GoREST **Users** API focusing on happy-path, negative, pagination (strict), boundary, and error-message quality.

## What’s covered
- Folder-level checks (status / array / light schema).
- Request-level assertions for each scenario under `/users`.
- **Pagination (strict)**:
  - Page 2 has **no overlap** with Page 1 (0 shared IDs).
  - Invalid `page` (e.g. `-1`) returns the **same item set** as Page 1 (order-agnostic).
- **Error quality audits**: verify clarity for 4xx (duplicate email, invalid enums).

## How to run (Postman UI)
1. Import collection: `postman/GoREST Users Tests.postman_collection.json`
2. Import environment: `postman/env/GoREST Local.postman_environment.json`
3. **Set environment variable:** `token` (insert your personal GoREST API token in Postman UI; never commit it to Git).
   - `baseUrl` is already preconfigured in the environment file.
4. Run folders:
   - Pagination: run page=1 → page=2 → invalid.
   - Negative / Email: **Seed (201)** → **Duplicate (422)** → **Cleanup (204)**.
   - Other 422 tests (missing/invalid format) are independent.

## How to run (Newman CLI)
This project also includes a ready-to-run Newman setup.

### Prerequisites
- [Node.js](https://nodejs.org/) (v16+)
- Run `npm install` in the project root to install `newman` and `newman-reporter-htmlextra`.

### Run Locally
Runs the collection with your local **secret** environment and generates an HTML report:

```bash
npm run test:api
```

## Challenges & solutions
- **Schema failed on 404**  
  *Fix:* schema guard — run only on **2xx JSON**. For the delete-verify step, assert **404 + message** without schema.
- **Duplicate email stability**  
  *Problem:* pre-request seeding was async → sometimes got `201` instead of `422`.  
  *Fix:* deterministic flow **Seed → Duplicate (422) → Cleanup (204)**.

### Error quality as TDD
Assertions for **clear error messages** and correct **4xx codes** are written first and then used as **TDD** until the behavior matches.  
Example focus: duplicate email (422), invalid enums, missing required fields.

## Mock-based TDD (Postman Mock Server)
Following the section above, this mock server was created to demonstrate the TDD approach for invalid error messages, specifically showing the desired fix for invalid `status` messages.

**Folder:** `Users / Error Quality – Mock Server (TDD)`  
**How it works:**
- `DEF: POST /users — invalid status (422 example only)` holds a 422 Example used by the mock (do **not** run it).  
- Runnable requests:  
  - `MOCK: invalid status (string)`  
  - `MOCK: invalid status (number)`  
  These call `{{mockBaseUrl}}/users` with invalid values and always assert the **STRICT** message:  
  ```json
  [
    {
      "field": "status",
      "message": "status is invalid; must be one of: active, inactive"
    }
  ]

**Environment:** add `mockBaseUrl = https://<your-mock-id>.mock.pstmn.io` (No Auth required for the mock).

## Repo structure
```
postman/
├─ GoREST Users Tests.postman_collection.json
└─ env/
   └─ GoREST Local.postman_environment.json
test-plan/
└─ TEST_PLAN.md
test-cases/
└─ TEST_CASES.md
findings/
└─ KNOWN_ISSUES.md
```

## Known issues / Findings
| ID  | Title                                | Type            | Repro (high level)                 | Expected               | Actual                 | Status/Notes                        |
|-----|--------------------------------------|-----------------|-----------------------------------|------------------------|------------------------|------------------------------------- |
| K1  | Invalid `page` falls back to Page 1  | Finding         | GET `/users?page=-1` after Page 1 | Error or explicit empty | Same item set as Page 1 | Covered by strict compare test      |
| K2  | Error messages for invalid enums can be vague | Potential issue | POST `/users` with `status=123` | “must be one of …”     | “can’t be blank”       | Using error-quality tests as TDD    |

## Documentation
- [Summary](SUMMARY.md)
- [Test Plan](test-plan/TEST_PLAN.md)
- [Test Cases](test-cases/TEST_CASES.md)
- [Known Issues](findings/KNOWN_ISSUES.md)

## Future Improvements
- CI integration with Newman + HTML reports (GitHub Actions).  
- Continuous documentation of new findings as API evolves.  

