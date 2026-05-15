# Forma: iOS-First Desktop Organization & Intelligence App

## 1. Product Vision
Forma is an "environment-aware" (Context-Aware) desktop enhancement system. It acts as a personal desktop command center. Instead of relying on static grids of icons, Forma intelligently anticipates the user's intent based on context (time, focus mode, location) and provides immediate access to the necessary applications. 

## 2. Core Paradigms
- **iOS-First:** The primary interaction model is designed around iOS paradigms, specifically highly interactive and predictive Widgets, with a robust main app for configuration.
- **Space-Centric:** The system is divided into "Spaces" (e.g., Work, Personal, Creative). Each space is an independent container with its own rules, candidate apps, and machine learning weights.
- **Hybrid Intelligence:** 
  - **Deterministic Rules:** Users can set hard rules ("If Work Focus is on, show Jira and Slack").
  - **Probabilistic Learning:** The system learns from user behavior (frequency and sequence of app usage) to predict the next needed app.
- **Frictionless Correction:** Users can correct the system's predictions seamlessly by dragging and dropping the correct app over a predicted one, which automatically creates a permanent top-priority rule.

## 3. Architecture Overview

### A. Context Observation Layer (Sensors)
Monitors system state to build a `Context` snapshot.
- Time & Date
- Focus Modes
- Connected Devices (Bluetooth, Wi-Fi SSID)
- Location (Geofencing)

### B. Intent Engine Layer (Brain)
Responsible for evaluating the `Context` and determining the active `Space` and visible `Apps`.
1. **Rule Evaluator:** Checks if any hard rules are met.
2. **Learning Model:** If rules are ambiguous or not strictly defining the layout, it applies learned weights (based on frequency and recency).
3. **Conflict Resolver:** Arbitrates between manual rules and ML suggestions, prioritizing explicit user intent.

### C. Presentation Layer (UI)
- **Main App:** Space management, Visual Rule Editor (If [Context] Then [Display]), and drag-and-drop hierarchy.
- **iOS Widget:** Powered by `WidgetKit`. Uses a predictive timeline to update icons dynamically without launching the app.
- **macOS Overlay (Future):** A "Ghost Layer" that sits above the wallpaper but below desktop icons, rendering liquid tiles that fluidly transition as context changes.

## 4. Implementation Roadmap
- **Phase 1 (Core Models):** Define `Space`, `Rule`, `Context`, and `AppID`. Implement the foundation of the Rule Engine.
- **Phase 2 (Intelligence):** Implement frequency-based local learning algorithms and conflict arbitration.
- **Phase 3 (iOS UI):** Build the Main App interface, including the Space Switcher and visual Rule Editor block-UI.
- **Phase 4 (Widget):** Develop high-performance iOS Widgets with fluid transitions.
- **Phase 5 (macOS):** Migrate the core engine to macOS and implement the desktop overlay.
