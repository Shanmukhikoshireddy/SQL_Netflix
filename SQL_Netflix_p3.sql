
drop table if exists netflix;
create table netflix(
show_id varchar(6),
type varchar(7),
title varchar(150),
director varchar(208),	
casts varchar(1000),
country	varchar(150),
date_added	varchar(50),
release_year INT,	
rating	varchar(10),
duration varchar(15),
listed_in varchar(80),
description varchar(250)
)


select distinct type from netflix;
select count(*) as total_count from netflix;

--Queries 
--Count the number of Movies vs TV Shows
select type,count(*) as total_content
 from netflix group by type;

--	q2Find the most common rating for movies and TV shows

SELECT type,rating from (
select type,rating,count(*),
 rank() over(partition by type order by count(*) desc) as ranking
 from netflix
 group by 1,2
) as t
where ranking =1;

--q3  List all movies released in a specific year (e.g., 2020)
select title from netflix where release_year=2020 and type='Movie';

--q4 Find the top 5 countries with the most content on Netflix

select 
    UNNEST(STRING_TO_ARRAY(country,',')) AS NEW_COUNTRY,count(*)
FROM NETFLIX group by 1 order by 2 desc limit 5;

--q5 Identify the longest movie
select * from netflix where type='Movie' and duration=(select max(duration) from netflix where type='Movie');

--q6  Find content added in the last 5 years

select * from netflix where TO_DATE(date_added,'Month DD,YYYY')>=current_date-interval '5 years'

--q7 Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from netflix where director ILIKE '%Rajiv Chilaka%';

--q8 List all TV shows with more than 5 seasons
select * from netflix where type='TV Show' and SPLIT_PART(duration,' ',1)::numeric > 5;

--q9 Count the number of content items in each genre
select UNNEST(STRING_TO_ARRAY(listed_in,','))as content_items,count(show_id) from netflix group by 1;

-- q10 Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

select 
extract(year from to_date(date_added,'Month DD,YYYY')) AS year,
count(*) ,
round(count(*)::numeric/(select count(*) from netflix where country ILIKE '%India%') * 100 ,2)as avg_content_per_year
from netflix where country='India' group by 1;

--q11 List all movies that are documentaries
select * from netflix where type='Movie' and listed_in ILIKE '%Documentaries%';

--Q12 Find all content without a director
select * from netflix where director is null;

--q13 Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix where casts ILIKE '%Salman Khan%' and release_year>extract(year from current_date) - 10;

--q14 Find the top 10 actors who have appeared in the highest number of movies produced in India.
select 
    unnest(string_to_array(casts,',')) as actors,
	count(*) as total_content
from netflix where country ILIKE '%India'
group by 1 order by 2 desc limit 10

--q15 Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

with new_table as(
select *, case when description ILIKE '%kill%' or  description ILIKE '%violence%' then 'Bad_content'
else 'Good_content'
end category
from netflix  )
select category,count(*) as total_content from new_table group by 1;
