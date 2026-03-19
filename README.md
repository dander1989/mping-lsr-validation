# mping-lsr-validation
Verifying mPING reports against LSR (Local Storm Reports) from the March 13-15, 2026 Storm System

### Overview
This project builds a spatial analysis pipeline to evaluate the reliability and temporal lead-time of crowdsourced weather reports from mPING against official NWS Local Storm Reports (LSRs) archived by the Storm Prediction Center. The study event is the North American storm complex of March 13-16, 2026, which produced widespread wind damage and tornado reports across the Midwest and Ohio Valley.

### Why This Matters
LSRs are the gold standard for surface weather verification, but they carry an inherent reporting delay. mPING captures near real-time crowdsourced observations, but those reports are unverified and spatially imprecise. Understanding how well mPING reports correspond to official damage points, and how much earlier they tend to arrive, has real implications for how emergency managers and forecasters weight crowdsourced data during active events.

### Data Sources

- SPC Local Storm Reports: SPC Archive - filtered for wind and tornado reports, March 13-15, 2026
- mPING: mPING API - accessed under a non-commercial research license. Raw data is not redistributed in this repository per license terms.
- Administrative Boundaries: US Census TIGER/Line county shapefiles

### Methodology
The core analysis performs a spatiotemporal join between LSR points and mPING reports, matching pairs within a 10km radius and a +/- 30 minute time window. From matched pairs the pipeline calculates temporal offset (how much earlier or later mPING arrived relative to the official report) and distance decay between the crowdsourced report location and the official damage point.

### Repository Structure
```
├── data/
│   ├── raw/          # not committed, see license note above
│   └── processed/    # derived outputs and summary tables
├── notebooks/
│   ├── 01_data_recon.ipynb
│   ├── 02_cleaning.ipynb
│   ├── 03_spatial_analysis.ipynb
│   └── 04_visualization.ipynb
├── outputs/
│   └── maps/
├── requirements.txt
└── README.md
```

### Status
In progress. Data acquisition phase. API access pending.

### License Note
mPING data is used under a non-commercial research license issued by the University of Oklahoma. Raw mPING data is not included in this repository and may not be redistributed. See mPING Terms of Use for details.
