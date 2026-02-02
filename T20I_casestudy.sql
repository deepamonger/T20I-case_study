-- identify matches		between two person  team, (e.g india and south africa) in 2024 and their result 
select * from T20I where (team1 = 'south africa' and team2 = 'india') or
(team1 = 'india' and team2 = 'south afria') and year(MatchDate) = 2024

--find the team with the  higest number of  wins in 2024 and total matches it won

select   winner, count(*) as 'number of win' from T20I where year(matchdate) = 2024
group by winner order by 'number of win' desc;

--rank the team based on the total number of wins in 2024
select   winner, count(*) as 'number of win', dense_rank() over(order by count(*) desc) as rank_section
from T20I where year(matchdate) = 2024 and winner not in('tied', 'no result')
group by winner 

---which team had the highest average winning margin(in run), and what was the average margin?

select winner, AVG(CAST(SUBSTRING(margin, 1, CHARINDEX(' ', margin)-1)as INT)) as aver_margin
from T20I 
where margin like '%runs'
group by winner
ORDER BY AVER_MARGIN DESC



--LIST ALL MATCHES WHERE THE WINNING MARGIN WAS GREATER THAN THE AVERAGE MARGIN ACROSS all matches

with cte_avgmargin as 
	(select  AVG(CAST(SUBSTRING(margin, 1, CHARINDEX(' ', margin)-1)as INT)) as aver_margin
	from T20I 
	where margin like '%runs'
	)
select T.Team1, T.Team2, T.Winner, T.Margin from T20I T 
left join cte_avgmargin A on 1 =1 
where T.margin like '%runs' and CAST(SUBSTRING(margin, 1, CHARINDEX(' ', margin)-1)as INT) > A.aver_margin

--- SUBSTRING(Margin, 1, CHARINDEX(' ', Margin) - 1)
--- Extracts the number before the space
-----Example: '25 runs' → '25' CAST(... AS INT)
----Converts text to integer
----AVG(...)
----Calculates average margin
----WHERE Margin LIKE '%runs'
----Keeps only results won by runs (not wickets)
-- expalnation about 1 = 1 because we dont have any common column whih will become true  

-- find the	team with the most win when chasing a target (wins by wickets)

select winner, total_winner 
from(
	 
	 select winner, count(*) as total_winner,
	rank() over(order by count(*) desc) as rank_section
	 from T20I where margin like '%wickets' and 
	 winner not in ('tied', 'no result') group by winner 
) t
where rank_section = 1

-- note rank() over(order by count(*) desc) as rank_section this is window function 

--07 head to head  record between  two selected team(e.g england vs australia)

declare @teamA varchar(25) = 'england';
declare @teamB varchar(25) = 'Australia';

select winner, count(*)  as matches from  T20I 
 where(Team1 = @TeamA and Team2 = @TeamB) or (Team1 = @TeamB and Team2 = @TeamA)
 group by winner

 --identify the month in 2024 with the higest number of T20I matches played 

 select * from T20I;

 select year(MatchDate) As Yearplayed,  
        Month(matchdate) AS Monthnumber,
		DATENAME(MONTH, MatchDate) As MONTHNAME, 
		count(*) as matchesPlayed
 from T20I where year(MatchDate) = 2024
 group by year(matchDate), Month(MatchDate),DATENAME(MONTH, MatchDate) order by matchesPlayed desc

 --for each team, find how many matches they played in 2024 and their win percentage
with cte_MatchesPlayed as ( 
select team, count(*) as Matcheplayed
from (
select Team1 as Team 
 from T20I 
where year(MatchDate) = 2024
union all
select Team2 as Team 
 from T20I 
where year(MatchDate) = 2024
) t
group by Team
),
cte_wind as(
select winner as team , count(*) as win 

from T20I
where year(MatchDate) = 2024 and winner not in ('tied', 'no result')
group by winner 
)

select m.team, m.Matcheplayed,isnull( w.win,0) as wins,

cast(isnull( w.win,0)*100.0/m.Matcheplayed as decimal(5,2))as winPercentage 

from cte_MatchesPlayed m
left join cte_wind w
on m.team = w.team 
order by winPercentage Desc

--identify the most successful team at each ground(team wtih most win per ground)

	select * from T20I;
WITH CTE_WINSPERGROUND AS(		
	select ground, winner, wins, RANK() OVER(PARTITION BY GROUND ORDER BY WINS DESC) as rn 
	from 
	(
	select Ground, winner, count(*) as wins 
	from T20I 
	where winner not in ('tied', ' no result')
	group by  ground, winner) t		
	)
	select ground, winner as mostsuccessfulteam, wins from
	CTE_WINSPERGROUND where rn = 1  order by ground 