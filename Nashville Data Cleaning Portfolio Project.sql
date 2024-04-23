--Script to Explore the First 1000 rows of This Large Dataset
SELECT TOP (1000) *
FROM PortfolioProject..NashvilleHousing

--Standardzing Date Format

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Checking to See if Standardization took Effect
SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing

-- Populating Empty Property Address Data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--Separating PropertyAddress Into Individual Columns (Address, City)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD StreetAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD CityAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET CityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--Checking to See if Address was Separated Successfully
SELECT StreetAddress, CityAddress
FROM PortfolioProject..NashvilleHousing

--Separating OwnerAddress Into Individual Columns (Address, City, State)
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerStreetAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerCityAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

ALTER TABLE NashvilleHousing
ADD OwnerStateAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerStateAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

--Checking to See if Address was Separated Successfully
SELECT OwnerAddress, OwnerStreetAddress, OwnerCityAddress, OwnerStateAddress
FROM PortfolioProject..NashvilleHousing

--Change '0' and '1' to 'Yes' and 'No' in "Sold Vacant" field
SELECT CAST(SoldAsVacant AS VARCHAR),
	CASE WHEN CAST(SoldAsVacant AS VARCHAR) = '0' THEN 'Yes'
	WHEN CAST(SoldAsVacant AS VARCHAR) = '1' THEN 'No'
	ELSE CAST(SoldAsVacant AS VARCHAR)
	END
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SoldVacant VARCHAR(255)

UPDATE NashvilleHousing
SET SoldVacant = CASE WHEN CAST(SoldAsVacant AS VARCHAR) = '0' THEN 'Yes'
	WHEN CAST(SoldAsVacant AS VARCHAR) = '1' THEN 'No'
	ELSE CAST(SoldAsVacant AS VARCHAR)
	END
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN SoldAsVacant

--Checking to See if 'SoldVacant' Column was added
SELECT SoldAsVacant, SoldVacant
FROM PortfolioProject..NashvilleHousing

SELECT SoldVacant, COUNT(SoldVacant) AS Total
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldVacant
ORDER BY 2 DESC

--Removing Duplicate From Data

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
	PropertyAddress, 
	SalePrice, 
	SaleDate, 
	LegalReference
	ORDER BY UniqueID
	) row_num


FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Deleting Other Unused Columns
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SoldAsVacant
--Checking to See if Unused Columns were Dropped
SELECT OwnerAddress, TaxDistrict, PropertyAddress, SoldAsVacant
FROM PortfolioProject..NashvilleHousing
--Received an Syntax Error confirming Dropped Columns no longer exists