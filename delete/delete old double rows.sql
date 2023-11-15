--Таблица T содержит дубли в поле n:
SELECT n
FROM T;

--Написать DML запрос, который очистит таблицу от старых дублей
--первый вариант
DELETE D
FROM
(SELECT n, ROW_NUMBER() OVER (ORDER BY dt) AS RowNum FROM t) D
    JOIN
    (SELECT n, ROW_NUMBER() OVER (ORDER BY dt) AS RowNum FROM t) E
        ON D.n = E.n
           AND D.RowNum < E.RowNum
           
--второй прогрессивный вариант удаления устаревших дублей
DECLARE @t TABLE
(
    n INT,
    dt DATE
);
INSERT INTO @t
VALUES
(1, '2019-07-08'),
(1, '2019-07-09'),
(2, '2019-07-08'),
(2, '2019-07-10'),
(3, '2019-07-10'),
(3, '2019-07-10');

SELECT *
FROM @t;

WITH CTE
AS (SELECT N = ROW_NUMBER() OVER (PARTITION BY n ORDER BY dt DESC),
           dt
    FROM @t)
DELETE CTE
WHERE N > 1;

SELECT *
FROM @t;