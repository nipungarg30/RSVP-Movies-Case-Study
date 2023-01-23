USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

-- Row Count for Director Mapping Table
SELECT COUNT(*) as RowCount_director_mapping_table FROM director_mapping ;
-- Ans: 3867 Rows

-- Row Count for Genre Table
SELECT COUNT(*) as RowCount_genre_table FROM genre ;
-- Ans: 14662 Rows

-- Row Count for Movie Table
SELECT COUNT(*) as RowCount_movie_table FROM movie ;
-- Ans: 7997 Rows

-- Row Count for Names Table
SELECT COUNT(*) as RowCount_names_table FROM names ;
-- Ans: 25735 Rows

-- Row Count for Ratings Table
SELECT COUNT(*) as RowCount_ratings_table FROM ratings ;
-- Ans: 7997 Rows

-- Row Count for Role Mapping Table 
SELECT COUNT(*) as RowCount_role_mapping_table FROM director_mapping ;
-- Ans: 3867 Rows


-- Q2. Which columns in the movie table have null values?
-- Type your code below:

SELECT
	COUNT(*) - COUNT(id) AS id_nulls,
    COUNT(*) - COUNT(title) AS title_nulls,
    COUNT(*) - COUNT(year) AS year_nulls,
    COUNT(*) - COUNT(date_published) AS date_published_nulls,
    COUNT(*) - COUNT(duration) AS duration_nulls,
    COUNT(*) - COUNT(country) AS country_nulls,
    COUNT(*) - COUNT(worlwide_gross_income) AS worlwide_gross_income_nulls,
    COUNT(*) - COUNT(languages) AS languages_nulls,
    COUNT(*) - COUNT(production_company) AS production_company_nulls
FROM
	movie;

-- Ans: There are 4 columns that contain null Values. These are: country, worldwide_gross_income, languages and production_company

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Part 1

SELECT
	Year,
    COUNT(year) AS number_of_movies
FROM
	movie
GROUP BY
	year
ORDER BY
	COUNT(year) DESC;

/*
Ans: There is a decreasing trend in the number of movies released every year from 2017 to 2019.
In 2017, 3052 movies were released followed by 2944 in 2018 and 2001 in 2019.
*/


-- Part 2

SELECT
	MONTH(date_published) AS month_num,
    COUNT(*) AS number_of_movies
FROM
	movie
GROUP BY
	MONTH(date_published)
ORDER BY
	MONTH(date_published) ;

-- Ans: The month of March (824) has the most movies released and December has the least (438).

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT
	COUNT(id) AS number_of_movies 
FROM
	movie
WHERE
	year = 2019 and country regexp 'USA|India';


-- Ans: There were 1059 movies produced by USA or India in 2019. 

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:


SELECT
	DISTINCT genre
FROM
	genre;

-- There are total 13 different genres.


/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:


WITH Ranks AS
(
SELECT
	genre, 
    COUNT(movie_id) AS movies_produced_count,
	RANK() OVER (ORDER BY COUNT(movie_id) DESC) AS genre_rank
FROM 
	genre
GROUP BY
	genre
ORDER BY
	movies_produced_count DESC
)
SELECT genre, movies_produced_count
FROM Ranks
WHERE genre_rank=1;


-- Ans: The most popular genre is Drama with 4285 movies produced.

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:


WITH one_genre AS(
SELECT
	movie_id,
	COUNT(movie_id) AS number_of_genre
FROM 
	genre
GROUP BY
	movie_id
)
SELECT
	COUNT(movie_id) AS movie_with_one_genre
FROM
	one_genre
WHERE
	number_of_genre < 2;

-- Ans: There are 3289 single genre movies.


/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT
	gn.genre,
    ROUND(AVG(duration),2) AS avg_duration
FROM
	genre AS gn
INNER JOIN
	movie AS mv
	ON mv.id = gn.movie_id
GROUP BY
		genre
ORDER BY
	avg_duration DESC ;

-- Action genre has the highest avergae duration.



/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH genre_ranking AS (
SELECT
	genre,
	COUNT(genre) AS movie_count,
	RANK()	OVER(ORDER BY COUNT(genre) DESC) AS genre_rank
FROM
	genre
GROUP BY
	genre
)
SELECT *
FROM
	genre_ranking
WHERE
	genre = 'thriller';
    
    
-- Ans: There are 1484 movies which have been produced under the Thriller genre and the genre rank that Thriller has is 3.

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT
	min(avg_rating) AS min_avg_rating,
    max(avg_rating) AS max_avg_rating,
    min(total_votes) AS min_total_votes,
    max(total_votes) AS max_total_votes,
    min(median_rating) AS min_median_rating,
    max(median_rating) AS max_median_rating
FROM
	ratings;


/*
Ans: 
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		1.0		|			10.0	|	       100		  |	   725138	    	 |		1	       |	10			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
*/
    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too
WITH top_rated_movies AS
( 
SELECT
	m.title,
    r.avg_rating,
    RANK() OVER( ORDER BY avg_rating DESC ) AS movie_rank
FROM
	ratings AS r
INNER JOIN
	movie AS m
    ON r.movie_id = m.id
)
SELECT *
FROM
	top_rated_movies
WHERE
	movie_rank <=10 ;

-- Top 3 movies have average rating >= 9.8


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT
	median_rating,
    COUNT(movie_id) AS movie_count
FROM 
	ratings
GROUP BY
	median_rating
ORDER BY
	movie_count DESC ;

-- Movies with a median rating of 7 have a count of 2257, which is the highest. The lowest is 1 with a count of 94.

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

WITH prod_rank AS (
SELECT
	m.production_company,
    COUNT(id) AS movie_count,
    DENSE_RANK() OVER( ORDER BY COUNT(id) DESC ) AS prod_company_rank
FROM
	ratings AS r
INNER JOIN
	movie AS m
    ON r.movie_id = m.id
WHERE
	avg_rating > 8 AND production_company IS NOT NULL
GROUP BY
	production_company
)
SELECT *
FROM
	prod_rank
WHERE
	prod_company_rank = 1 ;

-- Ans. Dream Warrior Pictures and National Theatre Live production houses has produced the most number of hit movies (average rating > 8)

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


SELECT
	genre,
    COUNT(g.movie_id) AS movie_count
FROM
	genre AS g
INNER JOIN
	movie AS m
    ON m.id = g.movie_id
INNER JOIN 
	ratings AS r
    ON m.id = r.movie_id
WHERE
	year = 2017 AND MONTH(date_published) = 3
    AND country LIKE '%USA%' AND total_votes > 1000 
GROUP BY
	genre 
ORDER BY
	movie_count DESC;
    
-- Drama had the most number of movies released in March 2017 in USA.

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT
	title,
    avg_rating,
	genre
FROM 
	movie AS m
INNER JOIN
	ratings AS r
	ON m.id = r.movie_id
INNER JOIN
	genre AS g
	ON m.id = g.movie_id
WHERE
	avg_rating > 8 AND title like 'the%'
ORDER BY
	avg_rating DESC ;


-- Top 3 movies belongs to Drama genre.


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:


SELECT
	COUNT(m.id) AS movie_count
FROM
	movie AS m
INNER JOIN
	ratings AS r
	ON m.id = r.movie_id
WHERE
	median_rating = 8
    AND date_published BETWEEN '2018-04-01' AND '2019-04-01' ;


-- Ans: 361 movies were released.

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT 
	languages,
	SUM(total_votes) AS total_votes
FROM	                                     -- German movies votes  	
	movie AS m	
INNER JOIN	
	ratings AS r
    ON r.movie_id = m.id
WHERE	
	languages LIKE '%german%'                

UNION                            -- Combining results of two queries using union
    
SELECT 
	languages,
	SUM(total_votes) AS total_votes
FROM		                                  -- Italian movies votes  
	movie AS m	
INNER JOIN	
	ratings AS r
    ON r.movie_id = m.id
WHERE	
	languages LIKE '%italian%'
;



-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:



SELECT
    COUNT(*) - COUNT(name) AS name_nulls,
    COUNT(*) - COUNT(height) AS height_nulls,
    COUNT(*) - COUNT(date_of_birth) AS date_of_birth_nulls,
    COUNT(*) - COUNT(known_for_movies) AS dknown_for_movies_nulls
FROM
	names;


/*
Ans:
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|		17335		|	       13431	  |	   15226	    	 |
+---------------+-------------------+---------------------+----------------------+
*/


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


-- CTE for best 3 genres having a rating of > 8
WITH top3_genres AS(
-- CTE for getting the genres
WITH Genre_ranks AS(
SELECT
	g.genre, 
    r.avg_rating,
    COUNT(m.id), 
    RANK() OVER (ORDER BY COUNT(m.id) DESC) AS Rankings_of_Genres
FROM
	genre AS g 
INNER JOIN movie AS m 
	ON g.movie_id = m.id
INNER JOIN ratings AS r
	ON m.id = r.movie_id
WHERE
	r.avg_rating > 8
GROUP BY
	g.genre
)
SELECT *
FROM
	Genre_ranks 
WHERE 
	Rankings_of_Genres < 4) 
-- CTE for best directors
, best_directors AS
(
SELECT 
	n.name AS director_name,
    COUNT(g.movie_id) AS movie_count,
	ROW_NUMBER() OVER(ORDER BY COUNT(g.movie_id) DESC) AS director_rank 
FROM
	names AS n 
INNER JOIN director_mapping AS dm
	ON n.id = dm.name_id
INNER JOIN movie AS m
	ON dm.movie_id = m.id
INNER JOIN genre AS g
	ON m.id=g.movie_id
INNER JOIN ratings AS r
	ON g.movie_id=r.movie_id,
top3_genres
WHERE 
	r.avg_rating > 8 AND g.genre IN (top3_genres.genre)
GROUP BY
	director_name
ORDER BY 
	movie_count DESC)
-- Final query to get the best 3 directors
SELECT 
	director_name,
    movie_count FROM best_directors
WHERE 
	director_rank < 4;


/*
Ans:	
+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|Anthony Russo	|		3			|
|Joe Russo		|		3			|
+---------------+-------------------+ 
The best 3 are James Mangold, Anthony Russo, Joe Russo.
*/


/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


-- CTE for top actors with median rating >=8
WITH actors_summary AS
(
SELECT
	name AS actor_name,
    COUNT(n.id) AS movie_count,
    RANK() OVER(ORDER BY COUNT(n.id) DESC ) AS actor_rank
FROM 	
	names AS n
INNER JOIN		
	role_mapping AS ro
    ON ro.name_id = n.id
INNER JOIN
	ratings AS ra
    ON ra.movie_id = ro.movie_id
WHERE
	median_rating >= 8 AND category = 'actor'
GROUP BY
	name
ORDER BY COUNT(n.id) DESC
)
SELECT
	actor_name,
    movie_count
FROM
	actors_summary
WHERE
	actor_rank < 3;
	
/*
Ans:
+-----------+----------------+
| actor_name|	movie_count	 |
+-------------------+--------+
|Mammootty	|		8		 |
|Mohanlal	|		5		 |
+-----------+----------------+
The best 2 actors are Mammootty, Mohanlal.
*/



/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH prod_houses AS
(
SELECT
	production_company,
    SUM(total_votes) AS vote_count,
    RANK() OVER( ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM
	movie AS m
INNER JOIN
	ratings AS r
    ON r.movie_id = m.id
GROUP BY
	production_company
)
SELECT *
FROM
	prod_houses
WHERE
	prod_comp_rank < 4;
    

-- Top three production houses based on the number of votes received by their movies are Marvel Studios, Twentieth Century Fox and Warner Bros.


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


WITH top_actor AS
(
SELECT
	n.name AS actor_name,
    SUM(total_votes) AS total_votes,
    COUNT(m.id) AS movie_count,
    ROUND(SUM(ra.avg_rating*ra.total_votes)/SUM(ra.total_votes),2) AS actor_avg_rating
FROM
	names AS n
INNER JOIN
	role_mapping AS ro
    ON n.id = ro.name_id
INNER JOIN
	ratings AS ra
    ON ra.movie_id = ro.movie_id
INNER JOIN
	movie AS m
    ON m.id = ra.movie_id
WHERE
	ro.category = 'actor' AND country = 'India'
GROUP BY
	name
HAVING
	movie_count >=5
)
SELECT *,
	RANK() OVER( ORDER BY actor_avg_rating DESC) AS actor_rank
FROM
	top_actor ;


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


WITH actress_summary AS
(
SELECT
	n.name AS actress_name,
    SUM(total_votes) AS total_votes,
    COUNT(m.id) AS movie_count,
    ROUND(SUM(ra.avg_rating*ra.total_votes)/SUM(ra.total_votes),2) AS actress_avg_rating
FROM
	names AS n
INNER JOIN
	role_mapping AS ro
    ON n.id = ro.name_id
INNER JOIN
	ratings AS ra
    ON ra.movie_id = ro.movie_id
INNER JOIN
	movie AS m
    ON m.id = ra.movie_id
WHERE
	ro.category = 'actress' AND country = 'India'  AND languages like '%Hindi%'
GROUP BY
	name
HAVING
	movie_count >=3
)
, top_actress AS
(
SELECT *,
	RANK() OVER( ORDER BY actress_avg_rating DESC) AS actress_rank
FROM
	actress_summary 
)
SELECT *
FROM top_actress
WHERE actress_rank < 6 ;

-- Taapsee Pannu tops with average rating 7.74. 


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:


SELECT
	m.title AS movie_title,
    CASE
		WHEN r.avg_rating > 8 THEN 'Superhit movies'
		WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'	
		WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
        ELSE 'Floop movies'
        END AS movie_category
FROM
	genre AS g
INNER JOIN	
	ratings AS r
    ON r.movie_id = g.movie_id
INNER JOIN
	movie AS m
    ON m.id = r.movie_id
WHERE
	genre = 'thriller';




/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


SELECT
	g.genre,
    ROUND(AVG(duration),2) AS avg_duration,
    SUM(ROUND(AVG(duration),2)) OVER( ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
    ROUND(AVG(ROUND(AVG(duration),2)) OVER( ORDER BY genre ROWS UNBOUNDED PRECEDING),2) AS moving_avg_duration
FROM
	genre AS g
INNER JOIN
	movie AS m
    ON m.id = g.movie_id
GROUP BY
	genre;


/* Ans:
+---------------+-------------------+-------------------------+------------------------------+
| genre			|	avg_duration	|running_total_duration   |         moving_avg_duration  |
+---------------+-------------------+-------------------------+------------------------------+
|	Action		|		112.88		|	       112.88   	  |	   112.88    	    	     |
|Adventure		|		101.87		|	       214.75		  |	   107.38           		 |
|	Comedy		|		102.62		|	       317.37		  |	   105.79   	    		 |
|	Crime		|		107.05		|	       424.42		  |	   106.11   	    		 |
|	Drama		|		106.77		|	       531.19		  |	   106.24           		 |
|	Family		|		100.97		|	       632.16		  |	   105.36           		 |
|	Fantasy		|		105.14		|	       737.30		  |	   105.33		    		 |
|	Horror		|		92.72		|	       830.02		  |	   103.75		    		 |
|	Mystery		|		101.80		|	       931.82		  |	   103.54		    		 |
|	Others		|		100.16		|	       1031.98		  |	   103.20	 	    		 |
|	Romance		|		109.53		|	       1141.51		  |	   103.77		    		 |
|	Sci-Fi		|		97.94		|	       1239.45		  |	   103.29		    		 |
|Thriller		|		101.58		|	       1341.03		  |	   103.16		    		 |
+---------------+-------------------+-------------------------+------------------------------+
Note: Unbounded preceding can be used for the rolling average here but 13 was chosen as it was more time efficient.
*/


-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies



WITH movie_summary AS
(
SELECT
	genre,
    year,
    title,
    CAST(TRIM(REPLACE(REPLACE(worlwide_gross_income, "INR",""),"$","")) AS DECIMAL(10)) AS worlwide_gross_income
FROM movie AS m
INNER JOIN
	genre AS g
    ON m.id = g.movie_id
WHERE  genre IN 
(
WITH top3_genre AS
(
SELECT
	genre,
    RANK() OVER( ORDER BY COUNT(movie_id) DESC ) AS genre_rank
FROM genre
GROUP BY genre
)
SELECT genre
FROM top3_genre
WHERE genre_rank < 4
)
GROUP BY
	title
)
, top_5_movie AS
(
SELECT *,
	RANK() OVER( PARTITION BY year ORDER BY worlwide_gross_income DESC ) AS movie_rank
FROM movie_summary
)
SELECT *
FROM top_5_movie
WHERE movie_rank <=5
;
    
/*
The Fate of the Furious ranked 1 in 2017, The Villain ranked 1 in 2018 and
Avengers: Endgame ranked 1 in 2019 as highest-grossing movies .
*/


-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:


WITH prodcomp_summary AS
(
SELECT
	production_company,
	COUNT(m.id) AS movie_count,
    RANK() OVER( ORDER BY COUNT(m.id) DESC ) AS prod_comp_rank
FROM
	movie AS m
INNER JOIN
	ratings AS r
    ON m.id = r.movie_id
WHERE
	median_rating >= 8
    AND POSITION(',' IN languages)>0
    AND production_company IS NOT NULL
GROUP BY
	production_company
)
SELECT *
FROM prodcomp_summary
WHERE prod_comp_rank <3
;

/*
Ans: 
+---------------------+-------------------+---------------------+
|production_company   |movie_count		  | 	prod_comp_rank  |
+---------------------+-------------------+---------------------+
| Star Cinema		  |		7			  |		1   		    |
|Twentieth Century Fox|		4			  |		2    		    |
+---------------------+-------------------+---------------------+

*/



-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH top_actress AS
(SELECT
	name AS actress_name,
    SUM(total_votes) AS total_votes,
    COUNT(ra.movie_id) AS movie_count,
    ROUND(SUM(ra.avg_rating*ra.total_votes)/SUM(ra.total_votes),2) AS actress_avg_rating,
    ROW_NUMBER() OVER( ORDER BY COUNT(ra.movie_id) DESC ) AS actress_rank
FROM
	names AS n
INNER JOIN
	role_mapping AS ro
    ON ro.name_id = n.id
INNER JOIN
	ratings AS ra
    ON ra.movie_id = ro.movie_id
INNER JOIN
	genre AS g
    ON g.movie_id = ra.movie_id
WHERE
	avg_rating > 8
    AND category = 'actress'
    AND genre = 'drama'
GROUP BY
	name
)
SELECT *
FROM
	top_actress
WHERE
	actress_rank <=3 ;

/*
Ans:
+-----------------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	        |	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+-----------------------+-------------------+---------------------+----------------------+-----------------+
|	Parvathy Thiruvothu	|			4974	|	       2		  |	   8.30			     |		1	       |
|		Susan Brown		|			656		|	       2		  |	   8.90	    		 |		2	       |
|	Amanda Lawrence		|			656		|	       2		  |	   8.90	    		 |		3	       |
+-----------------------+-------------------+---------------------+----------------------+-----------------+
*/



/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:


WITH director_summary AS
(
SELECT
	d.name_id AS director_id,
    n.name AS director_name,
    m.id AS movie_id,
    date_published,
    avg_rating,
    total_votes,
    duration,
    LEAD(date_published) OVER( PARTITION BY d.name_id ORDER BY date_published ) AS next_movie_date
FROM
	director_mapping AS d
INNER JOIN
	names AS n
    ON d.name_id = n.id
INNER JOIN
	ratings AS r
    ON d.movie_id = r.movie_id
INNER JOIN
	movie AS m
    ON m.id = r.movie_id
),
date_difference AS
(
SELECT *,
DATEDIFF(next_movie_date, date_published) AS date_diff
FROM director_summary
)
, final_result AS
(
SELECT
	director_id,
    director_name,
    COUNT(movie_id) AS movie_count,
    ROUND(AVG(date_diff)) AS avg_inter_movie_days,
    ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS avg_rating,
    SUM(total_votes) AS total_votes,
    MIN(avg_rating) AS min_rating,
    MAX(avg_rating) AS max_rating,
    SUM(duration) AS total_duration,
    RANK() OVER( ORDER BY COUNT(movie_id) DESC) AS director_rank
FROM
	date_difference
GROUP BY
	director_id
)
SELECT
	director_id,
    director_name,
    movie_count,
    avg_inter_movie_days,
    avg_rating,
    total_votes,
    min_rating,
    max_rating,
    total_duration
FROM
	final_result
WHERE
	director_rank < 10 ;

