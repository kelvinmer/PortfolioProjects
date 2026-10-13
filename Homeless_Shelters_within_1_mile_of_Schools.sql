select *
from projects..HomelessSheltersinLosAngeles
order by 3,4



select *
from projects..SchoolsinLosAngeles
order by 3,4


--selecting useful columns 
select [Address Line 1], Category2,Name,State,Latitude,Longitude,x,y,zipcode
from projects..SchoolsinLosAngeles
order by 1,2

SELECT
[Address Line 1],
Category2,
Name,
State,
Latitude,
Longitude,
x,
y,
zipcode
INTO projects.dbo.SchoolsinLosAngeles_Cleaned
FROM projects.dbo.SchoolsinLosAngeles;

select addrln1, Name,city,state,latitude,longitude, zip
from projects..HomelessSheltersinLosAngeles
order by 1,2

SELECT
addrln1,
Name,
city,
state,
latitude,
longitude,
zip
INTO projects.dbo.HomelessSheltersinLosAngeles_Cleaned
FROM projects.dbo.HomelessSheltersinLosAngeles;

--standardize text based location
ALTER TABLE HomelessSheltersinLosAngeles
ALTER COLUMN zip VARCHAR(5);
ALTER TABLE projects.dbo.SchoolsinLosAngeles 
ALTER COLUMN zip VARCHAR(5);


SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'SchoolsinLosAngeles'
  AND COLUMN_NAME = 'zip';
  --Find any zip codes greater than 5 characters 
  SELECT zip 
  FROM dbo.SchoolsinLosAngeles
  WHERE LEN(LTRIM(RTRIM(CAST(zip as VARCHAR)))) > 5;

  USE projects;
  GO

  ALTER TABLE dbo.SchoolsinLosAngeles
  add zipcode Nvarchar(255);


  UPDATE dbo.SchoolsinLosAngeles
  SET zipcode = SUBSTRING(zip, 1, charindex('-',zip) -1 )
  where CHARINDEX('-', zip) >0;
  --Made the 
  --- Case statement to check the zip code contains dash and if not then keep orginal zip code.
  update dbo.SchoolsinLosAngeles
  SET zipcode = CASE
  WHEN CHARINDEX('-',zip) > 0
  THEN SUBSTRING(zip, 1, CHARINDEX('-',zip) -1)
  WHEN LEN(zip) = 5
  THEN zip
  ELSE zip
  END
  WHERE zip is not null;

  --Check zipcode column then drop old column.
  select zip, zipcode
  from projects..SchoolsinLosAngeles

  ALTER TABLE SchoolsinLosAngeles
  DROP COLUMN zip;
  --Double check column
 -- select zipcode
--  from projects..SchoolsinLosAngeles


---Analyze Schools by ZIP code

SELECT
zipcode,
COUNT(*) as NumberofSchools
FROM dbo.SchoolsinLosAngeles
GROUP BY zipcode
ORDER BY NumberofSchools DESC;

--
SELECT *
FROM projects..HomelessSheltersinLosAngeles_Cleaned

SELECT *
FROM projects..SchoolsinLosAngeles_Cleaned
----Calculate distance 
SELECT
h.Name as ShelterName,
h.zip as Zipcode,
s.name as SchoolName,
h.Latitude as ShelterLatitude,
h.longitude as ShelterLongitude,
s.latitude as SchoolLatitude,
s.longitude as SchoolLongitude,
3959 * ACOS(
CASE
when distance_calc > 1 then 1
when distance_calc < -1 then -1 
else distance_calc
end
) as DistanceMiles
INTO projects.dbo.shelterswithinonemileofschools
From projects.dbo.HomelessSheltersinLosAngeles_Cleaned as h
inner join projects.dbo.SchoolsinLosAngeles_Cleaned as s
on h.zip = s.zipcode 
cross apply ( 
SELECT 
Sin(radians(h.latitude)) * sin(radians(s.latitude)) 
+ COS(radians(h.latitude)) * cos(radians(s.latitude))
* cos(radians(s.longitude - h.longitude)) as distance_calc
) As d
Where h.latitude is not null
and h.longitude is not null
and s.latitude is not null
and s.longitude is not null
and 3959 * ACOS(
case 
when distance_calc > 1 then 1
when distance_calc < -1 then -1 
else distance_calc
end
) <=1
order by h.name, distanceMiles;

select*
from shelterswithinonemileofschools
