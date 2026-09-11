# Development & Environment Setup Guide — Vela Player

This guide provides instructions for bootstrapping the Vela Player project locally on Windows, macOS, and Linux.

---

## 1. System Prerequisites

### Mobile Development
- **Flutter SDK**: `>= 3.24.0` (Dart SDK `>= 3.5.0`)
- **Android Studio / Android SDK**:
  - `build-tools`: `36.0.0`
  - `compileSdk`: `36` (Android 16)
  - `minSdk`: `24`
  - JDK: `OpenJDK 17`
- **Xcode** (macOS only):
  - Xcode `26.0+`
  - iOS Deployment Target: `16.0+`
  - CocoaPods: `>= 1.14.0`

### Backend Development
- **Python**: `>= 3.11`
- **PostgreSQL**: `>= 16.0`
- **Redis**: `>= 7.0`
- **Docker & Docker Compose**: Recommended for local containerized development

---

## 2. Setting Up the Flutter Application

```bash
# 1. Fetch dependencies for main app and modular packages
flutter pub get

# 2. Run static analysis
flutter analyze

# 3. Execute all automated tests
flutter test

# 4. Launch on connected device / emulator
flutter run
```

---

## 3. Setting Up the Backend Modular Monolith

```bash
cd backend

# 1. Create virtual environment
python -m venv .venv
source .venv/bin/activate  # Or .venv\Scripts\activate on Windows

# 2. Install dependencies
pip install -e .

# 3. Start local development server with live reload
uvicorn app.main:app --reload --port 8000
```

The interactive OpenAPI documentation will be accessible at `http://localhost:8000/api/v1/docs`.

---

## 4. Git Branching & Contribution Workflow

- **Branch Naming Conventions**:
  - `feature/<ticket-or-feature-name>` (e.g. `feature/sub-drift-sync`)
  - `fix/<bug-description>` (e.g. `fix/ass-tag-cleaning`)
  - `release/<vX.Y.Z>`
- **Commit Messages**: Follow Conventional Commits:
  - `feat: add 2-point drift interpolation algorithm`
  - `fix: correct file picker call on Android 16`
  - `docs: update master engineering prompt`
