# Autonomous Astrobiology Multi-Well Microbial Imaging
## Optical Turbidity, In-Situ Well Tracking, and OD600 Cross-Modal Calibration

This repository contains the complete image processing and biophysical analysis pipeline for tracking microbial growth in a multi-well optical cassette. The approach measures transmitted light through liquid cultures, applies adaptive kinematic tracking with OpenCV to compensate for cassette movement, isolates liquid cores via a 90% Region of Interest (ROI), and calibrates in-situ camera attenuance to laboratory spectrophotometer optical density ($\text{OD}_{600}$).

---

## 1. Experimental Overview

- **Platform:** 4-Well Optical Growth Cassette with Trans-Illumination Backlight Array.
- **Conditions Investigated:**
  - **Control ($W_0$):** Sterile Growth Medium (Row 1 Well 1)
  - **Bacteria 1 ($W_1$):** *Shewanella* sp. (Row 1 Well 2)
  - **Bacteria 2 ($W_3$):** *Ustilago* sp. (Row 2 Well 2)
- **Time-Series Cadence:** 288 continuous image frames sampled at $\Delta t \approx 30.6\text{ min}$ over $146.3\text{ hours}$ (analysis truncated to $52.0\text{ hours}$ to align with the spectrophotometer sampling window).
- **Spectrophotometer Reference:** Optical density measured at $\lambda = 630\text{ nm}$ at discrete timepoints from $0$ to $51.5\text{ hours}$.

---

## 2. Methodological Approach

### Step 1: Microplate Motion Registration & Well Tracking
Over the 52-hour incubation, slight changes in plate position and rotation can occur due to thermal variations and mechanical settling. 
- Two stable physical landmarks are tracked frame-by-frame using Normalized Cross-Correlation (`cv2.matchTemplate`): the $W_0$ well rim and the central intersection rib.
- Kinematic transformation parameters (translation $\Delta x, \Delta y$, rotation $\Delta \theta$, and scale $s$) are computed.
- Each well ellipse boundary is dynamically updated across all frames using an adaptive affine transformation.

### Step 2: Defining the 90% Region of Interest (ROI)
The outer edges of microplate wells suffer from optical artifacts, including wall reflections, shadows, and liquid meniscus curvature.
- To eliminate these artifacts, measurements are restricted to an inner circular aperture covering a **$0.90$ radius ratio ($0.90\,R$)** of the detected physical well boundary.
- Only light passing directly through the liquid culture core is sampled.

### Step 3: Measuring Transmitted Light Intensity
Under trans-illumination (backlight), clear media transmits light freely (high brightness). As microbial cells multiply, they absorb and scatter incoming photons, reducing transmitted intensity ($I$).

### Step 4: Baseline Brightness Shift ($\alpha$)
At $t = 0$, raw brightness can differ slightly between wells due to minor illumination geometry differences. All wells are aligned to the exact initial baseline of the Control ($W_0$) using a shift factor $\alpha$:
$$\alpha = \frac{I_{\text{Control}}(0)}{I(0)}, \qquad I_{\text{adj}}(t) = I(t) \cdot \alpha$$

### Step 5: Live Control Blank Normalization ($I'$)
To cancel lamp output fluctuations and thermal sensor drift over the 52 hours, each adjusted sample intensity is divided by the live Control ($W_0$) at that exact timepoint:
$$I'(t) = \frac{I_{\text{adj}}(t)}{I_{\text{Control}}(t)}$$
- The Control blank remains identically at $1.0$.
- Samples start at $1.0$ at $t = 0$. As turbidity increases, normalized intensity drops below $1.0$.

### Step 6: Cross-Modal Calibration to Spectrophotometer OD600
Spectrophotometer $\text{OD}_{600}$ measures light extinction ($-\log_{10} T$), increasing with cell density, whereas image brightness decreases with density. To unify both modalities:
1. **Convert Transmission to Attenuance:**
   $$\Delta \text{OD}_{\mathrm{img}}(t) = -\log_{10}(I'(t))$$
2. **Linear Calibration Transfer Function:**
   $$\text{OD600}_{\mathrm{cal}}(t) = m \cdot \Delta \text{OD}_{\mathrm{img}}(t) + c$$
   - ***Shewanella*:** $\text{OD600} = 6.7402 \cdot \Delta \text{OD}_{\mathrm{img}} + 0.2372 \quad (R^2 = 0.965)$
   - ***Ustilago*:** $\text{OD600} = 14.3959 \cdot \Delta \text{OD}_{\mathrm{img}} + 0.2289 \quad (R^2 = 0.984)$

---

## 3. Publication Figures Generated

The pipeline generates the five core figures used in the report:

| Figure | Description | Styling & Colors |
| :--- | :--- | :--- |
| **Figure 1** | **Normalized Mean Intensity** | Control ($1.0$ baseline, Slate Grey `#64748b`), *Shewanella* (Royal Purple `#7c3aed`), *Ustilago* (Emerald Green `#059669`) with $\pm 1\,\sigma$ shaded envelope. |
| **Figure 2** | **Spectrophotometer Growth Curves** | Spectrophotometer $\text{OD}_{600}$ discrete readings connected by linear interpolation lines with $\pm 1\,\sigma$ inter-well error bands. |
| **Figure 3** | **Cross-Modal Growth Comparison** | Spectrophotometer (Solid + Markers) vs Calibrated Image Analysis (Dashed + Error bars + Shaded envelope):<br>• *Shewanella* Solid: `#7c3aed`, Dotted: `#6555f7`<br>• *Ustilago* Solid: `#059669`, Dotted: `#17bda7` |
| **Figure 4** | **Well Timelapse Crops** | $3 \times 4$ grid of $144 \times 144\text{ px}$ well crops at hours 0, 13, 26, 52 with condition-colored square borders. |
| **Figure 5** | **Well Tracking & 90% ROI Geometry** | Same $3 \times 4$ grid showing outer green tracked boundary and inner condition-colored $0.90\,R$ circular aperture. |

---

## 4. Folder Contents

```
Github/
├── document_image_processing_and_plots.ipynb  # Self-contained notebook (image processing & all 5 figures)
├── requirements.txt                          # Dependencies list for pip install
├── LICENSE                                   # MIT License
├── README.md                                 # Methodological overview and documentation
└── Dataset/
    ├── output_15fps.mp4                      # Full time-lapse tracking video at 15 fps (real-time labels & 90% ROI)
    ├── output_30fps.mp4                      # Full time-lapse tracking video at 30 fps
    ├── Bacteria/                             # Raw camera milestone frames (Hours 0, 13, 26, 52)
    │   ├── image_2026-09-29_14_55_21.jpg     # Hour 0  (0.0h baseline frame)
    │   ├── image_2026-09-30_04_10_35.jpg     # Hour 13 (13.3h early growth frame)
    │   ├── image_2026-09-30_16_55_13.jpg     # Hour 26 (26.0h mid-exponential frame)
    │   └── image_2026-10-01_18_55_06.jpg     # Hour 52 (52.0h stationary phase frame)
    ├── Bacteria_shift/                       # Shift-compensated & annotated frames with 90% ROI & live metrics
    │   ├── image_2026-09-29_14_55_21.jpg     # Hour 0  annotated (outer rim + inner ROI + metrics)
    │   ├── image_2026-09-30_04_10_35.jpg     # Hour 13 annotated
    │   ├── image_2026-09-30_16_55_13.jpg     # Hour 26 annotated
    │   └── image_2026-10-01_18_55_06.jpg     # Hour 52 annotated
    └── Bacteria_Marked/                      # Frame 0 landmark reference frame
```

> **Note on Datasets:** To maintain a lightweight repository, only the 4 milestone timepoint images (Hours 0, 13, 26, 52) are included in both raw form (`Bacteria/`) and tracking-annotated form (`Bacteria_shift/`) alongside the full time-lapse tracking videos (`output_15fps.mp4`, `output_30fps.mp4`). The full 288-frame metrics dataset is recorded in `dataset_image_turbidity_metrics.csv`.

---

## 5. Quickstart

To run the full pipeline and regenerate all figures:

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Launch Jupyter
jupyter notebook document_image_processing_and_plots.ipynb
```

Running all cells will:
1. Detect initial reference well coordinates.
2. Track microplate kinematics across time-lapse images.
3. Compute 90% aperture intensities and execute baseline drift normalization.
4. Render and save Figures 1 to 5 into `updates/figures/`.
