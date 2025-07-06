# ATV18 Simulator

**Version:** 1.0.0-alpha  
**Status:** Alpha Release (Early Testing)

**ATV18 Simulator** for Variable Frequency Drive (VFD) is an Android application designed to simulate the logic and speed selection of the ATV18 VFD. This app is intended for educational and testing purposes, allowing users to interact with a simulated VFD environment.

<div align="center">
    <img src="https://github.com/h4fide/atv18/blob/main/assets/icon.png" alt="ATV18 Logo" width="200">
</div>
<div align="center">
<h3><a href="https://github.com/h4fide/atv18/releases">Download APK</a> </h3>
</div>

---

## Features (Alpha)


- Simple user interface
- Simulates ATV18 VFD logic and speed selection
- User-friendly Android interface
- Supports multiple preset speeds
- Open source and easy to extend
- Core functionality implemented, but still under heavy development

## Known Issues

- Limited features compared to planned final version
- Animation requires a higher frequency (Hz) to appear more realistic
- Some Parameters are not yet implemented

---

## Preset Speeds

- **LSP**: Low speed (petite vitesse)
- **HSP**: High speed (grande vitesse)
- **SP3**: 3rd preset speed
- **SP4**: 4th preset speed

---

## Logical Inputs on ATV18

- **LI1**: Forward direction (Sens de marche direct)
- **LI2**: Reverse direction (Sens de marche inverse)
  - *Priority to the first closed input*
- **LI3 & LI4**: Preset speeds selection
  - `LI3 = 0` & `LI4 = 0` → **LSP** + analog setpoint
  - `LI3 = 1` & `LI4 = 0` → **SP3**
  - `LI3 = 0` & `LI4 = 1` → **SP4**
  - `LI3 = 1` & `LI4 = 1` → **HSP**

---

## How to Contribute
Contributions and feedback are welcome! Please report bugs or feature requests via the Issues tab or contact me directly.

---

## License

This project is licensed under the MIT License.