/*

Cleaning Data in SQL Queries

*/


Select *
From  prj2_data_cleaning.nashville_housing_data_for_data_cleaning;

# Standardize Date Format
select SaleDate,convert(SaleDate,date) as SalesDateConverted
From prj2_data_cleaning.nashville_housing_data_for_data_cleaning;

alter table nashville_housing_data_for_data_cleaning
add Sales_Date_Cov date;

update nashville_housing_data_for_data_cleaning
set Sales_Date_Cov=convert(SaleDate,date);

select Sales_Date_Cov 
From prj2_data_cleaning.nashville_housing_data_for_data_cleaning;

-- Populate Property Address data

select Propertyaddress 
from prj2_data_cleaning.nashville_housing_data_for_data_cleaning;

select count('Propertyaddress')
from prj2_data_cleaning.nashville_housing_data_for_data_cleaning
where Propertyaddress is null;


select * 
from prj2_data_cleaning.nashville_housing_data_for_data_cleaning
order by ParcelID;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from prj2_data_cleaning.nashville_housing_data_for_data_cleaning a 
join prj2_data_cleaning.nashville_housing_data_for_data_cleaning b
on a.ParcelID=b.ParcelID
and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,COALESCE(a.PropertyAddress,b.PropertyAddress)
from prj2_data_cleaning.nashville_housing_data_for_data_cleaning a 
join prj2_data_cleaning.nashville_housing_data_for_data_cleaning b
on a.ParcelID=b.ParcelID
and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null;

UPDATE prj2_data_cleaning.nashville_housing_data_for_data_cleaning a 
JOIN prj2_data_cleaning.nashville_housing_data_for_data_cleaning b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Breaking out PropertyAddress and ownerAddress into Individual Columns (Address, City, State)

select 
substring(PropertyAddress,1,locate(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,locate(",",PropertyAddress)+1) as city
from prj2_data_cleaning.nashville_housing_data_for_data_cleaning;

desc prj2_data_cleaning.nashville_housing_data_for_data_cleaning;

alter table prj2_data_cleaning.nashville_housing_data_for_data_cleaning
drop column Property_split_addresss ,
drop column property_split_cityy;

-- Add the new columns to the table
ALTER TABLE prj2_data_cleaning.nashville_housing_data_for_data_cleaning
ADD COLUMN Property_split_address NVARCHAR(255),
ADD COLUMN property_split_city NVARCHAR(255);

-- Update the new columns with parsed address components
UPDATE prj2_data_cleaning.nashville_housing_data_for_data_cleaning
SET Property_split_address = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', 1)),
    property_split_city = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1));


select ownerAddress 
from prj2_data_cleaning.nashville_housing_data_for_data_cleaning;

alter table prj2_data_cleaning.nashville_housing_data_for_data_cleaning
drop column owner_split_address,
drop column owner_split_city ,
drop column owner_split_state;

alter table prj2_data_cleaning.nashville_housing_data_for_data_cleaning
add column owner_split_address nvarchar(255),
add column owner_split_city nvarchar(255),
add column owner_split_state nvarchar(255);  

update prj2_data_cleaning.nashville_housing_data_for_data_cleaning
set owner_split_address=trim(substring_index(ownerAddress,',',1)),
owner_split_city=trim(substring_index(substring_index(ownerAddress,',',2),',',-1)),
owner_split_state=trim(substring_index(ownerAddress,',',-1));


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct SoldAsVacant
From  prj2_data_cleaning.nashville_housing_data_for_data_cleaning;

select SoldAsVacant,
case 
when SoldAsVacant="Y" then "Yes"
when SoldAsVacant="N" then "No"
else SoldAsVacant
end 
From  prj2_data_cleaning.nashville_housing_data_for_data_cleaning;

update prj2_data_cleaning.nashville_housing_data_for_data_cleaning
set SoldAsVacant=
case 
when SoldAsVacant="Y" then "Yes"
when SoldAsVacant="N" then "No"
else SoldAsVacant
end ;

-- Remove Duplicates

SELECT *
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM prj2_data_cleaning.nashville_housing_data_for_data_cleaning
) AS RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

DELETE nh
FROM prj2_data_cleaning.nashville_housing_data_for_data_cleaning nh
JOIN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID,
                                PropertyAddress,
                                SalePrice,
                                SaleDate,
                                LegalReference
                   ORDER BY UniqueID
               ) AS row_num
        FROM prj2_data_cleaning.nashville_housing_data_for_data_cleaning
    ) AS subquery
    WHERE row_num > 1
) AS duplicates
ON nh.UniqueID = duplicates.UniqueID;


-- Delete Unused Columns

alter table prj2_data_cleaning.nashville_housing_data_for_data_cleaning
drop column OwnerAddress,
drop column  TaxDistrict, 
drop column PropertyAddress, 
drop column SaleDate;

SELECT * FROM prj2_data_cleaning.nashville_housing_data_for_data_cleaning;





















