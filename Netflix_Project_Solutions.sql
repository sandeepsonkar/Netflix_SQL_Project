-- Netflix Project

CREATE TABLE netflix (
	show_id VARCHAR(15),
	type VARCHAR(50),
	title VARCHAR(200),
	director VARCHAR(300),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(10),
	listed_in VARCHAR(90),
	description VARCHAR(250)
);

-- 15 Business Problems

-- 1. Count the number of Movies vs TV Shows
	SELECT  type, 
			COUNT(*) AS Total_Content
	FROM netflix
	GROUP BY type

--2. Find the most common rating for movies and TV shows
SELECT type,
	   rating 
FROM 
	(
	SELECT  type,
			rating,
			COUNT(*) AS in_number,
			RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS Rank_ji
	FROM netflix 
	GROUP BY 1,2
	) AS t1
	WHERE rank_ji = 1

--3. List all Movies released in a specific year (e.g, 2020)
	SELECT title, type, release_year
	FROM netflix
	WHERE   
		 type = 'Movie'
		 AND
		 release_year = 2020

--4. Find the top 5 counties with the most content on Netflix
	SELECT  TRIM(UNNEST(STRING_TO_ARRAY(country, ','))), 
			COUNT(show_id) AS Total_content
	FROM netflix
	GROUP BY  1
	ORDER BY 2 DESC 
	LIMIT 5

--5. Identify the longest Movie
	SELECT title, SUBSTRING(duration, 1, POSITION('m' IN duration)-2)::INT AS duration_in_minutes
	FROM Netflix
	WHERE TYPE = 'Movie' AND duration IS NOT NULL
	ORDER BY 2 DESC
	LIMIT 5

--6. Find the content added in the last 5 years:
	SELECT *
	FROM netflix
	WHERE TO_DATE(date_added, 'Month DD, YYYY') >= '2020-07-22'

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'
	SELECT *
	FROM netflix
	WHERE director ILIKE '%Rajiv Chilaka%'

--8. List all TV Shows with more than 5 seasons
	SELECT *
	FROM netflix
		 WHERE type = 'TV Show'
		 AND
		 SPLIT_PART(duration, ' ', 1):: NUMERIC > 5

--9. Count the number of content items in each genre:
	SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS Genre,
		   COUNT(show_id) AS Total_Count
	FROM netflix
	GROUP BY 1

--10. Find each year and the average number of content release in India on Netflix.
	-- Return Top 6 year with the highest avg content release
	SELECT 
		  EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY')) AS year,
		  COUNT(*) AS yearly_Content,
		  ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM netflix WHERE COUNTRY ILIKE '%India%')::NUMERIC *100, 2) AS Average_Content_Per_Year
		  
	FROM netflix
	WHERE 
		 country ILIKE '%India%'
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 5

--11. List all the movies that are documentaries	
	SELECT * FROM netflix
	WHERE type = 'Movie' AND listed_in ILIKE '%Documentaries%'

--12. Find all content without the director
	SELECT * FROM netflix
	WHERE 
		 director IS NULL

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years:
	SELECT * FROM netflix
	WHERE 
		 casts ILIKE '%Salman khan%' 
		 AND
		 TO_DATE(date_added, 'Month-DD-YYYY') > '2015-07-22'

	SELECT * FROM netflix
	WHERE 
		 casts ILIKE '%Salman khan%' 
		 AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

--14. Find the top 10 actor who have appeared in the highest numaber of movies produced in India
	SELECT TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS Actor,
		   COUNT(casts) AS frequency
	FROM netflix
	WHERE country ILIKE '%India%'
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 10

--15. Categorize the content based on the presence of the keywords 'Kill' and 'violence' in the
-- description field. Label content containing these keywords as 'Bad' or all other content as 'good'.
-- Count how many item fall into each category
	WITH new_table
	AS
	(
	SELECT 
	*,
		  CASE
		  WHEN 
		  	  description ILIKE '% kill %' OR
		  	  description ILIKE '% violence %' THEN 'Bad_Content'
			  ELSE 'Good_Content'
		  END category
	FROM netflix
	)
	SELECT category,
		   COUNT(*) AS total_Content
	FROM new_table
	GROUP BY 1
			