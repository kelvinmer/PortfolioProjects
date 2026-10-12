Select * 
from projects..NashvilleHousingData

--Standardize Date Format

Select saleDateConverted, Convert(Date,SaleDate)
From projects..NashvilleHousingData

Update NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousingData
Add saleDateConverted Date;

Update NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)



--Populate Property Address data

Select *
From projects..NashvilleHousingData
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
From projects..NashvilleHousingData a
JOIN projects..NashvilleHousingData b
on a. ParcelID = b.ParcelID
AND a.[UniqueID ] <> b. [UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From projects..NashvilleHousingData a
JOIN projects..NashvilleHousingData b
on a. ParcelID = b.ParcelID
AND a.[UniqueID ] <> b. [UniqueID ]
Where a.PropertyAddress is null


--- Breaking out Address into Individual Columns (Address, City, State)

Select Propertyaddress
From projects..NashvilleHousingData
--where property address is null
-- order by ParcelID
SELECT
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1 ) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From projects..NashvilleHousingData



ALTER TABLE NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1 )



ALTER TABLE NashvilleHousingData
Add PropertySplitCity nvarchar(255);

Update NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress))




select *
From projects..NashvilleHousingData



--owner address

Select OwnerAddress
from projects..NashvilleHousingData

Select
parsename(Replace(Owneraddress,',','.'), 3),
parsename(Replace(Owneraddress,',','.') ,2),
parsename(Replace(Owneraddress,',','.'), 1)
from projects..NashvilleHousingData



ALTER TABLE NashvilleHousingData
Add OwnersplitAddress nvarchar(255);
Update NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(Replace(Owneraddress,',','.'), 3) 

ALTER TABLE NashvilleHousingData
Add OwnersplitCity nvarchar(255);
Update NashvilleHousingData
SET OwnerSplitCity = parsename(Replace(Owneraddress,',','.'), 2)


ALTER TABLE NashvilleHousingData
Add OwnersplitState nvarchar(255);
Update NashvilleHousingData
SET OwnerSplitState = parsename(Replace(Owneraddress,',','.'), 1)

Select *
from projects..NashvilleHousingData


---Change y and n to Yes and No in "sold as Vacant" field

Select Distinct(SoldasVacant), count(SoldasVacant)
from projects..NashvilleHousingData
group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE When soldasVacant = 'Y' Then 'Yes'
when soldasVacant = 'N' Then 'NO'
Else soldasvacant
end
from projects..NashvilleHousingData

Update NashvilleHousingData
SET SoldAsVacant = CASE When soldasVacant = 'Y' Then 'Yes'
when soldasVacant = 'N' Then 'NO'
Else soldasvacant
end
From projects..NashvilleHousingData


--Remove Duplicates
with rownumCTE as(
select*,
row_number() over (
partition by ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY 
UniqueID
) row_Num

From projects..NashvilleHousingData
--order by parcelID
)
select *
from rownumCTE
where row_num >1 
--order by propertyaddress

Select *
from projects..NashvilleHousingData

--Remove unused columns

select *
from projects..NashvilleHousingData

alter table projects..NashvilleHousingData
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table projects..NashvilleHousingData
drop column SaleDate

