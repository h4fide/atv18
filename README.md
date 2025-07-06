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

## Features (Alpha) 🚀


- Simple user interface
- Simulates ATV18 VFD logic and speed selection
- User-friendly Android interface
- Supports multiple preset speeds
- Open source and easy to extend
- Core functionality implemented, but still under heavy development

## Known Issues ⚠️

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

### Read the Official Manual 

For detailed technical information, wiring diagrams, and parameter descriptions, refer to the official ATV18 manual:

- [ATV18 User Manual (PDF)](https://download.schneider-electric.com/files?p_enDocType=User+guide&p_File_Name=1624542.pdf&p_Doc_Ref=1624542)
- You can also open the PDF directly in your browser or preferred PDF reader for reference while using the simulator.

---
## Main Parameters 

> **⚠️ Note:** The following parameters are not yet implemented in the simulator, but are essential for understanding ATV18 VFD operation.

### Display Parameters (Read-Only)

| Parameter | Description | Behavior / Guidance |
|-----------|-------------|---------------------|
| **rdY**   | Variator Ready | Indicates drive readiness (no fault detected).<br>_Monitor for operational status._ |
| **FrH**   | Frequency Setpoint | Displays target motor frequency (Hz).<br>_Ensure it aligns with application speed requirements._ |
| **LCr**   | Motor Current | Shows real-time current draw (Amps).<br>_Monitor to avoid exceeding motor’s rated current._ |
| **rFr**   | Rotation Frequency | Displays actual motor speed (Hz).<br>_Compare with FrH to verify speed alignment._ |
| **ULn**   | Mains Voltage | Displays input voltage (Volts).<br>_Ensure stability (e.g., 400V ±10% for your motor)._ |
| **FLt**   | Last Fault | Shows recent fault code (e.g., "nErr" for no fault).<br>_Troubleshoot if errors persist._ |

---

### Adjustable Parameters (Configuration & Optimization)
### Motor-Specific Settings

| Parameter      | Description                          | Recommended Setting / Guidance |
|----------------|--------------------------------------|-------------------------------|
| **bFr**        | Base Frequency                       | 50Hz (preset voltage: 400V/50Hz for ATV18...N4 models). Match motor’s nameplate frequency (e.g., 50Hz or 60Hz). Adjust only when stopped. |
| **ItH**        | Motor Thermal Protection             | 1.0 × motor’s rated current (check nameplate). Example: For a 30A motor, set to 30A. Drive’s nominal current must support this. |
| **ACC / dEC**  | Acceleration / Deceleration Ramps    | ACC: 10–20s (gradual ramp-up); dEC: 10–20s (prevents abrupt stops). Adjust based on load inertia. |
| **LSP / HSP**  | Low / High Speed                     | LSP: 5–10Hz (prevents stalling); HSP: 50Hz (default, up to 60Hz if motor permits). |
| **FLG**        | Frequency Loop Gain                  | Start at 50%. Reduce for high-inertia loads; increase for low-inertia, fast-cycle applications. |
| **JPF**        | Critical Speed Suppression           | Set to resonance frequency ±1Hz (e.g., 25Hz → block 24–26Hz). Set to 0 if no resonance issues. |
| **Idc / tdc**  | DC Injection Braking                 | Idc: 0.8 × drive’s nominal current (e.g., 20A drive → 16A); tdc: 2–5s (adjust to prevent overheating). |
| **UFr**        | Low-Speed Torque Optimization        | 50–70% to enhance torque below 10Hz (e.g., conveyors, mixers). |
| **JOG**        | Jog Speed                            | 10–15Hz (for precise positioning during maintenance). |
| **Fdt**        | Frequency Threshold                  | 5Hz (triggers LO output when frequency drops below threshold). |

---

### Advanced Control Parameters

| Parameter      | Description                          | Recommended Setting / Guidance |
|----------------|--------------------------------------|-------------------------------|
| **rPG**        | PI Regulator Proportional Gain       | Start at 20%; increase for faster response. |
| **rIG**        | PI Regulator Integral Gain           | Start at 10%; adjust to minimize steady-state error. |
| **FbS**        | Feedback Coefficient                 | Set to 1.0 (default); adjust if using external feedback (e.g., encoder). |


---

## How to Contribute 
Contributions and feedback are welcome! Please report bugs or feature requests via the Issues tab or contact me directly.

---

## License 

This project is licensed under the MIT License.