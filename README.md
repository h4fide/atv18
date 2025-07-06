# ATV18 Simulator

A minimal viable product (MVP) Android app simulating the ATV18 Variable Frequency Drive (VFD).

<div align="center">
    <img src="https://github.com/h4fide/atv18/blob/main/assets/icon.png" alt="ATV18 Logo" width="200">
</div>

---

## Features

- Simulates ATV18 VFD logic and speed selection
- User-friendly Android interface
- Supports multiple preset speeds
- Open source and easy to extend

---

## Preset Speeds

- **LSP**: Low speed (petite vitesse)
- **HSP**: High speed (grande vitesse)
- **SP3**: 3rd preset speed
- **SP4**: 4th preset speed

---

## Logical Inputs (Entrées logiques)

- **LI1**: Forward direction (Sens de marche direct)
- **LI2**: Reverse direction (Sens de marche inverse)
  - *Priority to the first closed input*
- **LI3 & LI4**: Preset speeds selection
  - `LI3 = 0` & `LI4 = 0` → **LSP** + analog setpoint
  - `LI3 = 1` & `LI4 = 0` → **SP3**
  - `LI3 = 0` & `LI4 = 1` → **SP4**
  - `LI3 = 1` & `LI4 = 1` → **HSP**

---

## Getting Started

1. Clone this repository
2. Open in Android Studio or your preferred IDE
3. Build and run on an Android device or emulator

---

## License

This project is licensed under the MIT License.