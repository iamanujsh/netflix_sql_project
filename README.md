# Netflix Movies and TV Shows Data Analysis

This project focuses on analyzing Netflix's dataset to uncover key insights using SQL. The dataset contains detailed information about movies and TV shows, including their type, release year, duration, country, and more.

---

## Dataset Schema

```sql
CREATE DATABASE Netflix;

USE Netflix;

CREATE TABLE netflix (
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

-- Netflix Database Analysis

-- 1. Create Database and Use it
CREATE DATABASE Netflix;

USE Netflix;

-- 2. Select All Data
SELECT * FROM netflix;

-- 1. Count of TV Shows vs. Movies
SELECT type,
       COUNT(type) AS [Total Count]
FROM netflix
GROUP BY type;

-- 2. Find the Most Common Rating for Movies and TV Shows
WITH countRating AS (
    SELECT type,
           rating,
           COUNT(rating) AS [total_rating]
    FROM netflix
    GROUP BY type, rating
), 
rankRating AS (
    SELECT type,
           rating,
           total_rating,
           RANK() OVER (PARTITION BY type ORDER BY total_rating DESC) AS [rank]
    FROM countRating
)
SELECT type, rating
FROM rankRating
WHERE [rank] = 1;

-- 3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * 
FROM netflix
WHERE type = 'Movie' 
  AND release_year = 2020;

-- 4. Find the Top 5 Countries with the Most Content
SELECT TOP 5
    TRIM(value) AS country,
    COUNT(*) AS [total_content]
FROM netflix
CROSS APPLY STRING_SPLIT(country, ',')
GROUP BY TRIM(value)
ORDER BY [total_content] DESC;

-- 5. Identify the Longest Movie
WITH GetValue AS (
    SELECT CAST(value AS INT) AS [Duration], 
           title
    FROM netflix 
    CROSS APPLY STRING_SPLIT(duration, ' ')
    WHERE type = 'Movie' 
      AND value NOT LIKE 'min'
), 
RankMovieBasedOnDuration AS (
    SELECT title,
           Duration,
           ROW_NUMBER() OVER (ORDER BY Duration DESC) AS [Indexs]
    FROM GetValue
)
SELECT TOP 1 title, Duration 
FROM RankMovieBasedOnDuration 
ORDER BY Duration DESC;

-- 6. Find Content Added in the Last 5 Years
SELECT * 
FROM netflix
WHERE TRY_CAST(date_added AS DATE) >= CAST(DATEADD(YEAR, -5, GETDATE()) AS DATE);

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT * 
FROM netflix 
WHERE director LIKE ('Rajiv Chilaka');

-- 8. List All TV Shows with More Than 5 Seasons
SELECT * 
FROM netflix
WHERE type = 'TV Show' 
  AND duration > '5 Seasons';

-- 9. Count the Number of Content Items in Each Genre
WITH FindGenre AS (
    SELECT *, 
           TRIM(value) AS [Genre] 
    FROM netflix 
    CROSS APPLY STRING_SPLIT(listed_in, ',')
)
SELECT Genre, COUNT(Genre) AS [total_content]
FROM FindGenre
GROUP BY Genre;

-- 10. Find the Top 5 Years with the Highest Average Content Released by India
WITH CountRelease AS (
    SELECT country, 
           release_year, 
           COUNT(show_id) AS [total_release]
    FROM netflix 
    WHERE country = 'India'
    GROUP BY release_year, country
)
SELECT TOP 5 release_year, 
             AVG(total_release) AS [avg_release]
FROM CountRelease 
GROUP BY release_year
ORDER BY [avg_release] DESC;

-- 11. List All Movies That Are Documentaries
WITH FilterGenre AS (
    SELECT *, 
           TRIM(value) AS [Genre]
    FROM netflix
    CROSS APPLY STRING_SPLIT(listed_in, ',')
)
SELECT title, Genre
FROM FilterGenre 
WHERE type = 'Movie' 
  AND Genre = 'Documentaries';

-- 12. Find All Content Without a Director
SELECT * 
FROM netflix 
WHERE director IS NULL;

-- 13. Find How Many Movies Actor Salman Khan Appeared in Last 10 Years
SELECT * 
FROM netflix
WHERE type LIKE ('Movie') 
  AND release_year >= YEAR(CAST(DATEADD(YEAR, -10, GETDATE()) AS DATE))
  AND casts LIKE ('%Salman Khan%');

-- 14. Find the Top 10 Actors Who Have Appeared in the Most Movies Produced in India
WITH FilterCasts AS (
    SELECT *, 
           TRIM(value) AS [ExtractCasts]
    FROM netflix 
    CROSS APPLY STRING_SPLIT(casts, ',')
    WHERE country = 'India' 
      AND type = 'Movie'
)
SELECT TOP 10 ExtractCasts, 
               COUNT(type) AS [total_movies]
FROM FilterCasts 
GROUP BY ExtractCasts
ORDER BY [total_movies] DESC;

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
WITH LabelCategory AS (
    SELECT *,
           CASE 
               WHEN description LIKE ('%kill%') OR description LIKE ('%violence%') THEN 'Bad'
               ELSE 'Good'
           END AS [Label]
    FROM netflix
)
SELECT label, 
       COUNT(*) AS [count]
FROM LabelCategory
GROUP BY label;

