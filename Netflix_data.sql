-- Requires MySQL 8.0+ (window functions and JSON_TABLE).
-- Run CREATE DATABASE / USE, then import Netflix_Data.csv with Workbench's
-- Table Data Import Wizard into netflix_data. Keep date_added as TEXT.
-- Run the remaining statements after importing the CSV.
CREATE DATABASE IF NOT EXISTS netflix_database;

USE netflix_database;

SELECT * FROM netflix_data LIMIT 10;

-- What is the total number of 'Movies' and 'TV Shows' on Netflix?

SELECT type, COUNT(*) total_count
FROM netflix_data
GROUP BY type;

-- . Which country has produced the most content (Movies + TV Shows) on Netflix? List the top 5 countries.

SELECT country, COUNT(DISTINCT show_id) AS total_content
FROM netflix_data
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;


--  Retrieve a list of all movies and TV shows released in the year 2020.

SELECT title, type
FROM netflix_data
WHERE release_year = 2020;

--  What are the titles of all movies directed by 'Kirsten Johnson'?

SELECT title
FROM netflix_data
WHERE director = 'Kirsten Johnson' AND type = 'Movie';

--  Which content rating is the most common on Netflix? (Count of titles by rating).

SELECT rating, COUNT(*) content_rating
FROM netflix_data
GROUP BY rating
ORDER BY content_rating DESC
LIMIT 1;

-- Find the TV shows that have 5 or more seasons

SELECT title, duration
FROM netflix_data
WHERE type = 'TV Show' AND 
CAST(SUBSTRING_INDEX(duration, ' ',1) AS UNSIGNED) >= 5;

--  List all the movies  that produced in 'India' that belong to the 'comedies' category

SELECT title, listed_in
FROM netflix_data
WHERE type = 'Movie' AND
      country = 'India' AND  
      listed_in LIKE '%comedies%';
      
-- How many movies/shows were released each year? Sort the results in descending order of the release year 

SELECT release_year, COUNT(*) AS movies_and_shows
FROM netflix_data
GROUP BY release_year
ORDER BY release_year DESC;

-- Who are the top directors with the highest number of directed movies (exluding 'Not Given')

SELECT director, COUNT(*) AS directed_movies
FROM netflix_data
WHERE type = 'Movie' AND TRIM(COALESCE(director, '')) NOT IN ('', 'Not Given')
GROUP BY director
ORDER BY directed_movies DESC
LIMIT 5;

-- In which year did netflix add the highest amount of content to its platform?

SELECT YEAR(STR_TO_DATE(TRIM(date_added), '%m/%d/%Y')) AS year_added,
			COUNT(*) AS total_release
FROM netflix_data
WHERE STR_TO_DATE(TRIM(date_added), '%m/%d/%Y') IS NOT NULL
GROUP BY year_added 
ORDER BY total_release DESC
LIMIT 1;

-- Which are the oldest movies released in India on Netflix?

SELECT title, release_year 
FROM netflix_data
WHERE type = 'Movie' AND country = 'India'
ORDER BY release_year ASC
LIMIT 5;

-- FInd the titles of all movies listed as 'Documentaries' that were released after the year 2015

SELECT title
FROM netflix_data
WHERE type = 'Movie' AND listed_in LIKE '%Documentaries%' AND release_year > 2015
ORDER BY release_year ASC;

-- Which movies has the longest duration in minutes on Netflix ?

SELECT title,
		CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS duration_minutes
FROM netflix_data
WHERE type = 'Movie'
ORDER BY duration_minutes DESC
LIMIT 5;

-- What is the most recently released movie for each country?

-- For tied release years, return every movie in the latest year.

WITH ranked_movies AS (
    SELECT title, country, release_year,
           DENSE_RANK() OVER (
               PARTITION BY country ORDER BY release_year DESC
           ) AS rnk
    FROM netflix_data
    WHERE type = 'Movie' AND release_year IS NOT NULL
)
SELECT country, title AS latest_movie, release_year
FROM ranked_movies
WHERE rnk = 1
ORDER BY country, latest_movie;

-- Identify the release years in which more than 50 movies from India were released.

SELECT release_year, COUNT(*) AS total_movies
FROM netflix_data
WHERE type = 'Movie' AND country = 'India'
GROUP BY release_year
HAVING total_movies > 50
ORDER BY release_year DESC;
