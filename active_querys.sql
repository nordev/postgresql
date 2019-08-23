# Watch active querys
SELECT pid,
       query,
       now() - query_start                                                     as duration,
       row_number() OVER (PARTITION BY query ORDER BY now() - query_start ASC) AS youngest_query
FROM pg_stat_activity
WHERE usename = 'XXXX'

# Find repeated querys
WITH repeated_querys as (
    SELECT pid,
           query,
           now() - query_start                                                     as duration,
           row_number() OVER (PARTITION BY query ORDER BY now() - query_start ASC) AS youngest_query
    FROM pg_stat_activity
    WHERE query in (
        SELECT query
        FROM pg_stat_activity
        where usename = 'XXXX'
        group by 1
        having count(*) > 1
    )
)
SELECT pid, query, duration, youngest_query
FROM repeated_querys
where pid not in (
    SELECT pid
    FROM repeated_querys
    where youngest_query = 1
