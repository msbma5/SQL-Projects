/*

Cleaning Data in SQL Queries

Skills Used : CONVERT, ALTER TABLE, UPDATE, ISNULL, ORDER BY, PARSENAME, SUBSTRING, CHARINDEX, LENGTH, REPLACE, COUNT, DISTINCT, CASE, ROW_NUMBER

*/

USE [Portfolio Project 1.2]

SELECT *
FROM NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------
                                               --Standardize Date Format


-- Taking a look at the SaleDate column and the converted date column
SELECT
	SaleDate,
	CONVERT(date,SaleDate) As ConvertedSaleDate
FROM NashvilleHousing


-- Editing the date into a YYYY-MM-DD format
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


--Double checking if updated.
SELECT
	SaleDate,
	SaleDateConverted
FROM NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------------
                                      --Populate Property Address data
            	-- To search for property address through similar ParcelID where property address IS NULL.


--Taking a look at the dataset
SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

-- Taking a look at where the property address is null
SELECT
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- To use Self Join and update the null values in property address
UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--To double check if there is still a NULL in property address
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


-----------------------------------------------------------------------------------------------------------------------------------
                                        --Breaking out Address Into Individual Columns (Address, City, State)


-- Taking a look at the PropertyAddress
SELECT
	PropertyAddress
FROM NashvilleHousing


--Seperating them between address and city name.
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City_Name
FROM NashvilleHousing


--Creating 2 new columns for the address and city name.
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--To double check whether the 2 new columns have been added in.
SELECT *
FROM NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------
						--Another way to break out Address into different columns is by using PARSENAME.
						                 --( A much easier and quicker way to do.)


--Taking a look at OwnerAddress
SELECT OwnerAddress
FROM NashvilleHousing


--Seperating OwnerAddress into different columns. 
SELECT
	PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3),
	PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2),
	PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)
FROM NashvilleHousing


--Creating 3 new columns for the address, city name and state.
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)


--To double check whether the 3 new columns have been added in.
SELECT *
FROM NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------------
                                     --To standardize the options and Change Y and N to Yes and No in "Sold as Vacant" field


--Looking at what options there is and how many counts of it.
SELECT 
	DISTINCT (SoldAsVacant),
	COUNT (SoldAsVacant) AS 'Number of times appeared'
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


-- Checking and comparing side by side which is Y/N and Yes/No (between a column that is origanally inside the table i.e SoldAsVacant and a new column that changes Y/N to Yes/No)
SELECT
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
		 WHEN SoldAsVacant = 'N' Then 'No'
		 ELSE SoldAsVacant
		 END
FROM NashvilleHousing


--Updating the Y/N to Yes/No
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
		 WHEN SoldAsVacant = 'N' Then 'No'
		 ELSE SoldAsVacant
		 END


--Double check if it is updated. (same code as before)
SELECT 
	DISTINCT (SoldAsVacant),
	COUNT (SoldAsVacant) AS 'Number of times appeared'
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

----------------------------------------------------------------------------------------------------------------------------------------------
                                                                           -- Removing duplicates.


-- To check for any duplicates if ParcelID, PropertyAddress, SalePrice AND LegalReference are similar.
	-- If similar, row_num should appear as 2 or more.
SELECT 
	*,
	ROW_NUMBER() OVER(
	PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		LegalReference
		ORDER BY 
			UniqueID
			) row_num
FROM NashvilleHousing
ORDER BY ParcelID


-- To single out all the row_num that appears 2 or more times.
	-- As we cannot use WHERE row_num > 1, must use CTE to search for row_num > 1
WITH RowNumCTE AS (
SELECT 
	*,
	ROW_NUMBER() OVER(
	PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		LegalReference
		ORDER BY 
			UniqueID
			) row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-- To delete these duplicates
WITH RowNumCTE AS (
SELECT 
	*,
	ROW_NUMBER() OVER(
	PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		LegalReference
		ORDER BY 
			UniqueID
			) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Run this code again to see if there any more duplicates. 
	-- Should be empty if successfull.
WITH RowNumCTE AS (
SELECT 
	*,
	ROW_NUMBER() OVER(
	PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		LegalReference
		ORDER BY 
			UniqueID
			) row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                         -- Deleting Unused Columns
									-- Take note. Deleting raw data is very uncommon and not advisable. Best to seek advice from someone before deleting.


--Looking at which columns to delete.
SELECT *
FROM NashvilleHousing

--Deleting the columns that is not needed.
ALTER TABLE NashvilleHousing
DROP COLUMN
	OwnerAddress,
	TaxDistrict,
	PropertyAddress