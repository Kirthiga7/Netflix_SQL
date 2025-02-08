DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(10),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(220),
	casts VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year INT,
	rating	VARCHAR(10),
	duration VARCHAR(20),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

SELECT * FROM netflix;

--1. Count the Number of Movies and TV Shows
SELECT type,COUNT(*) AS total_shows
FROM netflix
GROUP BY type;

--2. Find the Most Common Rating for Movies and TV Shows
SELECT type,rating
FROM(
SELECT type,rating,COUNT(rating),
       RANK() OVER(PARTITION BY type ORDER BY COUNT(rating) DESC) as ranking
FROM netflix
GROUP BY 1,2
)AS rank_table
WHERE ranking=1;

--Top rating
SELECT rating,count(rating)
FROM netflix
GROUP BY 1
ORDER BY 2 desc LIMIT 1;

--3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM netflix
WHERE type='Movie' 
      AND 
	  release_year=2020;

--4. Find the top 5 countries with the most content on Netflix
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(country,','))) as new_country,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;
/*
SELECT 
     STRING_TO_ARRAY(country,',') as new_country 
FROM netflix;
STRING_TO_ARRAY(column,'delimiter') */
SELECT DURATION FROM NETFLIX
WHERE type='Movie'
order by 1 desc;

--5. Identify the longest movie
SELECT title, SUBSTRING(duration,1,POSITION ('m'IN duration)-1)::INT AS duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY duration DESC;

--6. Find content added in the last 5 years
SELECT * FROM netflix
where TO_DATE(date_added,'Month DD,YYYY') >=current_date - interval '5 years';
/*
select current_date - interval '5';
SELECT TO_DATE(date_added,'Month DD,YYYY') FROM netflix;
date_added is in format September 25,2021
*/
--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT title FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

--8. List all TV shows with more than 5 seasons
SELECT title
FROM netflix
WHERE type='TV Show' AND
      SUBSTRING(duration,1,POSITION ('S'IN duration)-1)::INT >5 ;
--Another method
SELECT *
FROM netflix
WHERE type='TV Show' AND
      SPLIT_PART(duration,' ',1):: INT > 5 ;

--9. Count the number of content items in each genre
SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) as new_list,
	   COUNT(title) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
SELECT 
	  EXTRACT (YEAR FROM(TO_DATE(date_added,'Month DD,YYYY'))) AS year, 
	  COUNT(*) AS yearly_content,
	  ROUND(
      COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country='India')::numeric*100,
	  2) AS avg_content_per_year
FROM netflix
WHERE country='India'
GROUP BY 1
ORDER BY 1;

--11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%';

-- 12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years
SELECT * FROM netflix
WHERE casts LIKE '%Salman Khan%'
AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India
SELECT  TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) as cast_list,
       count(*) as appeared_count
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC LIMIT 10;

/* 15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category. */
WITH category_table
AS(
SELECT title,
	CASE
	   WHEN description LIKE ANY(ARRAY ['%kill%','%violence%'])  THEN 'Bad'
	   ELSE 'Good'
    END category
FROM netflix
)
SELECT category,
       COUNT(*) AS total_content
FROM category_table
GROUP BY 1;
       



