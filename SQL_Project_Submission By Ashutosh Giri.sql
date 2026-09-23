-- =========================================
-- SQL Project Submission
-- Name: Ashutosh Giri
-- =========================================
--         Objective Questions
-- =========================================

-- =========================================
-- Question 1
-- List the different dtypes of columns in table 
-- 'ball_by_ball' (using information schema)
-- =========================================

select column_name, data_type from information_schema.columns
where table_schema = 'ipl'
and table_name = 'ball_by_ball';


-- =========================================
-- Question 2 
-- What is the total number of runs scored in 1st season by RCB
-- (bonus: also include the extra runs using the extra runs table)
-- =========================================

SELECT
    (SELECT SUM(Runs_Scored)
     FROM ball_by_ball
     WHERE Team_Batting = 2
     AND Match_Id IN (
         SELECT Match_Id FROM matches
         WHERE Season_Id = 6 AND (Team_1 = 2 OR Team_2 = 2)
     )) AS Total_Runs,

    (SELECT SUM(e.Extra_Runs)
     FROM extra_runs e
     JOIN ball_by_ball b
       ON e.Match_Id = b.Match_Id AND e.Over_Id = b.Over_Id
       AND e.Ball_Id = b.Ball_Id AND e.Innings_No = b.Innings_No
     WHERE b.Team_Batting = 2
     AND e.Match_Id IN (
         SELECT Match_Id FROM matches
         WHERE Season_Id = 6 AND (Team_1 = 2 OR Team_2 = 2)
     )) AS Total_Extras,

    (SELECT SUM(Runs_Scored)
     FROM ball_by_ball
     WHERE Team_Batting = 2
     AND Match_Id IN (
         SELECT Match_Id FROM matches
         WHERE Season_Id = 6 AND (Team_1 = 2 OR Team_2 = 2)
     ))
    +
    (SELECT SUM(e.Extra_Runs)
     FROM extra_runs e
     JOIN ball_by_ball b
       ON e.Match_Id = b.Match_Id AND e.Over_Id = b.Over_Id
       AND e.Ball_Id = b.Ball_Id AND e.Innings_No = b.Innings_No
     WHERE b.Team_Batting = 2
     AND e.Match_Id IN (
         SELECT Match_Id FROM matches
         WHERE Season_Id = 6 AND (Team_1 = 2 OR Team_2 = 2)
     )) AS Total_Including_Extras;

-- =========================================
-- Question 3
-- How many players were more than the age of 25 during season
-- 2014?
-- =========================================
select count(distinct p.Player_Id) AS Total_Players
from Player p
join Player_Match pm
    on p.Player_Id = pm.Player_Id
join Matches m
    on pm.Match_Id = m.Match_Id
where m.Season_Id = 7
  and timestampdiff(year, p.DOB, '2014-04-01') > 25;


-- =========================================
-- Question 4
-- How many matches did RCB win in 2013?
-- =========================================
select count(*) as matches_won
from matches
where season_id = 6 and 
match_winner = 2;

-- =========================================
-- Question 5
-- List the top 10 players according to their strike rate in the last 4
-- seasons
-- =========================================

select
    p.player_name,
    sum(b.runs_scored) as total_runs,
    count(*) as balls_faced,
    round((sum(b.runs_scored) * 100.0) / count(*), 2) as strike_rate
from ball_by_ball b
join matches m
    on b.match_id = m.match_id
join player p
    on b.striker = p.player_id
where m.season_id in (6, 7, 8, 9)
group by p.player_id, p.player_name
order by strike_rate desc
limit 10;

-- =========================================

-- Question 6
-- What are the average runs scored by each batsman considering
-- all the seasons?

-- =========================================

select p.player_name,
round(avg(t.match_runs), 2) as average_runs
from (select match_id, striker,
sum(runs_scored) as match_runs
from ball_by_ball
group by match_id, striker) as t
join player p
on t.striker = p.player_id
group by p.player_id, p.player_name
order by average_runs desc;

-- =========================================
-- Question 7
-- What are the average wickets taken by each bowler considering all
-- the seasons?
-- =========================================

select p.player_name,
round(avg(t.match_wickets), 2) as average_wickets
from (select b.match_id, b.bowler,
count(*) as match_wickets
from wicket_taken as w
join ball_by_ball as b
on w.match_id = b.match_id
and w.over_id = b.over_id
and w.ball_id = b.ball_id
and w.innings_no = b.innings_no
group by b.match_id, b.bowler) as t
join player as p on t.bowler = p.player_id
group by p.player_id, p.player_name
order by average_wickets desc;

-- =========================================
-- Question 8
-- List all the players who have average runs scored greater than the
-- overall average and who have taken wickets greater than the
-- overall average
-- =========================================

with batting as(select striker,
avg(match_runs) as avg_runs
from
(select match_id, striker,
sum(runs_scored) as match_runs
from ball_by_ball
group by match_id, striker
) as t group by striker),
bowling as (select bowler,
avg(match_wickets) as avg_wickets
from
(select b.match_id, b.bowler,
count(*) as match_wickets
from wicket_taken as w
join ball_by_ball as b
on w.match_id = b.match_id
and w.over_id = b.over_id
and w.ball_id = b.ball_id
and w.innings_no = b.innings_no
group by b.match_id, b.bowler)
as t group by bowler)
select p.player_name,
bt.avg_runs, bw.avg_wickets
from batting as bt
join bowling as bw
on bt.striker = bw.bowler
join player as p
on bt.striker = p.player_id
where bt.avg_runs > (select avg(avg_runs) from batting)
and bw.avg_wickets > (select avg(avg_wickets) from bowling)
order by bt.avg_runs desc, bw.avg_wickets desc;

-- =========================================
-- Question 9
-- Create a table rcb_record table that shows the wins and losses of
-- RCB in an individual venue.
-- =========================================

create table rcb_record as
select v.venue_name,
count(case when m.match_winner = 2 then 1 end) as wins,
count(case
when (m.team_1 = 2 or m.team_2 = 2)
and m.match_winner <> 2
and m.match_winner is not null
then 1 end) as losses
from matches as m
join venue as v
on m.venue_id = v.venue_id
where m.team_1 = 2
or m.team_2 = 2
group by v.venue_name;

-- =========================================
-- Question 10
-- What is the impact of bowling style on wickets taken?
-- =========================================

select bs.bowling_skill,
count(*) as total_wickets
from wicket_taken as w
join ball_by_ball as b
on w.match_id = b.match_id
and w.over_id = b.over_id
and w.ball_id = b.ball_id
and w.innings_no = b.innings_no
join player as p
on b.bowler = p.player_id
join bowling_style as bs
on p.bowling_skill = bs.bowling_id
group by bs.bowling_skill
order by total_wickets desc;

-- =========================================
-- Question 11
-- Write the SQL query to provide a status of whether the
-- performance of the team is better than the previous year's
-- performance on the basis of the number of runs scored by the
-- team in the season and the number of wickets taken
-- =========================================

with season_runs as
(select m.season_id,
sum(b.runs_scored) as total_runs
from matches as m
join ball_by_ball as b
on m.match_id = b.match_id
where b.team_batting = 2
group by m.season_id),
season_wickets as
(select m.season_id,
count(*) as total_wickets
from wicket_taken as w
join ball_by_ball as b
on w.match_id = b.match_id
and w.over_id = b.over_id
and w.ball_id = b.ball_id
and w.innings_no = b.innings_no
join matches as m
on b.match_id = m.match_id
where b.team_bowling = 2
group by m.season_id)
select
r.season_id, r.total_runs, w.total_wickets, case
when r.total_runs > lag(r.total_runs) over(order by r.season_id)
and w.total_wickets > lag(w.total_wickets) over(order by r.season_id)
then 'Better' else 'Not Better'
end as performance_status
from season_runs as r
join season_wickets as w
on r.season_id = w.season_id
order by r.season_id;

-- =========================================
-- Question 12
-- Can you derive more KPIs for the team strategy?
-- =========================================
-- NA
-- =========================================
-- Question 13
-- Using SQL, write a query to find out the average wickets taken by
-- each bowler in each venue. Also, rank the gender according to the
-- average value.
-- =========================================

with bowler_match_wickets as
(select m.venue_id, b.match_id,
b.bowler, count(*) as wickets
from wicket_taken as w
join ball_by_ball as b
on w.match_id = b.match_id
and w.over_id = b.over_id
and w.ball_id = b.ball_id
and w.innings_no = b.innings_no
join matches as m
on b.match_id = m.match_id
group by m.venue_id, b.match_id,
b.bowler)
select v.venue_name, p.player_name,
round(avg(bmw.wickets),2) as average_wickets,
dense_rank() over(partition by v.venue_name
order by avg(bmw.wickets) desc
) as bowler_rank
from bowler_match_wickets as bmw
join player p on bmw.bowler = p.player_id
join venue as v
on bmw.venue_id = v.venue_id
group by v.venue_name, p.player_name
order by v.venue_name, bowler_rank;

-- =========================================
-- Question 14
-- Which of the given players have consistently performed well in
-- past seasons? (will you use any visualization to solve the problem)
-- =========================================
with season_runs as
(select m.season_id, b.striker,
sum(b.runs_scored) as total_runs
from ball_by_ball as b
join matches as m
on b.match_id = m.match_id
group by m.season_id, b.striker)
select p.player_name,
count(sr.season_id) as seasons_played,
round(avg(sr.total_runs),2) as average_runs,
dense_rank() over(order by avg(sr.total_runs) desc) as player_rank
from season_runs as sr
join player as p
on sr.striker = p.player_id
group by
p.player_id, p.player_name
having count(sr.season_id) > 1
order by player_rank
limit 10;

-- =========================================
-- Question 15
-- Are there players whose performance is more suited to specific
-- venues or conditions? (how would you present this using charts?)
-- =========================================

with venue_runs as
(select v.venue_name, b.striker,
sum(b.runs_scored) as total_runs
from ball_by_ball as b
join matches as m
on b.match_id = m.match_id
join venue as v
on m.venue_id = v.venue_id
group by v.venue_name, b.striker),
ranked_players as (select
vr.venue_name, p.player_name, vr.total_runs,
dense_rank() over
(partition by vr.venue_name
order by vr.total_runs desc) as player_rank
from venue_runs as vr
join player as p
on vr.striker = p.player_id)
select * from ranked_players
where player_rank <= 10
order by venue_name, player_rank;

-- =========================================
--        Subjective Questions
-- =========================================

-- =========================================
-- Question 1
-- How does the toss decision affect the result of the match? (which
-- visualizations could be used to present your answer better) And is
-- the impact limited to only specific venues?
-- =========================================

select v.venue_name,
case
when m.toss_decide = 1 then 'field first'
when m.toss_decide = 2 then 'bat first'
end as toss_decision,
count(*) as total_matches,
sum(case
when m.match_winner = 2 then 1
else 0 end) as matches_won,
count(*) -
sum(case when m.match_winner = 2 then 1
else 0 end) as matches_lost,
round(sum(case
when m.match_winner = 2 then 1 else 0
end) * 100.0 / count(*),
2) as win_percentage
from matches as m
join venue as v
on m.venue_id = v.venue_id
where m.toss_winner = 2
group by
v.venue_name, m.toss_decide
order by
v.venue_name, win_percentage desc;

-- =========================================
-- Question 2
-- Suggest some of the players who would be best fit for the team.
-- =========================================

select p.player_name,
coalesce(b.total_runs, 0) as total_runs,
coalesce(w.total_wickets, 0) as total_wickets
from player as p
left join
(select striker as player_id,
sum(runs_scored) as total_runs
from ball_by_ball group by striker
) as b on p.player_id = b.player_id
left join
(select
bb.bowler as player_id,
count(*) as total_wickets
from ball_by_ball as bb
join wicket_taken as wt
on bb.match_id = wt.match_id
and bb.over_id = wt.over_id
and bb.ball_id = wt.ball_id
and bb.innings_no = wt.innings_no 
where wt.kind_out in (1, 2, 4, 6, 7, 8)
group by bb.bowler
) as w on p.player_id = w.player_id
where coalesce(b.total_runs, 0) > 0
or coalesce(w.total_wickets, 0) > 0
order by
total_runs desc, total_wickets desc 
limit 10;

-- =========================================
-- Question 3
-- What are some of the parameters that should be focused on while
-- selecting the players?
-- =========================================

select p.player_name,
coalesce(b.total_runs, 0) as total_runs,
coalesce(w.total_wickets, 0) as total_wickets,
timestampdiff(year, p.dob, curdate()) as age, bs.batting_hand,
bw.bowling_skill, r.role_desc
from player as p
left join
(select striker as player_id, sum(runs_scored) as total_runs
from ball_by_ball
group by striker
) as b on p.player_id = b.player_id
left join
(select bb.bowler as player_id, count(*) as total_wickets
from ball_by_ball as bb
join wicket_taken as wt
on bb.match_id = wt.match_id
and bb.over_id = wt.over_id
and bb.ball_id = wt.ball_id
and bb.innings_no = wt.innings_no
where wt.kind_out in (1, 2, 4, 6, 7, 8)
group by bb.bowler
)as  w on p.player_id = w.player_id
left join batting_style as bs
on p.batting_hand = bs.batting_id
left join bowling_style as bw
on p.bowling_skill = bw.bowling_id
left join
(select player_id, min(role_id) as role_id
from player_match
group by player_id) as 
pm on p.player_id = pm.player_id
left join rolee as r
on pm.role_id = r.role_id
where coalesce(b.total_runs, 0) > 0
or coalesce(w.total_wickets, 0) > 0
order by total_runs desc, total_wickets desc
limit 15;

-- =========================================
-- Question 4
-- Which players offer versatility in their skills and can contribute
-- effectively with both bat and ball? (can you visualize the data for
-- the same)
-- =========================================

with batting as (select
striker as player_id,
sum(runs_scored) as total_runs
from ball_by_ball
group by striker), bowling as (
select bb.bowler as player_id,
count(*) as total_wickets
from ball_by_ball as bb
join wicket_taken as wt
on bb.match_id = wt.match_id
and bb.over_id = wt.over_id
and bb.ball_id = wt.ball_id
and bb.innings_no = wt.innings_no
where wt.kind_out in (1, 2, 4, 6, 7, 8)
group by bb.bowler), 
ranked as (select p.player_name,
b.total_runs, w.total_wickets,
rank() over(order by b.total_runs desc) as batting_rank,
rank() over(order by w.total_wickets desc) as bowling_rank
from player as p
join batting as b
on p.player_id = b.player_id
join bowling as w
on p.player_id = w.player_id)
select player_name,
total_runs, total_wickets,
batting_rank, bowling_rank,
batting_rank + bowling_rank as versatility_score
from ranked
order by versatility_score
limit 10;

-- =========================================
-- Question 5
-- Are there players whose presence positively influences the morale
-- and performance of the team? (justify your answer using
-- visualization)
-- =========================================

with rcb_matches as (
select match_id, match_winner
from matches where team_1 = 2 or team_2 = 2
), player_performance as (
select p.player_id, p.player_name,
count(distinct pm.match_id) as matches_with_player,
sum(case when m.match_winner = 2 then 1 else 0 end) as wins_with_player
from player as p
join player_match as pm
on p.player_id = pm.player_id
and pm.team_id = 2
join rcb_matches as m
on pm.match_id = m.match_id
group by p.player_id, p.player_name),
rcb_summary as (select
count(*) as total_matches,
sum(case when match_winner = 2 then 1 else 0 end) as total_wins
from rcb_matches ) select
pp.player_name, pp.matches_with_player,
pp.wins_with_player,
round(
pp.wins_with_player * 100.0 / pp.matches_with_player, 2
) as win_percentage_with_player,
rs.total_matches - pp.matches_with_player as matches_without_player,
rs.total_wins - pp.wins_with_player as wins_without_player,
round(
(rs.total_wins - pp.wins_with_player) * 100.0 /
nullif(rs.total_matches - pp.matches_with_player, 0), 2
) as win_percentage_without_player, round(
(pp.wins_with_player * 100.0 / pp.matches_with_player)
        -
((rs.total_wins - pp.wins_with_player) * 100.0 /
nullif(rs.total_matches - pp.matches_with_player, 0)), 2
) as win_percentage_difference
from player_performance as pp
cross join rcb_summary as rs
where pp.matches_with_player >= 10
order by win_percentage_difference desc
limit 10;

-- =========================================
-- Question 6
-- What would you suggest to RCB before going to the mega
-- auction?
-- =========================================

with batting as (
select striker as player_id,
sum(runs_scored) as total_runs
from ball_by_ball
group by striker), bowling as 
(select bb.bowler as player_id,
count(*) as total_wickets
from ball_by_ball as bb
join wicket_taken as wt
on bb.match_id = wt.match_id
and bb.over_id = wt.over_id
and bb.ball_id = wt.ball_id
and bb.innings_no = wt.innings_no
where wt.kind_out in (1, 2, 4, 6, 7, 8)
group by bb.bowler)
select p.player_name,
coalesce(b.total_runs, 0) as total_runs,
coalesce(w.total_wickets, 0) as total_wickets,
r.role_desc
from player as p
join player_match as pm
on p.player_id = pm.player_id
and pm.team_id = 2
left join batting as b
on p.player_id = b.player_id
left join bowling as w
on p.player_id = w.player_id
left join rolee as r
on pm.role_id = r.role_id
group by p.player_id, p.player_name,
b.total_runs, w.total_wickets, r.role_desc
order by total_runs desc, total_wickets desc
limit 15;

-- =========================================
-- Question 7
-- What do you think could be the factors contributing to the
-- high-scoring matches and the impact on viewership and team
-- strategies
-- =========================================

select m.match_id, v.venue_name,
m.toss_decide, m.match_winner,
sum(bb.runs_scored + coalesce(er.extra_runs, 0)) as total_match_runs
from matches as m
join ball_by_ball as bb
on m.match_id = bb.match_id
left join extra_runs er
on bb.match_id = er.match_id
and bb.over_id = er.over_id
and bb.ball_id = er.ball_id
and bb.innings_no = er.innings_no
join venue as v
on m.venue_id = v.venue_id
where m.team_1 = 2
or m.team_2 = 2
group by m.match_id, v.venue_name,
m.toss_decide, m.match_winner
order by total_match_runs desc
limit 15;

-- =========================================
-- Question 8
-- Analyze the impact of home-ground advantage on team
-- performance and identify strategies to maximize this advantage for
-- RCB.
-- =========================================

select case
when v.venue_name = 'M Chinnaswamy Stadium' then 'home'
else 'away' end as match_location,
count(*) as total_matches,
sum(case when m.match_winner = 2 then 1 else 0 end) as matches_won,
sum(case when m.match_winner <> 2 then 1 else 0 end) as matches_lost,
round(
sum(case when m.match_winner = 2 then 1 else 0 end) * 100.0 / count(*),
2) as win_percentage
from matches as m
join venue as v on m.venue_id = v.venue_id
where m.team_1 = 2
or m.team_2 = 2
group by case
when v.venue_name = 'M Chinnaswamy Stadium'
then 'home' else 'away' end;

-- =========================================
-- Question 9
-- Come up with a visual and analytical analysis of the RCB's past
-- season's performance and potential reasons for them not winning
-- a trophy
-- =========================================

with rcb_matches as (select
match_id, season_id, match_winner
from matches where team_1 = 2
or team_2 = 2),
match_stats as (select season_id,
count(*) as total_matches,
sum(case when match_winner = 2 then 1 else 0 end) as matches_won,
sum(case when match_winner <> 2 then 1 else 0 end) as matches_lost
from rcb_matches group by season_id),
run_stats as (select rm.season_id,
sum(bb.runs_scored) as total_runs
from rcb_matches as rm
join ball_by_ball as bb
on rm.match_id = bb.match_id
group by rm.season_id)
select s.season_year, ms.total_matches,
ms.matches_won, ms.matches_lost,
round(ms.matches_won * 100.0 / ms.total_matches, 2) as 
win_percentage, rs.total_runs,
round(rs.total_runs * 1.0 / ms.total_matches, 2) as avg_runs_per_match
from match_stats as ms
join run_stats as rs
on ms.season_id = rs.season_id
join season as s
on ms.season_id = s.season_id
order by s.season_year;

-- =========================================
-- Question 10
-- How would you approach this problem, if the objective and
-- subjective questions weren't given?
-- =========================================
-- NA
-- =========================================
-- Question 11
-- In the "Match" table, some entries in the "Opponent_Team" column
-- are incorrectly spelled as "Delhi_Capitals" instead of
-- "Delhi_Daredevils". Write an SQL query to replace all occurrences
-- of "Delhi_Capitals" with "Delhi_Daredevils".
-- =========================================
-- NA
-- =========================================



