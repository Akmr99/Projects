![Netflix](https://github.com/Akmr99/Netflix_SQL_Project/blob/main/Netflix_2015_logo.svg.png?raw=true)

# Netflix Data Analysis SQL Queries

This repository contains SQL queries for analyzing Netflix content data. The queries cover various business problems and insights, including movie and TV show analysis, content categorization, and trends over time.

## Table of Contents
- [Schema Definition](#schema-definition)
- [Business Problems & Solutions](#business-problems--solutions)
  - [Count Movies vs TV Shows](#count-movies-vs-tv-shows)
  - [Find Highest Rating for Movies and TV Shows](#find-highest-rating-for-movies-and-tv-shows)
  - [List Movies Released in a Specific Year](#list-movies-released-in-a-specific-year)
  - [Top 5 Countries with Most Content](#top-5-countries-with-most-content)
  - [Identify the Longest Movie](#identify-the-longest-movie)
  - [Find Content Added in Last 5 Years](#find-content-added-in-last-5-years)
  - [Find Movies/TV Shows by Specific Director](#find-moviestv-shows-by-specific-director)
  - [List TV Shows with More than 5 Seasons](#list-tv-shows-with-more-than-5-seasons)
  - [Count Content Items in Each Genre](#count-content-items-in-each-genre)
  - [Average Content Release Per Year in India](#average-content-release-per-year-in-india)
  - [List All Movies that are Documentaries](#list-all-movies-that-are-documentaries)
  - [Find Content Without a Director](#find-content-without-a-director)
  - [Find Movies with Actor 'Salman Khan' in Last 10 Years](#find-movies-with-actor-salman-khan-in-last-10-years)
  - [Top 10 Actors with Highest Movies in India](#top-10-actors-with-highest-movies-in-india)
  - [Categorize Content Based on Keywords](#categorize-content-based-on-keywords)

## Schema Definition
```sql

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
```

## Business Problems & Solutions

### Count Movies vs TV Shows
```sql
SELECT type, COUNT(*)
FROM netflix
GROUP BY type;
```

### Find Highest Rating for Movies and TV Shows
```sql
WITH count_table AS (
    SELECT DISTINCT type, rating, COUNT(rating), 
           ROW_NUMBER() OVER(PARTITION BY type ORDER BY COUNT(rating) DESC) AS rate_count
    FROM netflix
    GROUP BY type, rating
)
SELECT *
FROM count_table 
WHERE rate_count <= 1;
```

### List Movies Released in a Specific Year
```sql
SELECT *
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;
```

### Top 5 Countries with Most Content
```sql
SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country, COUNT(*)
FROM netflix
GROUP BY new_country
ORDER BY COUNT(*) DESC
LIMIT 5;
```

### Identify the Longest Movie
```sql
SELECT *
FROM netflix
WHERE type = 'Movie' 
AND duration = (SELECT MAX(duration) FROM netflix)
ORDER BY duration DESC;
```

### Find Content Added in Last 5 Years
```sql
WITH year_table AS (
    SELECT release_year, COUNT(release_year)
    FROM netflix
    GROUP BY release_year
    ORDER BY release_year DESC
)
SELECT *, ROW_NUMBER() OVER(ORDER BY release_year DESC)
FROM year_table
WHERE release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 5;
```

### Find Movies/TV Shows by Specific Director
```sql
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';
```

### List TV Shows with More than 5 Seasons
```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'  
AND SPLIT_PART(duration, ' ', 1)::NUMERIC > 5;
```

### Count Content Items in Each Genre
```sql
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, COUNT(show_id) AS total_content
FROM netflix
GROUP BY genre;
```

### Average Content Release Per Year in India
```sql
SELECT COUNT(*) AS Movies, 
       EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD YYYY')) AS Year, 
       ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM netflix WHERE country = 'India') * 100::NUMERIC) AS avg
FROM netflix
WHERE country = 'India'
GROUP BY Year
ORDER BY Year DESC;
```

### List All Movies that are Documentaries
```sql
SELECT *
FROM netflix
WHERE listed_in IN (
    SELECT UNNEST(STRING_TO_ARRAY(listed_in, ','))
    FROM netflix
    WHERE listed_in = 'Documentaries' AND type = 'Movie'
);
```

### Find Content Without a Director
```sql
SELECT *
FROM netflix
WHERE director IS NULL;
```

### Find Movies with Actor 'Salman Khan' in Last 10 Years
```sql
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

### Top 10 Actors with Highest Movies in India
```sql
SELECT UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor, COUNT(*) AS no_of_movies
FROM netflix 
WHERE type = 'Movie' AND country = 'India'
GROUP BY actor
ORDER BY no_of_movies DESC
LIMIT 10;
```

### Categorize Content Based on Keywords
```sql
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
```

