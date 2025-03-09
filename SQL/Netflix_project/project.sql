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

SELECT * FROM netflix;

-- 1. Count the number of Movies vs TV Shows
SELECT 
    type, COUNT(*)
FROM netflix
GROUP BY type;

-- 2. Find the highest rating for movies and TV shows
WITH count_table AS (
    SELECT 
        DISTINCT type, rating, COUNT(rating), 
        ROW_NUMBER() OVER(PARTITION BY type ORDER BY COUNT(rating) DESC) AS rate_count
    FROM netflix
    GROUP BY type, rating
    ORDER BY type, COUNT(rating) DESC
)
SELECT *
FROM count_table 
WHERE rate_count <= 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT *
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
    UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
    COUNT(*)
FROM netflix
GROUP BY new_country
ORDER BY COUNT(*) DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT *
FROM netflix
WHERE 
    type = 'Movie' 
    AND duration = (SELECT MAX(duration) FROM netflix)
ORDER BY duration DESC;

-- 6. Find content added in the last 5 years
WITH year_table AS (
    SELECT 
        release_year, COUNT(release_year)
    FROM netflix
    GROUP BY release_year
    ORDER BY release_year DESC
)
SELECT *, ROW_NUMBER() OVER(ORDER BY release_year DESC)
FROM year_table
WHERE release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 5;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'  
AND SPLIT_PART(duration, ' ', 1)::NUMERIC > 5;

-- 9. Count the number of content items in each genre
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, 
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY genre;

-- 10. Find each year and the average number of content releases in India on Netflix
SELECT 
    COUNT(*) AS Movies, 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD YYYY')) AS Year, 
    ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM netflix WHERE country = 'India') * 100::NUMERIC) AS avg
FROM netflix
WHERE country = 'India'
GROUP BY Year
ORDER BY Year DESC;

-- 11. List all movies that are documentaries
SELECT *
FROM netflix
WHERE listed_in IN (
    SELECT UNNEST(STRING_TO_ARRAY(listed_in, ','))
    FROM netflix
    WHERE listed_in = 'Documentaries' AND type = 'Movie'
);

-- 12. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in the last 10 years
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor, 
    COUNT(*) AS no_of_movies
FROM netflix 
WHERE type = 'Movie' AND country = 'India'
GROUP BY actor
ORDER BY no_of_movies DESC
LIMIT 10;

-- 15. Categorize content based on keywords 'kill' and 'violence' in description and lebel them as bad rest as good
WITH cat_table AS (
    SELECT *,
        CASE
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
)
SELECT category, COUNT(*)
FROM cat_table
GROUP BY category;
