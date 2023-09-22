
--Cleaning Data in SQL Queries


Select * 
From PortfolioProject2.dbo.NashvilleHousing

--Standarize Date Format

Select SaleDate, CONVERT(Date,Saledate)
From PortfolioProject2.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,Saledate) 

-- Does not work the last query, so I create a new column and add the converted date there

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,Saledate) 

Select SaleDateConverted, CONVERT(Date,Saledate)
From PortfolioProject2.dbo.NashvilleHousing

-- Populate Property Address data

Select PropertyAddress 
From PortfolioProject2.dbo.NashvilleHousing
Where PropertyAddress is null



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject2.dbo.NashvilleHousing a 
JOIN PortfolioProject2.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject2.dbo.NashvilleHousing a 
JOIN PortfolioProject2.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--Breaking out Address into Individual Columns (address, City, State)

-- Property Address

Select PropertyAddress
FROM PortfolioProject2.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,Len(PropertyAddress)) as City
FROM PortfolioProject2.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255) ;

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,Len(PropertyAddress))

Select * 
FROM PortfolioProject2.dbo.NashvilleHousing


-- Owner Address

Select OwnerAddress
FROM PortfolioProject2.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress,',','.'), 1),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 3)
FROM PortfolioProject2.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

Select * 
FROM PortfolioProject2.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct SoldAsVacant, Count(SoldAsVacant)
FROM PortfolioProject2.dbo.NashvilleHousing
Group by SoldAsVacant
order By 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END
FROM PortfolioProject2.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END


Select Distinct SoldAsVacant, Count(SoldAsVacant)
FROM PortfolioProject2.dbo.NashvilleHousing
Group by SoldAsVacant
order By 2

--Remove Duplicates (not recommended)

WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject2.dbo.NashvilleHousing
)
Select *
FROM RowNumCTE
where row_num > 1

-- Delete Unused Columns

Select * 
FROM PortfolioProject2.dbo.NashvilleHousing

Alter TABLE PortfolioProject2.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress

Alter TABLE PortfolioProject2.dbo.NashvilleHousing
DROP COLUMN SaleDate