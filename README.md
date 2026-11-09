# EcoCollect – Responsive E-Waste Collection Platform

EcoCollect is a modern, eco-friendly Flutter application built to empower users to responsibly dispose of unused electronics, household gadgets, cables, and batteries. The platform connects consumers with sustainable electronic waste recycling logistics, ensuring zero landfill disposal.

---

## 📱 Features

- **Screen 1: Home Dashboard**
  - EcoCollect branding and welcome banner (*"Give Your Old Electronics a New Purpose!"*).
  - Quick action buttons: **Schedule a Pickup** and **Track Pickups**.
  - Real-time statistics: Total items submitted, pending pickups, and collected/recycled items.
  - **What Can You Recycle?** section featuring 7 electronic waste categories with icons and recycling tips (Mobile Phones, Laptops and Computers, Batteries, Chargers and Cables, Televisions, Keyboards and Accessories, Other Electronics).
  - Dynamic recycling awareness tip card with rotating environmental facts.
  - Recent collection requests list with one-tap access to details.

- **Screen 2: Add E-Waste**
  - Category dropdown with icons.
  - Device name and model specification.
  - Photograph upload via **Camera** or **Gallery** (`image_picker`) with instant thumbnail preview and removal.
  - Quantity input counter (`+` / `-`).
  - Device condition selector: **Working**, **Damaged**, **Not Working**.
  - Additional descriptions and notes.
  - Input validation for required fields.

- **Screen 3: Pickup Booking**
  - Customer contact details (Name, Phone number).
  - Pickup address (Street, City, PIN code).
  - Preferred pickup date selector using Material 3 `DatePicker`.
  - Preferred time window: **Morning** (9 AM - 12 PM), **Afternoon** (12 PM - 4 PM), **Evening** (4 PM - 8 PM).
  - Unique Request ID generation (e.g., `ECO-2026-XXXX`).
  - Submission confirmation screen and initial `Pending` status.

- **Screen 4: My Requests**
  - Search bar filtering by device name, request ID, category, or city.
  - Filter chips across statuses: `All`, `Pending`, `Pickup Scheduled`, `Collected`, and `Recycled`.
  - Clear `Demo Data` tags identifying simulated records.
  - Cards displaying item count, scheduled pickup date, condition, and status.

- **Screen 5: Request Details**
  - Complete specifications and photograph preview.
  - Pickup logistics and customer details.
  - **Progress Timeline**:
    $$\text{Pending} \longrightarrow \text{Pickup Scheduled} \longrightarrow \text{Collected} \longrightarrow \text{Recycled}$$
  - **Interactive Lifecycle Simulator**: Evaluator button to advance status through each step for demonstration and testing.
  - Cancel request option for pending collections.

- **Screen 6: Profile & Environmental Footprint**
  - Demo user profile with customizable details.
  - Calculated environmental footprint metrics:
    - E-waste diverted (kg)
    - CO2 emissions avoided (kg)
    - Equivalent trees preserved per year
  - About EcoCollect mission statement and prototype disclaimer.
  - Testing utilities: "Reset to Sample Data" and "Clear All Data".

---

## 💻 Responsive Design

EcoCollect utilizes `LayoutBuilder` and `MediaQuery` to deliver an adaptive user experience:
- **Mobile (< 640px)**: Bottom `NavigationBar`.
- **Tablet (640px – 1024px)**: Compact `NavigationRail`.
- **Desktop (> 1024px)**: Extended `NavigationRail` with labels and multi-column grid layouts.

---

## 🛠️ Technology Stack

- **Framework**: Flutter 3.44.8 & Dart 3.12.2 (Null-safe)
- **UI Design**: Material 3 Design with emerald green eco-palette
- **State Management**: `StatefulWidget`, `setState`, and `ChangeNotifier`
- **Local Storage**: `shared_preferences` (persists requests and Base64 encoded photos locally)
- **Image Handling**: `image_picker` (Camera and Gallery support)
- **Formatting**: `intl` package for calendar dates and time formatting

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Chrome or Edge browser (for Web), or Windows / Android / iOS build tools

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Roshini7788/E_Waste-app.git
   cd E_Waste-app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on Web (localhost):**
   ```bash
   flutter run -d chrome
   # or run on custom localhost port:
   flutter run -d web-server --web-port=8080 --web-hostname=localhost
   ```

4. **Run on Windows Desktop:**
   ```bash
   flutter run -d windows
   ```

5. **Run test suite:**
   ```bash
   flutter test
   flutter analyze
   ```

---

## 📄 Prototype Disclaimer

*EcoCollect is a functional frontend prototype demonstrating sustainable e-waste logistics. Collection requests are stored locally on your device via `shared_preferences`. No real collection vehicles are dispatched.*
