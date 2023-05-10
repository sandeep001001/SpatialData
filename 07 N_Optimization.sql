SELECT gid, name, aland
FROM (
  SELECT gid, name, aland, lag(aland) OVER (ORDER BY aland DESC) as prev_aland
  FROM tldd
) s
WHERE aland <= prev_aland
ORDER BY aland DESC, gid ASC
LIMIT 5;
