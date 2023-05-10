# GIS Analysis with PostgreSQL

This project involves analyzing geographic data from the US Census Bureau's 2022 places dataset for the state of Oklahoma. The tasks include:

1. Retrieving locations of specific features
2. Calculating distance between points
3. Calculating areas of interest
4. Analyzing and optimizing queries

## Data Preparation

The dataset is available for download [here](https://www2.census.gov/geo/tiger/TIGER2022/PLACE/tl_2022_40_place.zip).

Before using the data, we need to add a new `location` column to the `tldd` table and populate it with point data for each city or town:
```
ALTER TABLE tldd ADD COLUMN location GEOMETRY(Point, 4326);
UPDATE tldd SET location = ST_SetSRID(ST_MakePoint(intptlon::float, intptlat::float), 4326);
```
Tasks
1. Retrieve Locations of Specific Features

Assuming the 'features' are the towns or cities, we can retrieve their locations as follows:

```
SELECT name, ST_AsText(location) 
FROM tldd 
WHERE name = 'Tulsa';  -- replace 'Tulsa' with the name of the feature we're interested in
```
2. Calculate Distance Between Points

We can calculate the distance between the points representing two towns or cities:

```
SELECT ST_Distance(
    (SELECT location FROM tldd WHERE name = 'Tulsa'),
    (SELECT location FROM tldd WHERE name = 'Lawton')
) as distance;  -- replace 'Tulsa' and 'Lawton' with the names of the towns or cities of interest
```
3. Calculate Areas of Interest

We can find all towns or cities within a certain distance of a given town or city:

```
SELECT name 
FROM tldd 
WHERE ST_DWithin(
    location,
    (SELECT location FROM tldd WHERE name = 'Tulsa'),  -- replace 'Tulsa' with the name of the town or city we're interested in
    0.2  -- replace 0.2 with the distance we're interested in
);
```
4. Analyze and Optimize Queries

We can use the EXPLAIN command to analyze the performance of our queries:

```
EXPLAIN SELECT name FROM tldd WHERE ST_DWithin(location, ST_MakePoint(-95.9, 36.1)::geography, 20000);
```
To speed up our queries, we can add a spatial index to our location column:

```
CREATE INDEX tldd_gix ON tldd USING GIST (location);
```
We can also sort our results and limit the number of rows returned:

```
SELECT name, aland
FROM tldd
ORDER BY aland DESC
LIMIT 5;
```
Finally, for N-Optimization, we can remember the last item of the previous page and use multiple fields for ordering:

```
SELECT name, aland
FROM tldd
WHERE aland <= <previous_aland> AND gid < <previous_gid>
ORDER BY aland DESC, gid DESC
LIMIT 5;
```
markdown
### 5. Sorting and Limit Executions

This involves sorting the results of the SQL queries in a specific order, and limiting the number of results that are returned. A common use case is when we have a large amount of data and only want to retrieve a subset of it. Here's an example:

```
SELECT name, aland 
FROM tldd
ORDER BY aland DESC 
LIMIT 5; 
```
In this example, we're retrieving the names and land area of the top 5 largest towns or cities (by land area). The ORDER BY aland DESC sorts the results in descending order by land area, and LIMIT 5 limits the results to the top 5.
6. Optimize the Queries to Speed Up Execution Time

Optimizing queries can greatly improve performance, especially when dealing with large datasets. Here are some techniques:

    Indexing: Creating an index on the location column can significantly speed up spatial queries:

```
    CREATE INDEX tldd_gix ON tldd USING GIST (location);
```
    
   Filtering: Only fetch the data you need. This might involve making good use of WHERE clauses to filter out unnecessary data, or avoiding the use of SELECT * in favor of selecting only the specific columns you need.

   Using JOINs: Depending on the specific query, using JOINs can often be more efficient than using subqueries.

7. N-Optimization of Queries

N-Optimization, or Top-N queries, return a specified number of ordered rows or rows which match a condition. They can be optimized in PostgreSQL by using LIMIT and OFFSET. However, for large offsets, this method can be inefficient because PostgreSQL must retrieve and discard all the rows from the offset to the limit. An optimized way is to remember the last item of the previous page. We can make use of PostgreSQL's ability to order by multiple fields:

```
SELECT name, aland 
FROM tldd 
WHERE aland <= <previous_aland> AND gid < <previous_gid> 
ORDER BY aland DESC, gid DESC 
LIMIT 5;
```
In this example, <previous_aland> and <previous_gid> would be the aland and gid values of the last row from the previous page of results. This query will then return the next 5 results.
