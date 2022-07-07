--Cleaning data in sql
Select *
From portfolioproject.dbo.Nashvillehousing		


Select SaleDate,CONVERT(Date,SaleDate)
From portfolioproject.dbo.Nashvillehousing		



--Standardise date format
		
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDate,CONVERT(Date,SaleDate)
From portfolioproject.dbo.Nashvillehousing	




--Populate Property address data where data is null
Select *
From portfolioproject..Nashvillehousing		
--where PropertyAddress is nullby 
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolioproject..Nashvillehousing	a
Join portfolioproject..Nashvillehousing b
	on a.ParcelID= b.ParcelID
	And a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolioproject..Nashvillehousing	a
Join portfolioproject..Nashvillehousing b
	on a.ParcelID= b.ParcelID
	And a.[UniqueID ]<> b.[UniqueID ]
	
--Breaking out address into individual columns (Address, City, State)
Select PropertyAddress
From portfolioproject..Nashvillehousing		
--where PropertyAddress is nullby 
--order by ParcelID

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, Len(PropertyAddress)) as address
From portfolioproject..Nashvillehousing

Alter table Nashvillehousing
Add  PropertySplitAddress  Nvarchar(255);
Update Nashvillehousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)


Alter table Nashvillehousing
Add  PropertySplitCity Nvarchar(255);
Update Nashvillehousing
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress))

Select *
From portfolioproject..Nashvillehousing	

Select OwnerAddress
From portfolioproject..Nashvillehousing	

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From portfolioproject..Nashvillehousing	


Alter table Nashvillehousing
Add  OwnerSplitAddress  Nvarchar(255);

Update Nashvillehousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

Alter table Nashvillehousing
Add  OwnerSplitCity Nvarchar(255);

Update Nashvillehousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)



Alter table Nashvillehousing
Add  OwnerSplitState  Nvarchar(255);

Update Nashvillehousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

Select *
from portfolioproject..Nashvillehousing



--Change Y and N to Yes and No in "Sold as vacant" field
Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from portfolioproject..Nashvillehousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
       Else SoldAsVacant
	   End
from portfolioproject..Nashvillehousing

Update Nashvillehousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
       Else SoldAsVacant
	   End


--Remove duplicates

WITH RownumCTE as(
Select *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, Saledate,LegalReference ORDER BY UniqueID)row_num
From portfolioproject..Nashvillehousing
--Order by ParcelID
)
Delete
from RownumCTE
Where row_num>1


--Delete unused columns

Alter table portfolioproject..Nashvillehousing
Drop column SaleDate,OwnerAddress, TaxDistrict, PropertyAddress

Select *
from portfolioproject..Nashvillehousing

