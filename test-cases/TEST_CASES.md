# Test Cases — GoREST Users API

> IDs are suggestions; keep titles short and human-readable. Steps assume the Postman collection/environment provided in this repo.

## Happy Path
| ID | Title | Pre-conditions | Steps | Expected |
|---|---|---|---|---|
| TC-HP-01 | Create user — 201 + save id | Valid `token` set | POST `/users` with valid body and unique email | 201; body has numeric `id`; `email` matches input; save `userId` |
| TC-HP-02 | Get user by id — 200 | `userId` from TC-HP-01 | GET `/users/{userId}` | 200; body `id == userId` |
| TC-HP-03 | Get all users — 200 | — | GET `/users` | 200 |
| TC-HP-04 | Update user (name/status) — 200 | `userId` from TC-HP-01 | PUT `/users/{userId}` with `name`, `status` | 200; fields updated |
| TC-HP-05 | Delete user — 204 | `userId` from TC-HP-01 | DELETE `/users/{userId}` | 204; empty body |
| TC-HP-06 | Verify deleted user — 404 | After TC-HP-05 | GET `/users/{userId}` | 404; `{ message: <string> }` |

## Negative — Email
| ID | Title | Pre-conditions | Steps | Expected |
|---|---|---|---|---|
| TC-NE-01 | Create user — email missing — 422 | Valid `token` | POST without `email` | 422; body is **array**; item with `field=email` and `message` |
| TC-NE-02 | Create user — email invalid — 422 | Valid `token` | POST with `email=notvalid.com` | 422; error array with `field=email` |
| TC-NE-03 | Create seed user — 201 | Valid `token` | POST with unique `dupEmail`; save `dupUserId` | 201; numeric `id` saved |
| TC-NE-04 | Create user — email existing — 422 | After TC-NE-03 | POST with same `dupEmail` | 422; error array with `field=email`; message mentions duplicate/taken |
| TC-NE-05 | Cleanup seed user — 204 | After TC-NE-03 | DELETE `/users/{dupUserId}` | 204; empty body |

## Negative — Name
| ID | Title | Pre-conditions | Steps | Expected |
|---|---|---|---|---|
| TC-NN-01 | Create user — name missing — 422 | Valid `token`, unique `email` | POST without `name` | 422; error array with `field=name` |
| TC-NN-02 | Create user — name empty — 422 | Valid `token`, unique `email` | POST with `name=""` | 422; error array with `field=name` |
| TC-NN-03 | Create user — name space — 422 | Valid `token`, unique `email` | POST with `name=" "` | 422; error array with `field=name` |

## Negative — Gender
| ID | Title | Pre-conditions | Steps | Expected |
|---|---|---|---|---|
| TC-NG-01 | Create user — gender missing — 422 | Valid `token`, unique `email` | POST without `gender` | 422; error array with `field=gender` |
| TC-NG-02 | Create user — gender invalid — 422 | Valid `token`, unique `email` | POST with `gender="invalid gender"` | 422; error array with `field=gender` |

## Negative — Status
| ID | Title | Pre-conditions | Steps | Expected |
|---|---|---|---|---|
| TC-NS-01 | Create user — status missing — 422 | Valid `token`, unique `email` | POST without `status` | 422; error array with `field=status` |
| TC-NS-02 | Create user — status empty — 422 | Valid `token`, unique `email` | POST with `status=""` | 422; error array with `field=status` |
| TC-NS-03 | Create user — status space — 422 | Valid `token`, unique `email` | POST with `status=" "` | 422; error array with `field=status` |

## Negative — Token / ID
| ID | Title | Pre-conditions | Steps | Expected |
|---|---|---|---|---|
| TC-NT-01 | Create user — missing token — 401 | Token removed/empty | POST valid body with empty bearer | 401; body object with `message` mentioning authentication |
| TC-NT-02 | Create user — token invalid — 401 | Use fake token | POST valid body | 401; body object with `message` mentioning invalid token |
| TC-ID-01 | Update user — non-existing id — 404 | — | PUT `/users/10` (known missing) | 404; body object with `message` mentioning not found |

## Boundary
| ID | Title | Pre-conditions | Steps | Expected |
|---|---|---|---|---|
| TC-BD-01 | Create user — name length = 1 — 201 | Valid `token`, unique `email` | POST with `name="Q"` | 201; numeric `id` |

## Pagination
| ID | Title | Pre-conditions | Steps | Expected |
|---|---|---|---|---|
| TC-PG-01 | Pagination — Page 1 snapshot | — | GET `/users?page=1`; cache IDs (`users_page1_ids`) | 200; cache saved; cached count equals page length |
| TC-PG-02 | Pagination — Page 2 has no overlap | After TC-PG-01 | GET `/users?page=2`; compare with cached IDs | 200; **0** overlapping IDs with Page 1 |
| TC-PG-03 | Pagination — invalid page equals Page 1 (set-compare) | After TC-PG-01 | GET `/users?page=-1` (or non‑numeric); set-compare vs Page 1 | 200; same item **set** as Page 1 (order‑agnostic) |

## Error Quality
| ID | Title | Pre-conditions | Steps | Expected |
|---|---|---|---|---|
| TC-EQ-01 | Create user — status invalid (string) — 422 | Valid `token`, unique `email` | POST with `status="invalid status"` | 422; error **array** includes `field=status`; message ideally specific (e.g., “invalid / must be one of …”) |
| TC-EQ-02 | Create user — status invalid (number) — 422 | Valid `token`, unique `email` | POST with `status=1` | 422; error **array** includes `field=status`; message ideally specific (e.g., “invalid / must be one of …”) |

> Note: Specificity check is **toggleable** with `STRICT_ERROR_QUALITY=true` (env/collection) — when enabled, tests fail unless the message is explicit about allowed enum values.

## Mock (TDD)
| ID       | Title | Pre-conditions        | Steps | Expected |
|----------|-------|-----------------------|-------|----------|
| TC-MK-01 | Mock: invalid `status` (number) — 422 strict | `mockBaseUrl` set | POST `{{mockBaseUrl}}/users` with `status=123` | 422; error array includes `field=status`; message specific (enum) |
| TC-MK-02 | Mock: invalid `status` (string) — 422 strict | `mockBaseUrl` set | POST `{{mockBaseUrl}}/users` with `status="abc"` | 422; error array includes `field=status`; message specific (enum) |
