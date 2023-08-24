--Create WA_countries Table
Create Table WA_countries(
Country Varchar,
Population Varchar,
Urban_population Varchar);

--Copy table world-data-2023 to WA_countries
Copy WA_countries From 'C:\Program Files\PostgreSQL\15\data\data_copy\world-data-2023.csv'
Delimiter ',' csv header;

Select * From WA_countries;

--Cleaning WA_countries to include only West African Countries
Delete From WA_countries Where country Not in ('Benin','Burkina Faso',
'Ivory Coast','Cape Verde','Cameroon','The Gambia','Ghana','Guinea','Guinea-Bissau','Liberia',
'Mali','Mauritania','Niger','Nigeria','Senegal','Sierra Leone','Togo');

--Alter Population and urban_population data type
Alter Table WA_countries Alter Column Population Type Int Using Population::Int;

Alter Table WA_countries Alter Column Urban_Population Type Int Using Urban_Population::Int;

--Update country table
Update WA_countries set country='Cote dIvoire(Ivory Coast)' Where country='Cote dIvoire';

Update WA_countries set country='Gambia' Where country= 'The Gambia';

--Create WA_population table
Create Table WA_population(
Country Varchar,
Year Varchar,
Population Varchar);

--Copy Western Africa to WA_population
Copy WA_population From 'C:\Program Files\PostgreSQL\15\data\data_copy\Western Africa.csv'
Delimiter ',' csv header;

Select * From WA_population;

--Cleaning WA_population to remove year where is null
Delete From WA_population where year is null;

--Alter country and year data type
Alter Table WA_population Alter Column Population Type Int Using Population::Int;

--Update country table
Update WA_population set country='Cote dIvoire(Ivory Coast)' Where country='Cote dIvoire';

Update WA_population set country='Gambia' Where country= 'Gambia, The';

Update WA_population set country='Cape Verde' Where country= 'Cabo Verde';

--Create Malaria table
Create Table Malaria(measure_id Varchar,
					 measure_name Varchar,
					 location_id Varchar,
					 location_name Varchar,
					 sex_id Varchar,
					 sex_name Varchar,
					 age_id Varchar,
					 age_name Varchar,
					 cause_name Varchar,
					 metric_id Varchar,
					 metric_name Varchar,
					 year Varchar,
					 val Varchar,
					 upper Varchar,
					 lower Varchar);

--Copy Malaria dataset to Malaria Table
Copy Malaria From 'C:\Program Files\PostgreSQL\15\data\data_copy\malaria dataset.csv'
Delimiter ',' csv header;

select * from Malaria

--Cleaning malaria to include only West African Countries
Delete From Malaria Where location_name Not in ('Benin','Burkina Faso',
'Ivory Coast','Cape Verde','Cameroon','The Gambia','Ghana','Guinea','Guinea-Bissau','Liberia',
'Mali','Mauritania','Niger','Nigeria','Senegal','Sierra Leone','Togo');

--Alter Drop column
Alter Table Malaria Drop Column measure_id;
Alter Table Malaria Drop Column location_id;
Alter Table Malaria Drop Column sex_id;
Alter Table Malaria Drop Column age_id;
Alter Table Malaria Drop Column metric_id;

--Cleaning malaria to include only death case
Delete From Malaria Where measure_name != 'Deaths'

--Cleaning malaria to include only Number case
Delete From Malaria Where metric_name != 'Number'

--Alter data type
Alter Table Malaria Alter Column val Type Numeric Using val::Numeric;
Alter Table Malaria Alter Column upper Type Numeric Using upper::Numeric;
Alter Table Malaria Alter Column lower Type Numeric Using lower::Numeric;

--Update to include year from 2015 to 2019
Delete From Malaria Where year <='2014';


--Time for Analysis
Select * from WA_countries;
Select * from WA_population;
Select * from Malaria;

/* The tropical climates in many Western African countries provides an 
enviroment conducive to the trasmission of malaria. This dataset from 2015-2019
focus on the death of Female in western African countries between the age of 15-49years*/

--Year with total death
with cte as (Select year, round(sum(val)) as total_malaria_cases from Malaria
group by year order by total_malaria_cases desc),
cte2 as (select year, round(sum(population)) as population from WA_population 
		 group by year order by population desc)
Select cte.year, cte.total_malaria_cases, cte2.population from cte inner join cte2 using(year)
order by total_malaria_cases desc
/* The analysis show that 2019 had the highest malaria cases. UNICEF and other orgiantions
in their malaria article state that covid 19 was the cause of the increase. It is surprising
that total malaria death cases is lower in 2017. More research should be carried out on why*/

-- Total death in each country
Select location_name,cast(sum(val) as int) as total from Malaria group by location_name order by total desc
/* from this analysis out of 14 West African countries, is can be see that Nigeria have 
the highest number(67739) of death malaria cases with a 58857 gap from thesecond highest 
country which is Ghana with 8882.*/

--Total death affect population of countries
Select m.location_name,round((sum(p.population)-sum(m.val))) as remaining,
sum(p.population) as population, cast(sum(val) as int) as total
from WA_population as p
inner join Malaria as m on m.location_name=p.country group by 
location_name order by remaining desc
/* From the analysis, it can be seen that Nigeria even with high death malaria cases from 2016-
2019 still have a high population*/

--Coutries in 2019 with total malaria death cases
Select year, location_name, round(sum(val)) as total from malaria where year='2019'
group by location_name,year order by total desc
/* From the data, we can see that Nigeria had the highest malaria death case with Guinea-Bissau
being the lowest*/

--Total, average and median malaria female death cases
Select round(sum(val)) as total, round(avg(val))as average, 
round(percentile_cont(0.5) within group(order by val)) as median from malaria
