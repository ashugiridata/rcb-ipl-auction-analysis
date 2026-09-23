# RCB Player Analysis for IPL Mega Auction (SQL)

SQL analysis of IPL cricket data to support Royal Challengers Bangalore's (RCB) player selection strategy for the 2017 mega auction.

## Problem Statement
RCB wants to identify top-performing, reliable players for the 2017 mega auction — balancing on-field performance with value for money.

**Goals:**
- Identify high-performing and consistent players
- Evaluate batting, bowling, and player versatility
- Analyze team and venue performance
- Identify factors affecting match outcomes
- Develop data-driven auction strategies

## Dataset Overview
- **Matches** — 255 records covering toss results, winners, venues, and seasons
- **Seasons** — 9 seasons (2008–2016), including Orange/Purple Cap data
- **Venues** — 35 grounds across India and international locations
- **Ball_by_Ball** — 37,284+ granular delivery-level records
- **Players** — 469 players with biographic data
- **Teams** — 13 franchises

## Approach
SQL queries using joins, subqueries, and aggregations to analyze RCB's performance — team/season run totals, player consistency, venue-based trends, and batting vs. bowling strength.

## Key Findings
- RCB's performance has been inconsistent across seasons, highlighting the need for a more stable squad
- Consistent performers should be prioritized over one-season standouts
- Top-performing batsmen are crucial, but versatile all-rounders add flexibility
- Venue-specific performance should influence selection; RCB should maximize home-ground advantage while improving away form
- Bowling strength needs equal attention — batting alone isn't enough to win consistently
- Auction investments should be data-driven, combining performance, consistency, versatility, and venue suitability

## Files
- `SQL_Project_Submission By Ashutosh Giri.sql` — full set of queries
- Presentation (PPT) — problem statement, analysis, and conclusions

## Tools Used
MySQL, SQL (joins, subqueries, aggregations, information_schema)
