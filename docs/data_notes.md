PostgreSQL version 18.3

PostGIS version 3.6

ogr2ogr import into postgres
```
ogr2ogr -append -update -f PostgreSQL PG:"host=localhost port=25432 user=**** password=***** dbname=storm_analysis" "C:\Users\DJ\Documents\projects\mping-lsr-validation\data\raw\lsr_202603130000_202603160000.csv" -nln lsr_analysis.staging_lsr -lco GEOMETRY_NAME=GEOM -oo X_POSSIBLE_NAMES=LON -oo Y_POSSIBLE_NAMES=LAT -a_srs EPSG:4326
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