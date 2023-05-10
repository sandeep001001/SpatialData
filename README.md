# GIS Analysis with PostgreSQL

This project involves analyzing geographic data from the US Census Bureau's 2022 places dataset for the state of Oklahoma. The tasks include:

1. Retrieving locations of specific features
2. Calculating distance between points
3. Calculating areas of interest
4. Analyzing and optimizing queries

## Data Preparation

The dataset is available for download [here](https://www2.census.gov/geo/tiger/TIGER2022/PLACE/tl_2022_40_place.zip).

Before using the data, we need to add a new `location` column to the `tldd` table and populate it with point data for each city or town:

'''sql
ALTER TABLE tldd ADD COLUMN location GEOMETRY(Point, 4326);
UPDATE tldd SET location = ST_SetSRID(ST_MakePoint(intptlon::float, intptlat::float), 4326);

Tasks
1. Retrieve Locations of Specific Features

Assuming the 'features' are the towns or cities, we can retrieve their locations as follows:

sql

SELECT name, ST_AsText(location) 
FROM tldd 
WHERE name = 'Tulsa';  -- replace 'Tulsa' with the name of the feature we're interested in

2. Calculate Distance Between Points

We can calculate the distance between the points representing two towns or cities:

sql

SELECT ST_Distance(
    (SELECT location FROM tldd WHERE name = 'Tulsa'),
    (SELECT location FROM tldd WHERE name = 'Lawton')
) as distance;  -- replace 'Tulsa' and 'Lawton' with the names of the towns or cities of interest

3. Calculate Areas of Interest

We can find all towns or cities within a certain distance of a given town or city:

sql

SELECT name 
FROM tldd 
WHERE ST_DWithin(
    location,
    (SELECT location FROM tldd WHERE name = 'Tulsa'),  -- replace 'Tulsa' with the name of the town or city we're interested in
    0.2  -- replace 0.2 with the distance we're interested in
);

4. Analyze and Optimize Queries

We can use the EXPLAIN command to analyze the performance of our queries:

sql

EXPLAIN SELECT name FROM tldd WHERE ST_DWithin(location, ST_MakePoint(-95.9, 36.1)::geography, 20000);

To speed up our queries, we can add a spatial index to our location column:

sql

CREATE INDEX tldd_gix ON tldd USING GIST (location);

We can also sort our results and limit the number of rows returned:

sql

SELECT name, aland
FROM tldd
ORDER BY aland DESC
LIMIT 5;

Finally, for N-Optimization, we can remember the last item of the previous page and use multiple fields for ordering:

sql

SELECT name, aland
FROM tldd
WHERE aland <= <previous_aland> AND gid < <previous_gid>
ORDER BY aland DESC, gid DESC
LIMIT 5;
