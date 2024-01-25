/* 

Cleaning Data in SQL Queries 

*/

select * 
From PortfolioProject1.dbo.NashvilleHousing

-------------------------------------------------------------------------------------

-- Standardize Data Format

select SaleDateConverted, Convert(date,SaleDate)
From PortfolioProject1.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;


Update NashvilleHousing
Set SaleDateConverted = Convert(date,SaleDate)





-------------------------------------------------------------------------------------

-- Populate Property Address Data

select *
From PortfolioProject1.dbo.NashvilleHousing
--where PropertyAddress is null 
Order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 


Update a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 


-------------------------------------------------------------------------------------

-- Breaking out Address into Individual Column (Address, City, State) 


select PropertyAddress
From PortfolioProject1.dbo.NashvilleHousing
--where PropertyAddress is null 
Order by ParcelID


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address

From PortfolioProject1.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add PropertySpiltAddress Nvarchar(255);


Update NashvilleHousing
Set PropertySpiltAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )


Alter Table NashvilleHousing
Add PropertySpiltCity Nvarchar(255);


Update NashvilleHousing
Set PropertySpiltCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))


select * 
From PortfolioProject1.dbo.NashvilleHousing





select OwnerAddress
From PortfolioProject1.dbo.NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From PortfolioProject1.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSpiltAddress Nvarchar(255);


Update NashvilleHousing
Set OwnerSpiltAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


Alter Table NashvilleHousing
Add OwnerSpiltCity Nvarchar(255);


Update NashvilleHousing
Set OwnerSpiltCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter Table NashvilleHousing 
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);



select * 
From PortfolioProject1.dbo.NashvilleHousing


/*
If you need to drop a column you've made do this

Alter Table NashvilleHousing
DROP COLUMN OwnersSpiltState;
*/
-------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject1.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject1.dbo.NashvilleHousing



Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End





-------------------------------------------------------------------------------------
-- Not standard practice to delete data in a database but for this instance im going to.
-- Removing Duplicates

WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER By 
					UniqueID
					) row_num

From PortfolioProject1.dbo.NashvilleHousing
--ORDER by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
ORDER by PropertyAddress

select *
From PortfolioProject1.dbo.NashvilleHousing








-------------------------------------------------------------------------------------
 
-- Delete Unused Columns

Alter Table PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN SaleDate










-------------------------------------------------------------------------------------
