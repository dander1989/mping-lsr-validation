PostgreSQL version 18.3

PostGIS version 3.6

ogr2ogr import into postgres (lsr csv)
```
ogr2ogr -append -update -f PostgreSQL PG:"host=localhost port=25432 user=**** password=***** dbname=storm_analysis" "C:\Users\DJ\Documents\projects\mping-lsr-validation\data\raw\lsr_202603130000_202603160000.csv" -nln lsr_analysis.staging_lsr -lco GEOMETRY_NAME=GEOM -oo X_POSSIBLE_NAMES=LON -oo Y_POSSIBLE_NAMES=LAT -a_srs EPSG:4326
```

ogr2ogr import into postgres (census shapefile)
```
ogr2ogr -f "PostgreSQL" PG:"dbname=storm_analysis host=localhost port=25432 user=docker password=docker" "C:\Users\DJ\Documents\gis\data\census\tl_2025_us_county\tl_2025_us_county.shp" -nln reference.counties -lco SCHEMA=reference -nlt PROMOTE_TO_MULTI -overwrite
```

## MAG Zero Values
721 records have MAG = 0, representing None values substituted by ogr2ogr during ingestion.
Zeros are concentrated in damage-type codes (O: 425, D: 130) where no instrument 
measurement exists. Also present in tornado/waterspout codes (T, C, W) as expected.
No zeros found in gust codes (G, N) where a zero would be analytically suspicious.
All zeros will be converted to NULL in the cleaning step.

## Known Bad Records
GIDs 617 and 794 are malformed records from marine zones (LMZ, LSZ) outside the 
study area. Excluded in cleaning step.

## Lowercase Type Code
SNOW SQUALL uses lowercase 'q' as its type code. All other codes are uppercase.
Corrected to 'Q' in cleaning step.

## For 02_cleaning.sql
- Exclude GIDs 617 and 794 (the two bad records)
- Convert MAG zeros to NULL for codes where zero means no measurement
- Fix the lowercase q for SNOW SQUALL to uppercase
- Convert VALID2 from TEXT to a proper TIMESTAMP
- Rename columns to clean lowercase names
- Build a properly typed geometry column
- Reproject to a suitable projected coordinate system for distance-based analysis
- Moved the ST_Transform of reference.counties into the cleaning phase. By storing geom_5070 as a persistent column, we eliminated the need for on-the-fly transformations during analysis, reducing query times from ~20 minutes to under 15 seconds.

## FOR 03_spatial_analysis
- Identified bottleneck where ST_Transform inside JOIN caused a hang-up. Resolved by pre-calculating geom_5070 on reference.counties table and indexing.
- Chose ST_Intersects over ST_Within for better handling of points on boundaries.
- Implemented ST_ConvexHull to limit processing to storm's footprint rather than entire CONUS.
- Implemented date_trunc on event_time column to aggregate reports by date.
- Implemented COALESCE for magnitude to ensure null values in the numeric field default to 0 and do not break the severity summation.