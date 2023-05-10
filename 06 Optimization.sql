CREATE INDEX tldd_gix ON tldd USING GIST (location);

SELECT name, aland
FROM tldd
ORDER BY aland DESC, gid
LIMIT 5;
