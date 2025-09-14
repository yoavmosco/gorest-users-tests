# GoREST Users API — QA Portfolio Summary

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
- ✅ CI/CD readiness (Newman CLI, GitHub Actions optional).  
- ✅ TDD thinking via **Mock Server baseline** for strict error validation.  

---
