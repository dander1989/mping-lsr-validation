# mping-lsr-validation
Verifying mPING reports against LSR (Local Storm Reports) from the March 13-15, 2026 Storm System

### Overview
This project builds a PostGIS-based spatial analysis pipeline to identify clustering patterns and storm track progression in NWS Local Storm Reports (LSRs) during the major wind and tornado event of March 13-16, 2026. Report data is sourced from the Iowa Environmental Mesonet (IEM) LSR archive and loaded into a PostGIS database for spatial SQL analysis.

### Why This Matters
Understanding where storm damage concentrates spatially, and how that damage evolves over time, has real value for emergency managers, insurance assessors, and forecasters. This project explores whether LSR report density reflects genuine meteorological patterns or is influenced by population distribution and reporting bias.

### Data Sources

- NWS Local Storm Reports: Accessed via the IEM LSR API for March 13-15, 2026. Raw data is not committed to this repository.
- US Census TIGER/Line County Boundaries: For spatial aggregation and county-level analysis.

### Methodology
LSR point data is ingested into PostGIS using ogr2ogr. The analysis progresses through four stages expressed as numbered SQL scripts:

1. Database setup and geometry validation
2. Data cleaning and event type filtering
3. Spatial aggregation and county-level joins
4. Density-based clustering and storm track reconstruction

Results are visualized using a Python notebook with Folium and GeoPandas.

### Repository Structure
```
├── _archive/          # earlier exploratory work, preserved for reference
├── data/
│   ├── raw/          # not committed, see license note below
│   └── processed/    # derived outputs and summary tables
├── sql/              # numbered analysis scripts
├── notebooks/        # visualization only
├── outputs/
│   └── maps/
├── docs/
│   └── data_notes.md
├── requirements.txt
└── README.md
```

### Status
In progress. Repo restructured for PostGIS spatial SQL pipeline. Data ingestion phase starting.

### Stretch Goal
If access to the mPING crowdsourced weather report API is approved, a validation component comparing mPING reports against LSRs will be added to the pipeline.

### Data Notes
Raw LSR data is not redistributed in this repository. See docs/data_notes.md for schema notes, known data quality issues, and event type filtering decisions.
