# RPM Microgravity Growth Analysis

Image-based turbidity quantification pipeline for bacterial growth experiments conducted under simulated microgravity conditions using a **Random Positioning Machine (RPM)**.

This project detects wells from multi-well plate images and computes image-derived turbidity metrics over time.

---

## Overview

This repository provides a Jupyter Notebook workflow to analyze plate images from RPM antigravity experiments.

The pipeline performs:

1. Circular well detection using Hough Circle Transform  
2. Fallback detection if the expected number of wells is not found  
3. Inner region cropping to remove well wall artifacts  
4. Computation of turbidity-related image metrics  
5. Row-wise aggregation  
6. Time-series output generation  

The final data structure has shape:

Images × Rows × Measurements

---

## Biological Context

Increased bacterial growth leads to:

- Increased turbidity (cloudiness)  
- Reduced visibility of bottom texture  
- Increased blur  
- Reduced intensity variation  

The computed image metrics serve as non-invasive proxies for optical density.

---

## Repository Structure

```
rpm-microgravity-growth-analysis/
│
├── well_turbidity_analysis.ipynb   # Main Jupyter notebook (analysis pipeline)
├── Earth/                          # Images from Earth gravity experiment
├── Mars/                           # Images from Mars (simulated microgravity) experiment
└── README.md                       # Project documentation
```

### Folder Description

- **well_turbidity_analysis.ipynb**  
  Contains the full turbidity analysis pipeline:
  well detection, cropping, metric computation, and row-wise aggregation.

- **Earth/**  
  Contains plate images from the Earth gravity control experiment.

- **Mars/**  
  Contains plate images from the Mars / simulated microgravity experiment.

- **README.md**  
  Documentation describing the project, usage, configuration, and output interpretation.


---

## Requirements

Python 3.8+

Install dependencies:

pip install opencv-python numpy matplotlib

---

## How to Use

1. Place your plate images inside a folder (e.g., `Earth/`)  
2. Open `well_turbidity_analysis.ipynb`  
3. Modify the configuration section  
4. Run all cells  

---

## User Configuration

All adjustable parameters are grouped at the bottom of the notebook.

### Folder Configuration

```python
FOLDER_PATH = "Earth"
```

Path to the folder containing plate images.

---

### Plate Layout

```python
EXPECTED_WELLS = 12
NUM_ROWS = 3
```

- `EXPECTED_WELLS` → Total wells expected in each image  
- `NUM_ROWS` → Number of rows in plate layout  

The script assumes wells are ordered row-major  
(left to right, top to bottom).

---

### Crop Configuration

```python
SHRINK_FACTOR = 0.3
```

Controls how much of the detected radius is used for analysis.

- Smaller value → excludes well wall reflections  
- Larger value → includes more liquid region  

---

### Debug and Visualization

```python
DEBUG = False
VISUALIZE = True
```

- `DEBUG = True` → shows preprocessing steps (original, grayscale, blur)  
- `VISUALIZE = True` → overlays detected circles  

---

### Blur Parameters

```python
BLUR_KERNEL = (9,9)
BLUR_SIGMA = 2
```

Gaussian blur stabilizes circle detection.

- Larger values → smoother image  
- Too large → may weaken circle edges  

---

### Primary Hough Parameters

```python
HOUGH_DP = 1.2
HOUGH_MIN_DIST = 150
HOUGH_PARAM1 = 100
HOUGH_PARAM2 = 30
HOUGH_MIN_RADIUS = 80
HOUGH_MAX_RADIUS = 150
```

- Lower `HOUGH_PARAM2` → more circles detected  
- Higher `HOUGH_PARAM2` → stricter detection  
- Tight radius bounds reduce false positives  
- Increase `HOUGH_MIN_DIST` if duplicate circles appear  

---
### Fallback Detection

If detected wells ≠ expected wells, fallback detection runs with:

```python
FALLBACK_MIN_DIST = 300
FALLBACK_PARAM2 = 40
FALLBACK_MIN_RADIUS = 150
FALLBACK_MAX_RADIUS = 200
```

This improves robustness across varying lighting conditions.

---

## Output Interpretation

For each image and each well row, three measurements are computed:

Contrast (Intensity Variation)
- Pixel intensity standard deviation  
- Decreases with turbidity  

Sharpness (Clarity Score)
- Image sharpness (Laplacian variance)  
- Lower = more blur = more growth  

Mean Intensity/Brightness
- Mean pixel value  
- Lighting-dependent  

Example output shape:

(7, 3, 3)

Means:
- 7 images analyzed  
- 3 well rows  
- 3 measurements per row  

---

## Processing Workflow

### 1. Well Detection
- Convert image to grayscale  
- Apply Gaussian blur  
- Run Hough Circle Transform  
- If detected wells ≠ expected wells → run fallback detection  

### 2. Cropping
- Extract square region around each well  
- Apply circular mask inside that region for metric computation  

### 3. Metric Computation
- Extract circular region pixels  
- Compute contrast, sharpness, and mean intensity  

### 4. Row Averaging
- Wells grouped row-wise  
- Average metrics per row  

---

## Design Assumptions

- Plate layout is rectangular and ordered row-major  
- Lighting conditions are relatively stable  
- Wells are approximately circular  

---

## Intended Applications

- Simulated microgravity bacterial growth comparison  
- RPM vs control growth analysis  
- Image-based turbidity quantification  
- Time-series growth monitoring  

---

## Image Renaming (Optional Preprocessing)

Raw phone images can be renamed based on their EXIF timestamp using the provided PowerShell script:

```
scripts/rename_by_exif.ps1
```

This script:

- Reads EXIF capture timestamp
- Renames images to:
  `yyyyMMdd HHmmss.jpg`
- Preserves chronological ordering

### How to Use (Windows PowerShell)

1. Place images inside a folder named `Phone`
2. Run:

```powershell
.\scripts\rename_by_exif.ps1
```

A new folder with `_Renamed` suffix will be created containing timestamped images.

---

## License

This project is released under the MIT License.
You are free to use, modify, and distribute this software with attribution.

See the [LICENSE](LICENSE) file for details.

---


## Author

Saurav Mishra  
Indian Institute of Technology Kanpur  
2026  
