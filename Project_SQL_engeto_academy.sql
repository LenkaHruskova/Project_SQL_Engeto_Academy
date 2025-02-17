--náhled na potřebná data a propojení tabulek--
select *
from czechia_price cp 
join czechia_price_category cpc on cp.category_code = cpc.code
join czechia_payroll cp2 on date_part('year', cp.date_from) = cp2.payroll_year 
join czechia_payroll_industry_branch cpib on cp2.industry_branch_code = cpib.code ;


--vytvoření robustní datové tabulky s potřebnými informacemi pro projekt--
create table t_lenka_hruskova_project_SQL_primary_final as
select 
 cp.id, 
 cp2.value as prumerna_mzda,
 cp2.value_type_code as jednotky_mzdy,
 cpib.name as odvetvi_prumyslu,
 cpib.code as kod_odvetvi,
 cp2.payroll_year as rok,
 cpc.code as kod_potraviny,
 cpc.name as kategorie_potravin,
 cpc.price_value as mnozstvi,
 cpc.price_unit as jednotky_mnozstvi,
 cp.value as cena,
 TO_CHAR(cp.date_from, 'DD.MM.YYYY') AS cena_zaznamenana_od,
 TO_CHAR(cp.date_to, 'DD.MM.YYYY') AS cena_zaznamenana_do,
 cp.region_code as region
from czechia_price cp 
join czechia_price_category cpc on cp.category_code = cpc.code
join czechia_payroll cp2 on date_part('year', cp.date_from) = cp2.payroll_year 
join czechia_payroll_industry_branch cpib on cp2.industry_branch_code = cpib.code 
where cp2.value_type_code = 5958
and cp.region_code is null ;




--Výzkumná otázka č. 1--
--Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesaji?--

--celkový průměr za všechna odvětví--
with cte_prumerny_vyvoj_mezd as (
select
rok,
AVG(prumerna_mzda),
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
group by rok)
select 
rok,
v_procentech,
trend
from cte_prumerny_vyvoj_mezd
where v_procentech is not null;

--náhled na jednotlivá odvětví v tabulce--
select distinct odvetvi_prumyslu, kod_odvetvi 
from t_lenka_hruskova_project_sql_primary_final tlhpspf 
order by kod_odvetvi ;


--odvětví A Zemědělství, lesnictví a rybářství--
with cte_prumer_A as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'A'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_A
where avg_mzda_predchozi_rok is not null
order by rozdil asc ;

--odvětví B Těžba a dobývání--
with cte_prumer_B as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'B'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_B
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;


--odvětví C Zpracovatelský průmysl--
with cte_prumer_C as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'C'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_C
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;


--odvětví D Výroba a rozvod elektřiny, plynu, tepla a klimatizovaného vzduchu--
with cte_prumer_D as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'D'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_D
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;

--odvětví E Zásobování vodou, činnnosti související s odpady a sanacemi--
with cte_prumer_E as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'E'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_E
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;

--odvětví F Stavebnictví--
with cte_prumer_F as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'F'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_F
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;

--odvětví G Velkoobchod a maloobchod, opravy a údržba motorových vozidel--
with cte_prumer_G as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'G'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_G
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;

--odvětví H Doprava a skladování--
with cte_prumer_H as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'H'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_H
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;

--odvětví I Ubytování, stravování a pohostinství--
with cte_prumer_I as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'I'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_I
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;

--odvětví J Informační a komunikační činnosti--
with cte_prumer_J as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'J'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_J
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;

--odvětví K Peněžníctví a pojišťovnictví--
with cte_prumer_K as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'K'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_K
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;

--odvětví L Činnosti v oblasti nemovitostí--
with cte_prumer_L as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'L'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_L
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;

--odvětví M Profesní, věděcké a technické činnosti--
with cte_prumer_M as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'M'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_M
where avg_mzda_predchozi_rok is not null
order by rozdil asc ;

--odvětví N Administrativní a podpůrné činnosti--
with cte_prumer_N as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'N'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_N
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;

--odvětví O Veřejná správa a obrana, povinné sociální zabezpečení
with cte_prumer_O as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'O'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_O
where avg_mzda_predchozi_rok is not null
order by rozdil asc ;

--odvětví P Vzdělávání--
with cte_prumer_P as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'P'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_P
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;

--odvětví Q Zdravotní a sociální péče--
with cte_prumer_Q as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'Q'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_Q
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;

--odvětví R Kulturní, zábavní a rekreační činnosti--
with cte_prumer_R as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'R'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_R
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;

--odvětví S Ostatní činnosti--
with cte_prumer_S as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
where kod_odvetvi = 'S'
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_S
where avg_mzda_predchozi_rok is not null 
order by rozdil asc ;

--souhrnný přehled pro všechna jednotlivá odvětví ve sledovaném období--
with cte_prumer_vse as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by odvetvi_prumyslu, rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by odvetvi_prumyslu, rok)) as rozdil,
ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok) AS NUMERIC), 2) || ' %' AS v_procentech,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by odvetvi_prumyslu, rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
group by rok, odvetvi_prumyslu)
select *
from cte_prumer_vse
where rok != '2006';

--zobrazení jen dat, která potřebujeme--
WITH cte_prumer_vse AS (
    SELECT 
        AVG(prumerna_mzda) AS avg_mzda, 
        LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok) AS avg_mzda_predchozi_rok,
        rok,
        odvetvi_prumyslu,
        (AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok)) AS rozdil,
        ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok) AS NUMERIC), 2) || ' %' AS v_procentech,
        CASE 
            WHEN AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok) > 0 
            THEN 'roste' 
            ELSE 'klesá' 
        END AS trend
    FROM t_lenka_hruskova_project_SQL_primary_final
    GROUP BY rok, odvetvi_prumyslu
)
SELECT 
 rok,
 odvetvi_prumyslu,
 v_procentech,
 trend
FROM cte_prumer_vse
WHERE rok != '2006';

--zobrazení 5 nejvyšších procentuálních nárustů mezd průřezově v jednotlivých letech a v jednotlivých odvětvích--
WITH cte_prumer_vse AS (
    SELECT 
        AVG(prumerna_mzda) AS avg_mzda, 
        LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok) AS avg_mzda_predchozi_rok,
        rok,
        odvetvi_prumyslu,
        (AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok)) AS rozdil,
        ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok)) * 100) / 
            LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok) AS NUMERIC), 2) || ' %' AS v_procentech,
        CASE 
            WHEN AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok) > 0 
            THEN 'roste' 
            ELSE 'klesá' 
        END AS trend
    FROM t_lenka_hruskova_project_SQL_primary_final
    GROUP BY rok, odvetvi_prumyslu
)
SELECT 
 rok,
 odvetvi_prumyslu,
 v_procentech
FROM cte_prumer_vse
WHERE rok != '2006'
order by v_procentech desc 
limit 5;

--zobrazení 5 nejvetších procentuálních poklesů mezd průřezově v jednotlivých letech pro jednotlivá odvětví--
WITH cte_prumer_vse AS (
    SELECT 
        AVG(prumerna_mzda) AS avg_mzda, 
        LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok) AS avg_mzda_predchozi_rok,
        rok,
        odvetvi_prumyslu,
        (AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok)) AS rozdil,
        CASE 
            WHEN ((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok)) * 100) / 
                 LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok) < 0 
            THEN ROUND(CAST(((AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok)) * 100) / 
                 LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok) AS NUMERIC), 2) || ' %'
            ELSE NULL 
        END AS v_procentech,
        CASE 
            WHEN AVG(prumerna_mzda) - LAG(AVG(prumerna_mzda)) OVER (ORDER BY odvetvi_prumyslu, rok) > 0 
            THEN 'roste' 
            ELSE 'klesá' 
        END AS trend
    FROM t_lenka_hruskova_project_SQL_primary_final
    GROUP BY rok, odvetvi_prumyslu
)
SELECT 
rok,
odvetvi_prumyslu,
v_procentech
FROM cte_prumer_vse
WHERE rok != '2006'
and v_procentech is not null
order by v_procentech desc
limit 5;


-----------------
-- Otázka č. 2 Kolik je možné koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?--

select *
from t_lenka_hruskova_project_sql_primary_final tlhpspf ;


create or replace view v_prumerne_ceny_za_tydny as ( 
WITH prumerne_ceny AS (
   						 -- Výpočet průměrné roční ceny pro mléko a chléb, rozdělení na jednotlivé týdny stále--
   SELECT 
        EXTRACT(YEAR FROM TO_DATE(cena_zaznamenana_od, 'DD.MM.YYYY'))  AS rok_ceny,
        kod_potraviny,
        AVG(cena) AS prumerna_cena,
        jednotky_mnozstvi
    FROM t_lenka_hruskova_project_sql_primary_final tlhpspf 
    WHERE kod_potraviny IN ('114201', '111301')
    GROUP BY EXTRACT(YEAR FROM TO_DATE(cena_zaznamenana_od, 'DD.MM.YYYY')), kod_potraviny, jednotky_mnozstvi
),
mzdy AS (
   				 		-- Výběr průměrné mzdy pouze pro roky 2006 a 2018
    SELECT 
        rok,
        prumerna_mzda
    FROM t_lenka_hruskova_project_sql_primary_final tlhpspf 
    WHERE rok IN ('2006', '2018')
    GROUP BY rok, prumerna_mzda
)
SELECT 
    m.rok, 
    c.kod_potraviny, 
    m.prumerna_mzda / c.prumerna_cena AS mnozstvi_k_koupi, 
    c.jednotky_mnozstvi
FROM mzdy m
JOIN prumerne_ceny c ON m.rok = c.rok_ceny
ORDER BY m.rok, c.kod_potraviny 
);


select *
from v_prumerne_ceny_za_tydny ;


--vytvoření průměrného množství jednotlivých kategorií za celý rok, aby bylo možné porovnat s průměrnými mzdami za tytéž roky--

create or replace view v_vysledek_2 as (
SELECT 
    rok,
    kod_potraviny,
    AVG(mnozstvi_k_koupi) AS prumerne_mnozstvi,
    jednotky_mnozstvi
FROM v_prumerne_ceny_za_tydny
WHERE rok IN (2006, 2018) and kod_potraviny in (111301, 114201)
GROUP BY rok, kod_potraviny, jednotky_mnozstvi
ORDER BY rok);

select *
from v_vysledek_2 ;

-----přidání názvu kategorie a zaokrouhlení na celé číslo pro lepší orientaci ve výsledku--
SELECT 
    rok,
    ROUND(prumerne_mnozstvi) AS prumerne_mnozstvi,
    jednotky_mnozstvi,
    cpc.name
FROM v_vysledek_2 v
JOIN czechia_price_category cpc ON v.kod_potraviny = cpc.code;



--------
--Otázka č. 3 Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?--

select *
from t_lenka_hruskova_project_sql_primary_final tlhpspf ;

--vytvoření základního pohledu na tabulku průměrných cen jednotlivých kategorií po jednotlivých letech---
create or replace view v_komplet_rozdily as (
with cte_tydenni_avg_ceny as ( 
select 
 kod_potraviny,
 kategorie_potravin,
 cena,
 EXTRACT(YEAR FROM TO_DATE(cena_zaznamenana_od, 'DD.MM.YYYY')) AS rok
from t_lenka_hruskova_project_sql_primary_final tlhpspf 
group by kategorie_potravin, kod_potraviny,  EXTRACT(YEAR FROM TO_DATE(cena_zaznamenana_od, 'DD.MM.YYYY')), cena)
select 
 kod_potraviny,
kategorie_potravin,
avg(cena) as prumerna_cena,
lag(avg(cena)) over (order by kategorie_potravin, rok) as predchozi_prumerna_cena,
rok,
((avg(cena) - lag(avg(cena)) over (order by kategorie_potravin, rok)) * 100) / lag(avg(cena)) over (order by kategorie_potravin, rok) as procentualni_rozdil
from t_lenka_hruskova_project_sql_primary_final tlhpspf 
group by rok, kod_potraviny, kategorie_potravin
order by kategorie_potravin, rok);

select *
from v_komplet_rozdily;

--očištění od roku 2006, který je počáteční, a tím pádem není relevantní pro meziroční porovnávání--

select 
kod_potraviny,
kategorie_potravin,
prumerna_cena,
predchozi_prumerna_cena,
rok,
procentualni_rozdil
from v_komplet_rozdily
where rok != '2006';

--seřazení podle nejnizšího procentuálního rozdílu = 5 kategorií potravin, které ve sledovaných letech slevňovaly--
select 
kategorie_potravin,
rok,
round(cast(procentualni_rozdil as numeric), 2) as procentualni_rozdil 
from v_komplet_rozdily
where rok != '2006'
order by procentualni_rozdil asc 
limit 5;
 
----zobrazení 5 nejpomaleji zdražujících kategorií potravin v letech 2007–2018--
select 
kategorie_potravin,
rok,
round(cast(procentualni_rozdil as numeric), 2) as procentualni_rozdil 
from v_komplet_rozdily
where rok != '2006' and procentualni_rozdil >= 0
order by procentualni_rozdil asc 
limit 5;

---vytvoření průměru zdražování jednotlivých kategorií za období 2007–2019--

SELECT 
    kategorie_potravin,
    round(cast(AVG(procentualni_rozdil) as numeric), 2) AS prumerna_mezirocni_zmena
FROM v_komplet_rozdily
WHERE rok BETWEEN 2007 AND 2018
GROUP BY kategorie_potravin
ORDER BY prumerna_mezirocni_zmena ASC;


--u vína jakostního vyšel nezvykle velký meziroční nárust, proto se na tuto kategorii podíváme blíže--

select 
kod_potraviny,
kategorie_potravin,
prumerna_cena,
predchozi_prumerna_cena,
rok,
procentualni_rozdil
from v_komplet_rozdily
where rok != '2006' and kod_potraviny = '212101' ;

---očistímě tuto kategorii o rok 2015, protože její sledování začíná právě v tomto roce, proto není relevantní pro další výpočty--

select 
kod_potraviny,
kategorie_potravin,
prumerna_cena,
predchozi_prumerna_cena,
rok,
procentualni_rozdil
from v_komplet_rozdily
where rok != '2015' and kod_potraviny = '212101' ;

--zobrazíme 5 nejpomaleji zdražující potraviny znovu jen v období, kdy byly sledovány všechny kategorie, tj. 2016–2018--
SELECT 
    kategorie_potravin,
    ROUND(CAST(AVG(procentualni_rozdil) AS NUMERIC), 2) AS prumerna_mezirocni_zmena
FROM v_komplet_rozdily
WHERE rok BETWEEN 2016 AND 2018 
GROUP BY kategorie_potravin
HAVING AVG(procentualni_rozdil) >= 0 
ORDER BY prumerna_mezirocni_zmena asc
limit 5;



-----------------------
--Otázka č. 4 Existuje rok, ve kterém byl meziroční nárust cen potravin výrazně vyšší než růst mezd (větší než 10%)?--
--pro potřeby výpočtů očistíme analýzu o data z roku 2006, kdy sledování cen a mezd začalo, a proto nemůžeme učit výši meziročního růstu--


--první si vytvoříme průměrný růst mezd celkově pro jednotlivé roky--
create or replace view v_rust_mezd_celkove as ( 
with cte_prumer_vse as (
select 
AVG(prumerna_mzda) as avg_mzda, 
lag(avg(prumerna_mzda)) over (order by odvetvi_prumyslu, rok) as avg_mzda_predchozi_rok,
rok ,
odvetvi_prumyslu ,
(AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by odvetvi_prumyslu, rok)) as rozdil,
((AVG(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by odvetvi_prumyslu, rok)) * 100) / lag(avg(prumerna_mzda)) over (order by rok) as v_procentech ,
case when avg(prumerna_mzda) - lag(avg(prumerna_mzda)) over (order by odvetvi_prumyslu, rok) > 0 then 'roste' else 'klesá' end as trend
from t_lenka_hruskova_project_SQL_primary_final
group by odvetvi_prumyslu, rok 
order by odvetvi_prumyslu, rok)
select *
from cte_prumer_vse
where rok != 2006
order by odvetvi_prumyslu, rok asc );

select *
from v_rust_mezd_celkove ;

select 
AVG(v_procentech) as rocni_procentualni_rust,
rok
from v_rust_mezd_celkove
group by rok;

----přidáme výpočet průměrného meziročního růstu potravin (mimo vína bílého jakostního, protože vývoj ceny nebyl sledován celou dobu), 
--napojíme na sebe a vypočítáme rozdíl--

create or replace view v_rozdil_rustu_cen_a_mezd as ( 
WITH mezirocni_rust_cen AS (
    SELECT 
        rok,
        AVG(procentualni_rozdil) AS prumerna_mezirocni_zmena_cen
    FROM v_komplet_rozdily
    WHERE rok BETWEEN 2007 AND 2018
      AND kod_potraviny != '212101' 
    GROUP BY rok),
  mezirocni_rust_mezd as (select 
AVG(v_procentech) as rocni_procentualni_rust_mezd,
rok
from v_rust_mezd_celkove
group by rok)
SELECT 
    mrc.rok,
    mrc.prumerna_mezirocni_zmena_cen,
    mrm.rocni_procentualni_rust_mezd,
    (mrc.prumerna_mezirocni_zmena_cen - mrm.rocni_procentualni_rust_mezd) AS rozdil
FROM mezirocni_rust_cen mrc
JOIN mezirocni_rust_mezd mrm ON mrc.rok = mrm.rok
ORDER BY rozdil desc );

--výpočet, zda byl v některém roce nárust cen oproti nárustu mezd vyšší než 10 %--
select *
from v_rozdil_rustu_cen_a_mezd 
WHERE (prumerna_mezirocni_zmena_cen - rocni_procentualni_rust_mezd) > 10;

select 
rok,
round(cast(prumerna_mezirocni_zmena_cen as numeric), 2) as prumerna_mezirocni_zmena_cen,
round(cast(rocni_procentualni_rust_mezd as numeric), 2) as rocni_procentualni_rust_mezd,
round(cast(rozdil as numeric), 2) as rozdil 
from v_rozdil_rustu_cen_a_mezd 
limit 3;

--očistíme o roky, kdy mzdy nebo ceny klesaly--
create or replace view v_rozdil_rustu_cen_a_mezd_bez_minusovych as ( 
WITH mezirocni_rust_cen AS (
    SELECT 
        rok,
        AVG(procentualni_rozdil) AS prumerna_mezirocni_zmena_cen
    FROM v_komplet_rozdily
    WHERE rok BETWEEN 2007 AND 2018
      AND kod_potraviny != '212101' 
    GROUP BY rok),
  mezirocni_rust_mezd as (select 
AVG(v_procentech) as rocni_procentualni_rust_mezd,
rok
from v_rust_mezd_celkove
group by rok)
SELECT 
    mrc.rok,
    mrc.prumerna_mezirocni_zmena_cen,
    mrm.rocni_procentualni_rust_mezd,
    (mrc.prumerna_mezirocni_zmena_cen - mrm.rocni_procentualni_rust_mezd) AS rozdil
FROM mezirocni_rust_cen mrc
JOIN mezirocni_rust_mezd mrm ON mrc.rok = mrm.rok
where prumerna_mezirocni_zmena_cen >= 0
and rocni_procentualni_rust_mezd >= 0
ORDER BY rozdil desc);

--byl v těchto o mínusová vstupní data očistěných rozdílech rozdíl větší než 10 %?--
select *
from v_rozdil_rustu_cen_a_mezd_bez_minusovych 
WHERE (prumerna_mezirocni_zmena_cen - rocni_procentualni_rust_mezd) > 10;

--3 nejvetší rozdíly mezi nárusty cen a mezd v jednotlivých letech očistěné od let s poklesy cen či mezd--
select 
rok,
round(cast(prumerna_mezirocni_zmena_cen as numeric), 2) as prumerna_mezirocni_zmena_cen,
round(cast(rocni_procentualni_rust_mezd as numeric), 2) as rocni_procentualni_rust_mezd,
round(cast(rozdil as numeric), 2) as rozdil 
from v_rozdil_rustu_cen_a_mezd_bez_minusovych 
limit 3;


--------------------
--Otázka č. 5 Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP
--vzroste výrazneji v jednom roce, projeví se to i na cenách potravin či mzdách ve stejném nebo 
--následujícím roce výraznejším růstem?

--vytvoření pohledu na vývoj hdp v ČR v letech, která jsou relevantní pro porovnání--
create or replace view v_gdp_rozdil_cesko as ( 
with cte_rozdil_gdp as ( 
select 
 country,
 year,
 gdp,
 lag (gdp) over (order by year) as gdp_pre_year,
 (gdp -  lag (gdp) over (order by year)) as rozdil_gdp,
 ((gdp -  lag (gdp) over (order by year)) * 100) /  lag (gdp) over (order by year) as procentualni_rozdil
from economies e 
where country = 'Czech Republic'
 and year between 2006 and 2018)
select 
 year,
 rozdil_gdp,
 procentualni_rozdil
from cte_rozdil_gdp
where year between 2007 and 2018);

select 
 rok,
 prumerna_mezirocni_zmena_cen,
 rocni_procentualni_rust_mezd,
 V_gdp_rozdil_cesko.procentualni_rozdil
from v_rozdil_rustu_cen_a_mezd v 
join v_gdp_rozdil_cesko  on v_gdp_rozdil_cesko.year = v.rok
order by rok;

--zaokrouhlíme na dvě desetinná místa--
SELECT 
    rok,
    ROUND(CAST(prumerna_mezirocni_zmena_cen AS NUMERIC), 2) || ' %' AS prumerna_mezirocni_zmena_cen,
    ROUND(CAST(rocni_procentualni_rust_mezd AS NUMERIC), 2) || ' %' AS rocni_procentualni_rust_mezd,
    ROUND(CAST(V_gdp_rozdil_cesko.procentualni_rozdil AS NUMERIC), 2) || ' %' AS procentualni_rozdil_HDP
FROM v_rozdil_rustu_cen_a_mezd v 
JOIN v_gdp_rozdil_cesko ON v_gdp_rozdil_cesko.year = v.rok
ORDER by rok;

--vytvoření tabulky pro dodatečná data o dalších evropských státech--
create table t_lenka_hruskova_project_sql_secondary_final as
select 
 c.country,
 c.continent,
 c.population,
 e.gdp,
 e.gini,
 e.taxes,
 e.year
 from countries c 
 join economies e on c.country = e.country 
 where continent = 'Europe'
and year between 2006 and 2018
order by country, year;

select *
from t_lenka_hruskova_project_sql_secondary_final;

---vyzkouším poslední otázku vyhodnotit na druhé vytvořené tabulce--
create or replace view v_gdp_rozdil_cr as ( 
with cte_rozdil_gdp_cr as ( 
select 
 country,
 year,
 gdp,
 lag (gdp) over (order by year) as gdp_pre_year,
 (gdp -  lag (gdp) over (order by year)) as rozdil_gdp,
 ((gdp -  lag (gdp) over (order by year)) * 100) /  lag (gdp) over (order by year) as procentualni_rozdil
from t_lenka_hruskova_project_sql_secondary_final 
where country = 'Czech Republic'
 and year between 2006 and 2018)
select 
 year,
 rozdil_gdp,
 procentualni_rozdil
from cte_rozdil_gdp_cr
where year between 2007 and 2018);

select 
 rok,
 prumerna_mezirocni_zmena_cen,
 rocni_procentualni_rust_mezd,
 V_gdp_rozdil_cr.procentualni_rozdil
from v_rozdil_rustu_cen_a_mezd v 
join v_gdp_rozdil_cr  on v_gdp_rozdil_cr.year = v.rok
order by rok;

SELECT 
    rok,
    ROUND(CAST(prumerna_mezirocni_zmena_cen AS NUMERIC), 2) || ' %' AS prumerna_mezirocni_zmena_cen,
    ROUND(CAST(rocni_procentualni_rust_mezd AS NUMERIC), 2) || ' %' AS rocni_procentualni_rust_mezd,
    ROUND(CAST(V_gdp_rozdil_cr.procentualni_rozdil AS NUMERIC), 2) || ' %' AS procentualni_rozdil_HDP
FROM v_rozdil_rustu_cen_a_mezd v 
JOIN v_gdp_rozdil_cr ON v_gdp_rozdil_cr.year = v.rok
ORDER by rok;

---funguje a výsledky jsou stejné, jako když jsem používala přímo tabulku economies--



