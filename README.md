# SUVIDHA Urban Integrated Municipal ERP — Flutter Mobile App Knowledge & Integration Spec
## Shared Context for AI Agents & Mobile Developers

This document serves as the **Single Source of Truth** for the Flutter mobile application (`urban-mobile`). Any AI agent or developer building or modifying the mobile app must adhere to the rules, API contracts, and architectural laws documented below.

---

## 1. Network Topology & Environment Configuration

The backend services run in Docker on the host computer. When running the Flutter mobile app, network hostnames depend on the execution target:

| Target Environment | Backend Core Service API | Keycloak SSO Base URL | PostgreSQL (Reference) |
|---|---|---|---|
| **Android Emulator** | `http://10.0.2.2:8000/api/v1` | `http://10.0.2.2:8085` | `10.0.2.2:5432` |
| **Physical Android Device (via USB `adb reverse`)** | `http://localhost:8000/api/v1` | `http://localhost:8085` | `localhost:5432` |
| **Physical Android Device (Same Wi-Fi Network)** | `http://<YOUR_LAN_IP>:8000/api/v1` | `http://<YOUR_LAN_IP>:8085` | `<YOUR_LAN_IP>:5432` |

### Physical Device Port Forwarding Tip:
Run these commands in PowerShell to mirror ports to an Android device connected via USB:
```powershell
adb reverse tcp:8000 tcp:8000
adb reverse tcp:8085 tcp:8085
```

---

## 2. Multi-Tenancy Architectural Law

Urban ERP is a 3-tier multi-tenant SaaS platform:
* **Level 0: Platform Super Admin** (Global overview)
* **Level 1: State Tenant** (e.g. Telangana `TG`, Maharashtra `MH`, Tripura `TR`)
* **Level 2: Sub-Tenant / ULB** (e.g. Greater Warangal `GWMC`, Greater Hyderabad `GHMC`)

### Compulsory HTTP Request Headers
**Every single network request** sent to `/api/v1/*` must include these three headers:
```http
Authorization: Bearer <JWT_ACCESS_TOKEN>
X-Tenant-ID: <STATE_CODE_OR_TENANT_ID>       # e.g., "TG" or "GWMC"
X-Sub-Tenant-ID: <ULB_CODE_OR_SUB_TENANT_ID> # e.g., "GWMC" or "GHMC"
```
*Never send tenant-blind requests.*

---

## 3. Keycloak SSO & Direct Authentication Specifications

### 3.1 Keycloak SSO Configuration
* **Realm**: `urban`
* **Client ID**: `urban-web`
* **Token Issuer URL**: `http://10.0.2.2:8085/realms/urban`
* **Discovery Endpoint**: `http://10.0.2.2:8085/realms/urban/.well-known/openid-configuration`
* **Redirect URI Scheme**: `org.suvidha.urban://oauth2redirect`
* **Auth Protocol**: Authorization Code Flow with PKCE (Proof Key for Code Exchange)
* **Scopes**: `openid profile email offline_access`

### 3.2 Direct Signin Endpoint (Fallback / Alternative to Keycloak SSO)
* **Endpoint**: `POST /api/v1/auth/signin`
* **Request Body**:
```json
{
  "username": "officer@gwmc.gov.in",
  "password": "urban@123",
  "tenantId": "GWMC"
}
```
* **Response Body (`AuthResponse`)**:
```json
{
  "accessToken": "eyJhbGciOi...",
  "tokenType": "bearer",
  "expiresIn": 86400,
  "user": {
    "id": "USR-GWMC-002",
    "username": "officer@gwmc.gov.in",
    "name": "K. V. Rao",
    "role": "revenue_officer",
    "roles": ["revenue_officer", "ptx_collector"],
    "tenantId": "GWMC",
    "assignedModules": ["PTX", "WTR", "TRL", "UCH", "FIN", "DMS"]
  },
  "accessibleTenants": [
    {
      "stateCode": "TG",
      "stateName": "Telangana",
      "status": "Active",
      "ulbs": [
        {
          "code": "GWMC",
          "name": "Greater Warangal Municipal Corporation",
          "ulbType": "Municipal Corporation",
          "district": "Warangal",
          "stateCode": "TG"
        }
      ]
    }
  ]
}
```

---

## 4. First Module Specification: Property Tax & Revenue (PTX)

The primary mobile use case is for **Field Tax Inspectors & Assessment Surveyors**.

### 4.1 Relevant Component RBAC Action Codes:
* `PTX-P01`: Property registration and identification
* `PTX-P03`: Property survey and GIS reconciliation
* `PTX-P05`: New assessment – built property
* `PTX-P10`: General revision of rates and zones

### 4.2 Property Tax API Endpoints:

#### 1. Dashboard KPI Summary
* **Endpoint**: `GET /api/v1/properties/stats/summary`
* **Headers**: `Authorization`, `X-Tenant-ID`, `X-Sub-Tenant-ID`
* **Response**:
```json
{
  "totalParcels": 4250,
  "totalUnits": 5120,
  "totalDemand": 4820000.0,
  "totalCollected": 3663200.0,
  "residentialCount": 3800,
  "commercialCount": 1320,
  "wardCount": 66
}
```

#### 2. Search & List Properties
* **Endpoint**: `GET /api/v1/properties?q={query}&wardId={wardId}&taxStatus={PAID|DUE|ARREARS}&limit=50&offset=0`
* **Response Array Item (`PropertySummary`)**:
```json
{
  "id": "uuid-parcel-1",
  "ulpin": "TG-GWMC-506001-00123",
  "surveyNumber": "142/A",
  "address": "H.No 2-4-123, Postal Colony, Subedari, Hanamkonda",
  "wardNumber": 12,
  "wardName": "Subedari West",
  "buildingType": "Residential",
  "totalUnits": 1,
  "ptin": "PTIN-GWMC-2026-00042",
  "ownerName": "Ramesh Chandra",
  "usageCategory": "Residential",
  "currentDemandAmount": 4250.0,
  "taxStatus": "DUE"
}
```

#### 3. Property Detail View
* **Endpoint**: `GET /api/v1/properties/{ulpin}`
* **Response (`PropertyDetailResponse`)**:
Contains full parcel bounds, building dimensions, constructed floor area, occupancy type, arrears history, and owner contact details.

#### 4. Wards & Boundaries
* **Endpoint**: `GET /api/v1/boundaries/wards`
* **Response**: List of wards in current ULB with `wardNumber`, `wardName`, `councilorName`.

---

## 5. Official 19 Municipal Modules Reference

| Code | Module Name | Domain | Mobile Field Relevance |
|---|---|---|---|
| **PTX** | Property Tax & Revenue | Revenue & Billing | High (Survey, geotagging, demand spot delivery) |
| **WTR** | Water & Sewerage Billing | Revenue & Billing | High (Meter reading capture, photo proof) |
| **TRL** | Trade Licences | Revenue & Billing | High (On-site commercial shop inspection) |
| **UCH** | User Charges | Revenue & Billing | Medium (Spot receipt generation) |
| **MPM** | Municipal Property | Revenue & Billing | Medium (Asset verification) |
| **GRV** | Citizen Grievance & RTI | Citizen Engagement | High (Spot inspection, photo resolution upload) |
| **GSC** | Government Schemes | Citizen Engagement | Medium (Beneficiary verification) |
| **BPM** | Building Permissions | Planning & Regulation | High (Site setback inspection, construction stage audit) |
| **TPL** | Town Planning | Planning & Regulation | Medium (Masterplan zoning lookup) |
| **FNC** | Fire NOC | Planning & Regulation | High (Fire safety hydrant verification) |
| **LGL** | Legal Cases | Planning & Regulation | Low (Court date lookup) |
| **SWM** | Solid Waste Management | Field Infrastructure | High (Dump truck route tracking, bin fill level) |
| **ENG** | Engineering Projects / e-MB | Field Infrastructure | High (Work measurement book, photo proof of work) |
| **SLM** | Street Lights | Field Infrastructure | High (Defective pole reporting, repairs) |
| **PRK** | Parks & Horticulture | Field Infrastructure | Medium (Park maintenance audit) |
| **INV** | Inventory & Stores | Finance & Admin | Medium (Depot dispatch scan) |
| **FIN** | Finance & Accounting | Finance & Admin | Low (Voucher approvals) |
| **HRM** | Payroll & HR | Finance & Admin | High (Field staff geo-fenced attendance) |
| **DMS** | Document Management | Finance & Admin | Medium (Field document lookup) |

---

## 6. Design System & UI Standards (Hake Design Tokens)

The mobile app must maintain visual parity with SUVIDHA design tokens:
* **Primary Navy**: `#0E3A52` (`AppColors.primaryNavy`)
* **Secondary Teal**: `#1B8C77` (`AppColors.secondaryTeal`)
* **Accent Saffron**: `#D98A2B` (`AppColors.accentSaffron`)
* **Deep Sidebar / Surface**: `#071532` (`AppColors.surfaceDark`)
* **Background Canvas**: `#F7F5F1` (`AppColors.backgroundCream`)
* **Border Beige**: `#E5DFD2` (`AppColors.borderBeige`)
* **Status Colors**:
  - Paid / Success: `#3D8D51`
  - Due / Warning: `#D98A2B`
  - Arrears / Danger: `#B23A2E`

### Touch Target Rule:
All interactive controls (buttons, dropdowns, list tiles, icons) must have minimum touch bounds of **$44 \times 44\text{px}$** for sunlight-readable municipal field use.

---

## 7. Recommended Flutter Project Structure (`urban-mobile`)

```text
urban-mobile/
├── AGENTS.md                          # (Copy of this specification)
├── pubspec.yaml
├── android/
│   └── app/src/main/AndroidManifest.xml # Contains redirect scheme: org.suvidha.urban
└── lib/
    ├── main.dart                      # App entry point
    ├── core/
    │   ├── api/
    │   │   ├── api_client.dart        # Dio + X-Tenant-ID & Bearer interceptor
    │   │   └── api_endpoints.dart     # Central route definitions
    │   ├── auth/
    │   │   ├── auth_service.dart      # Keycloak SSO (PKCE) & Signin fallback
    │   │   └── token_storage.dart     # FlutterSecureStorage wrapper
    │   ├── theme/
    │   │   └── app_theme.dart         # Colors, typography, buttons
    │   └── models/
    │       ├── auth_response.dart
    │       └── tenant_context.dart    # Active State and ULB signals/state
    ├── modules/
    │   ├── dashboard/
    │   │   ├── views/dashboard_screen.dart # 19-module responsive grid
    │   │   └── widgets/module_card.dart
    │   └── ptx/                       # Module 1: Property Tax & Assessment
    │       ├── models/property.dart
    │       ├── repositories/property_repository.dart
    │       ├── state/property_provider.dart
    │       └── views/
    │           ├── ptx_home_screen.dart     # Stats + Search + Filter
    │           ├── property_detail_screen.dart
    │           └── field_inspection_screen.dart # Camera + GPS coordinates
    └── shared/
        └── widgets/
            ├── tenant_header.dart     # State/ULB switcher bar
            └── rbac_guard.dart        # Action permission checker
```
