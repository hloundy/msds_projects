--This file contains various queries that can be run on a dataset containing various statistics regarding 
--NBA players. Found at:
--https://www.kaggle.com/datasets/jamiewelsh2/nba-per-game-player-statistics-2022-2023-season

CREATE DATABASE nba;

CREATE TABLE nba (
	index smallint,
	player_name varchar(100),
	position varchar(5),
	age smallint,
	team varchar(7),
	gp smallint,
	gs smallint,
	mp decimal(3, 1),
	fg decimal(3, 1),
	fga decimal(3, 1),
	fg_pct decimal(4, 3),
	thp decimal(3, 1),
	thpa decimal(3, 1),
	thp_pct decimal(4, 3),
	tp decimal(3, 1),
	tpa decimal(3, 1),
	tp_pct decimal(4, 3),
	efg_pct decimal(4, 3),
	ft decimal(3, 1),
	fta decimal(3, 1),
	ft_pct decimal(4, 3),
	orb decimal(3, 1),
	drb decimal(3, 1),
	trb decimal(3, 1),
	ast decimal(3, 1),
	stl decimal(3, 1),
	blk decimal(3, 1),
	tov decimal(3, 1),
	pf decimal(3, 1),
	pts decimal(3, 1), 
	player_additional varchar(100)
);

COPY nba 
FROM 'C:\Users\hloun\Desktop\SQL Storage\nba_per_game_processed.csv' 
WITH (FORMAT CSV, HEADER);

SELECT *
FROM nba;

--Player who averaged the most points per position
SELECT s1.player_name, s1.position, s1.pts AS points, s1.team
FROM nba s1
JOIN (
	SELECT position, MAX(pts) as points
	FROM nba 
	GROUP BY position) AS s2
	ON s1.position = s2.position AND s1.pts = s2.points
ORDER BY s2.points DESC;

--Total average points scored by each position
SELECT position, SUM(pts) AS total_points
FROM nba
GROUP BY position
ORDER BY SUM(pts) DESC;

SELECT DISTINCT(position)
FROM nba;

-- Checking for duplicates
SELECT player_name, position, COUNT(*)
FROM nba
GROUP BY player_name, position, team
HAVING COUNT(*) > 1;

--Three pointers by team per game, greatest to least
SELECT team, SUM(thp) AS threes_made
FROM nba
GROUP BY team
ORDER BY SUM(thp) DESC;

--Players who did not attempt a three pointer during the season
SELECT player_name
FROM nba
WHERE thpa = 0;

--Total number of average points scored by each position over the season
SELECT position, SUM(pts)
FROM nba
GROUP BY position
ORDER BY SUM(pts) DESC;

--These players did not attempt a field goal, therefore their field goal percentage and related percentages 
--(two point, three point, etc.) are all null.
SELECT *
FROM nba
WHERE fg_pct ISNULL;

--Setting dual position listings to the first position given in the expression
UPDATE nba
SET position = SUBSTRING(position FOR 2)
WHERE position ILIKE '%-%';

--Setting players listed with two teams to the first team in the expression
UPDATE nba
SET team = SUBSTRING(team FOR 3)
WHERE team ILIKE '%/%';

--Setting null values to -1
UPDATE nba
SET fg_pct = -1
WHERE fg_pct ISNULL;

UPDATE nba
SET thp_pct = -1
WHERE thp_pct ISNULL;

UPDATE nba
SET tp_pct = -1
WHERE tp_pct ISNULL;

UPDATE nba
SET efg_pct = -1
WHERE efg_pct ISNULL;

UPDATE nba
SET ft_pct = -1
WHERE ft_pct ISNULL;

--Select players who were in the top 10% of pts and assists
SELECT player_name, pts, ast 
FROM (SELECT 
 		player_name,
	  	pts,
	    ast,
	    PERCENT_RANK() OVER (ORDER BY pts DESC) AS pts_rank,
	    PERCENT_RANK() OVER (ORDER BY ast DESC) AS ast_rank
	  FROM nba 
	  GROUP BY player_name, pts, ast) AS ranked 
	  WHERE pts_rank <= 0.1 AND ast_rank <= 0.1;

--Average blocks per game by position
SELECT position, AVG(blk)
FROM nba
GROUP BY position
ORDER BY AVG(blk) DESC;

--Team with the highest average free throw percentage
SELECT team, ROUND(AVG(ft_pct) * 100, 2) AS avg_ft_pct
FROM nba
WHERE ft_pct != -1
GROUP BY team
ORDER BY AVG(ft_pct) DESC
LIMIT(1);

