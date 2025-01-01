	
CREATE DATABASE Netflix

USE Netflix

select * from netflix

-- 1. Count of TV Show VS Movies

select type ,
	   count(type) [Total Count]
from netflix
group by type

-- 2. Find the most common rating for Movies And TV Shows

WITH countRating AS(
select	type  ,
		rating	,
		count(rating) [total_rating] 
	from netflix
group by type , rating
),  rankRating AS(
select type , rating , total_rating,
	rank() over(partition by type order by total_rating desc) [rank]
from countRating
)
select type , rating from rankRating
where rank = 1


-- 3. List all movies released in a specific year (e.g -> 2020)

select * from netflix
where type = 'Movie' AND release_year in (2020)

-- 4. Find top 5 country with the most content 

SELECT top 5
    TRIM(value) as country,
    COUNT(*) AS [total Content]
FROM netflix
CROSS APPLY STRING_SPLIT(country, ',')
GROUP BY TRIM(value)
ORDER BY [total Content] DESC

-- 5. Identify the longest movie

WITH GetValue AS (
select cast(value as int) [Duration], title
from netflix 
CROSS APPLY string_split(duration, ' ')
WHERE type like ('movie') AND value not like ('min')
), RankMovieBasedOnDuration AS(
	select title,
		Duration,
		ROW_NUMBER() over(order by Duration desc) [Indexs]
		from GetValue
)
select top 1 title, Duration 
from RankMovieBasedOnDuration 
order by Duration desc

-- 6. Find content added in the last 5 yeras

select *  from netflix
where TRY_CAST(date_added as date) >= CAST(DATEADD(year ,-5, GETDATE()) AS DATE)

-- 7. Find all movie / Tv shows by director 'Rajiv Chilaka'

select * from netflix 
where director like ('Rajiv Chilaka')

-- 8. List All Tv Shows with more than 5 season

select * from netflix
where type = 'tv show' AND duration > '5 Seasons'

-- 9. Count the number of content items in each genre

WITH FindGenre  AS(
select * , TRIM(value) [Genre] 
from netflix 
CROSS APPLY string_split(listed_in, ',')
)
select Genre, count(Genre) [total movie/tv shows]
from FindGenre
group by Genre

-- 10. Find each year and the average numbers of content release by India and return top 5 year with hightest avg content released

WITH CountRelease AS(
select country , release_year , count(show_id) [total_release]
from netflix 
where country = 'india'
group by release_year , country
) 
select top 5 release_year , 
avg(total_release) [avg_release]
from CountRelease 
group by release_year
order by [avg_release] desc

--11. List All the movies that are documentaries

WITH FilterGenre AS (
select * , TRIM(value) [Genre]
from netflix
CROSS APPLY string_split(listed_in , ',')
) 
select title , Genre
from FilterGenre 
where type = 'Movie' AND Genre = 'Documentaries'

-- 12. Find All Content Without Director

select * from netflix where director is null

-- 13. find how many movies actor Salman Kahn Appeared in last 10 years

select * 
from netflix
where type like ('movie') 
AND release_year >= YEAR(CAST(DATEADD(YEAR, -10 , GETDATE()) AS DATE))
AND casts like ('%Salman Khan%')

-- 14. Find the top 10 actors who have appeard in the highest numbers of movies produced in india

WITH FilterCasts AS (
select * , TRIM(value) [ExtractCasts]
from netflix 
CROSS APPLY string_split(casts , ',')
where country = 'india' AND type = 'movie'
) 
select top 10 ExtractCasts , count(type)
from FilterCasts 
group by ExtractCasts
order by count(type) desc

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

WITH LabelCategory AS(
select *,
CASE 
	WHEN description like ('%kill%') OR description like ('violence') THEN 'Bad'
	ELSE 'Good'
END [Label]
from netflix
)
select label , count(*)
from LabelCategory
group by Label



















































