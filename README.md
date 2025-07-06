# ATV18 Simulator

**Version:** 1.0.0-alpha  
**Status:** Alpha Release (Early Testing)

**ATV18 Simulator** for Variable Frequency Drive (VFD) is an Android application designed to simulate the logic and speed selection of the ATV18 VFD. This app is intended for educational and testing purposes, allowing users to interact with a simulated VFD environment.

<div align="center">
    <img src="https://github.com/h4fide/atv18/blob/main/assets/icon.png" alt="ATV18 Logo" width="200">
</div>
<div align="center">
<h3><a href="https://github.com/h4fide/atv18/releases/tag/v1.0.0-alpha">Download APK</a> </h3>
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

## See the Real ATV18 VFD

To better understand how the simulator matches the real device, you can view images and documentation of the actual ATV18 Variable Frequency Drive:

- [ATV18 Product Page (Schneider Electric)](https://www.se.com/za/en/product/ATV18U41N4/altivar18-41kva-380-460v/)
<div align="center">
    <img src="https://github.com/user-attachments/assets/68a4b1f4-3ceb-4fdc-902a-00a959b35785" alt="ATV18 Image" width="400">
</div>

## Read the Official Manual

For detailed technical information, wiring diagrams, and parameter descriptions, refer to the official ATV18 manual:

- [ATV18 User Manual (PDF)](https://download.schneider-electric.com/files?p_enDocType=User+guide&p_File_Name=1624542.pdf&p_Doc_Ref=1624542)
- You can also open the PDF directly in your browser or preferred PDF reader for reference while using the simulator.


## How to Contribute
Contributions and feedback are welcome! Please report bugs or feature requests via the Issues tab or contact me directly.

---

## License

This project is licensed under the MIT License.