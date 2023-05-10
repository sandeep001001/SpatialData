SELECT ST_Distance(
    (SELECT location FROM tldd WHERE name = 'Tulsa'),
    (SELECT location FROM tldd WHERE name = 'Lawton')
) as distance;  -- replace 'Tulsa' and 'Lawton' with the names of the towns or cities you're interested in
