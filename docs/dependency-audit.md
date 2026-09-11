# Dependency & Open-Source License Audit — Vela Player

---

## 1. Core Framework & Engine Libraries

| Package | Version | License | Platform Support | Commercial Usage Permitted | Notes |
|---|---|---|---|:---:|---|
| `flutter` | `>= 3.24.0` | BSD-3-Clause | Android, iOS, Windows, macOS, Linux, Web | Yes | Official Google framework. |
| `media_kit` | `^1.2.6` | MIT | Android, iOS, Windows, macOS, Linux | Yes | libmpv / FFmpeg wrapper supporting hardware acceleration. |
| `flutter_riverpod` | `^3.4.3` | MIT | All | Yes | Reactive unidirectional state management. |
| `google_fonts` | `^8.2.1` | Apache-2.0 | All | Yes | Dynamic typographic font loading (Outfit, Inter, Readex Pro). |
| `file_picker` | `^12.3.0` | MIT | All | Yes | Native document picker integration conforming to modern storage policies. |
| `shared_preferences` | `^2.5.5` | BSD-3-Clause | All | Yes | Local key-value persistence for settings and preferences. |
| `path_provider` | `^2.1.6` | BSD-3-Clause | All | Yes | Sandbox filesystem paths. |

---

## 2. Backend & Cloud Stack Libraries

| Package | Version | License | Commercial Usage Permitted | Security & Maintenance Notes |
|---|---|---|:---:|---|
| `fastapi` | `>= 0.115.0` | MIT | Yes | Actively maintained asynchronous web framework. |
| `uvicorn` | `>= 0.30.0` | BSD-3-Clause | Yes | Production ASGI server. |
| `pydantic` | `>= 2.8.0` | MIT | Yes | Strict runtime schema parsing and validation. |
| `asyncpg` | `>= 0.29.0` | Apache-2.0 | Yes | High-performance asynchronous PostgreSQL driver. |
| `redis` | `>= 5.0.8` | MIT | Yes | Official Redis client for queue and pub/sub. |
| `python-jose` | `>= 3.3.0` | MIT | Yes | Cryptographic JWT generation and verification. |

---

## 3. Compliance Affirmation
All dependencies bundled into the client applications utilize permissive open-source licenses (MIT, Apache 2.0, BSD). Zero GPL/AGPL copyleft libraries are linked in ways that compromise commercial redistribution rights.
