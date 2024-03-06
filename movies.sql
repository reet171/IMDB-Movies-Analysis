-- 1.	What are all Directors Names and total count of unique directors in directors’ table?
select Directors from directors;
select count(distinct(Directors)) from directors;

-- 2.	What are  unique Actors name  in actors’s table?
select actor from actors
group by actor;

-- 3.	What is the color, languages, country, title_year based on the distribution of movies in the movies table.
select color,languages,country,title_year,count(Movie_id) as No_of_movies
from movies
group by color,languages,country,title_year 
order by No_of_movies desc ;

-- 4.	What is the highest and lowest grossing, highest and lowest budget movies in the Database?
select * from movies;
select * from movies
where gross=(select max(gross) from movies);

select * from movies
where gross=(select min(gross) from movies);

select * from movies
where budget=(select max(budget) from movies);

select * from movies
where budget=(select min(budget) from movies where budget>0);



-- 5.	Retrieve a list of movie titles along with a column indicating whether the movie duration is above 120 minutes or not.
select movie_title , duration,
	case 
		when duration> 120 then 'above 120 min'
        else 'below 120 min'
	end as category
from movies;


-- 6.	Find the top 5 genres based on the number of movies released in the last 5 years.
select genres,count(*) as count
from movies
where title_year>(select max(title_year) from movies) -5
group by genres
order by 2 desc
limit 5;

-- 7.	Retrieve the movie titles directed by a director whose average movie duration is above the overall average duration.
select movie_title
from movies 
where Director_ID in
(
select Director_ID
from movies
group by Director_ID
having avg(duration)>(select avg(duration) from movies)
);
 


-- 8.Calculate the average budget of movies over the last 3 years, including the average budget for each movie.

select movie_title,
	avg(budget) over (order by title_year rows between 2 preceding and current row) as avg_budget_last_3_years
from movies
where title_year is not null;


-- 9.	Retrieve a list of movies with their genres, including only those genres that have more than 5 movies.

select movie_title,genres
from movies
where genres in
(
select genres 
from movies 
group by genres
having count(*) >5
)

-- 10.	Find the directors who have directed at least 3 movies and have an average IMDb score above 7.

select d.Directors,count(*) as movie_count,round(avg(imdb_score),2) as avg_imbd_score
from movies m
inner join directors d on m.Director_ID=d.D_ID
group by d.Directors
having count(*) >= 3 and round(avg(imdb_score),2)>7
order by 3 desc;

-- 11.	List the top 3 actors who have appeared in the most movies, and for each actor, provide the average IMDb score of the movies they appeared in.

select a.actor,
	count(*) as movie_count,
    round(avg(imdb_score),2) as avg_imdb_score
from actors a
left join movies m on concat('|', m.actors, '|') like concat('%|',a.actor,'|%')
group by a.actor
order by movie_count desc
limit 3;

-- 12.	For each year, find the movie with the highest gross, and retrieve the second highest gross in the same result set.
with RankedMovies as(
select movie_title,gross,title_year,
	row_number() over (partition by title_year order by gross desc) as new_rank
from movies
)

select title_year,
	max(case when new_rank=1 then movie_title end) as highest_grossing_movie,
    max(case when new_rank=2 then movie_title end) as second_highest_grossing_movie
from RankedMovies
where new_rank<=2
group by title_year
order by title_year desc;


-- 13.	Create a stored procedure that takes a director's ID as input and returns the average IMDb score of the movies directed by that director.

DELIMITER // 

create procedure Avg_IMDB_SCORE (in D_ID varchar(255))
begin
	select avg(imdb_score)
    from movies
    where Director_ID= D_ID;
end//

DELIMITER ;
call Avg_IMDB_SCORE('D1002')


-- 14.	Retrieve the top 3 movies based on IMDb score, and include their ranking.

select movie_title,imdb_score,
	rank() over (order by imdb_score desc) as ranking
from movies
where imdb_score is not null
order by imdb_score desc
limit 3;

-- 15.	For each director, list their movies along with the IMDb score and the ranking of each movie based on IMDb score.

select Director_ID,movie_title,imdb_score,
	rank() over(partition by Director_ID order by imdb_score desc) as ranking
from movies
where imdb_score is not null
order by Director_ID,imdb_score desc;



