# API Testing & Automation Project — Summary

This repository demonstrates **API test design & execution** for the public [GoREST Users API](https://gorest.co.in).  
It is part of a QA portfolio project to showcase structured **manual + Postman automation** skills.

---

## Objectives
- Validate core CRUD behavior on `/users` endpoints.
- Ensure robust error handling (401, 404, 422).
- Verify **pagination strictness** (page 1 vs page 2 → no overlap; invalid page → same set as page 1).
- Cover **boundary conditions** (e.g., minimal name length accepted).
- Audit **error message quality** for invalid enums (status, gender).

---

## Repository Structure
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
SUMMARY.md   ← (this file)
README.md
```

---

## Test Documentation
- [Test Plan](test-plan/TEST_PLAN.md) — objectives, scope, execution order, risks, and traceability matrix.  
- [Test Cases](test-cases/TEST_CASES.md) — detailed step-by-step tables (Happy Path, Negative, Pagination, Boundary, Error Quality).  
- [Known Issues](findings/KNOWN_ISSUES.md) — findings and improvement notes.

---

## Highlights
- **Happy Path:** full lifecycle (Create → Get by ID → List → Update → Delete → Verify 404).  
- **Negative:** Email, Name, Gender, Status, Token, ID (422/401/404).  
- **Boundary:** Minimal accepted values (name length = 1).  
- **Pagination:** No overlap between pages, invalid page = page 1 set.  
- **Error Quality (Enum fields):** clarity of messages for invalid `status` (TDD approach, toggleable strictness).  
- **Mock Server (TDD):** strict reference for expected error messages, independent of live API.
- **Flow Control:** selective skipping via `pm.execution.setNextRequest` to demonstrate complex run logic.
- **CI Integration:** automated Newman runs on GitHub Actions with live status badge + downloadable reports.

---

## Automation & CI

- **Newman CLI** — full collection runs with HTML reports (`newman-reporter-htmlextra`).
- **npm scripts** — shortcuts for local runs:
  - `npm run test:api` (full with report)
  - `npm run test:smoke` (smoke subset, no mocks, with bail)
- **Selective runs** — ability to run only specific folders (`--folder Pagination`, `--folder Negative`).
- **Fail-fast option** — stop on first failure (`--bail`) or stop when a folder fails (`--bail folder`).
- **Docker** — optional containerized run for consistency:
  - Build: `docker build -t gorest-tests .`
  - Run: `docker run --rm -e TOKEN=... -v "$PWD/reports:/app/reports" gorest-tests`
- **GitHub Actions CI**  
  - Runs Newman on every push/PR to `main`.  
  - Secrets managed via GitHub Actions (`GOREST_TOKEN`, `MOCK_BASE_URL`).  
  - Artifacts: downloadable Newman HTML report + JUnit XML.  
- **Badge in README** — live status of CI runs (passing/failing).

---

## How to Run
1. Import collection and environment in Postman.  
2. Set `token` in the environment (do **not** commit secrets).  
3. Run by folder in Postman Runner (or Newman in CI).  
   - Recommended order: Happy Path → Negative → Boundary → Pagination → Error Quality.  

---

## Value for QA Portfolio
This project illustrates:
- ✅ Professional test design (traceability, separation of plan/cases/findings).  
- ✅ API testing with **Postman assertions + environment data**.  
- ✅ Awareness of real-world issues (public API flakiness, vague error messages).  
- ✅ CI/CD readiness (Newman CLI, GitHub Actions optional, Docker optional).  
- ✅ TDD thinking via **Mock Server baseline** for strict error validation.  

---
