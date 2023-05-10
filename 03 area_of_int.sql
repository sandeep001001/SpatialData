SELECT name 
FROM tldd 
WHERE ST_DWithin(
    location,
    (SELECT location FROM tldd WHERE name = 'Tulsa'),  -- replace 'Tulsa' with the name of the town or city you're interested in
    0.5  -- replace 0.1 with the distance you're interested in
);
