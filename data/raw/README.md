# Data Ingestion

Raw data is not committed to this repository per the IEM terms of use. To reproduce this project, download the LSR CSV from the IEM archive and load it using the following `ogr2ogr` command.

## Download
Request the CSV from the IEM LSR API:
```
https://mesonet.agron.iastate.edu/cgi-bin/request/gis/lsr.py?wfo=ALL&sts=2026-03-13T00:00Z&ets=2026-03-16T00:00Z&fmt=csv
```

## Load into PostGIS
```
ogr2ogr -append -update -f PostgreSQL PG:"host=<host> port=<port> user=<username> password=<password> dbname=storm_analysis" "<path/to/csv>" -nln lsr_analysis.staging_lsr -lco GEOMETRY_NAME=GEOM -oo X_POSSIBLE_NAMES=LON -oo Y_POSSIBLE_NAMES=LAT -a_srs EPSG:4326
```

## Notes
- Default port for this project's Docker container is 25432
- Ensure the `lsr_analysis` schema and `staging_lsr` table exist before running
- See `sql/01_setup.sql` to create the required schema and table