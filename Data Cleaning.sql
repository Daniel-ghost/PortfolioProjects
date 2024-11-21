


  --CLEANING DATA 

  SELECT * 
  FROM NashvilleHousing


  --STANDARDIZE DATE FORMAT
  

 UPDATE NashvilleHousing
 SET SaleDate = (CONVERT (date, SaleDate))

 ALTER TABLE NashvilleHousing
 ADD saledateconverted date;

 UPDATE Nashvillehousing
 SET Saledateconverted = CONVERT(Date,SaleDate)

 SELECT saledate, SaleDateConverted
 FROM nashvillehousing

 --POPULATE PROPERTY ADDRESS DATA

 SELECT PropertyAddress
 FROM nashvillehousing

 --WHERE PropertyAddress is null

  
 SELECT *
 FROM nashvillehousing a JOIN NashvilleHousing b --(self join)
 ON a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ] 

 SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
 FROM nashvillehousing a JOIN NashvilleHousing b 
 ON a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ] 

 UPDATE a
 SET PropertyAddress =  isnull(a.PropertyAddress, b.PropertyAddress)
 FROM nashvillehousing a JOIN NashvilleHousing b 
 ON a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ] 
 WHERE a.PropertyAddress is null



 --BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

 
  SELECT PropertyAddress
  FROM NashvilleHousing
  --WHERE PropertyAddress is null
  --ORDER BY ParcelID


  --SUBSTRING(string, start_position, length), LEN(length of chosen string)
  SELECT PropertyAddress, 
  SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) address,
  SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) address2
  FROM NashvilleHousing


  ALTER TABLE NashvilleHousing
  ADD PropertysplitAddress nvarchar(255);

  UPDATE Nashvillehousing
  SET PropertysplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  ALTER TABLE NashvilleHousing
  ADD Propertysplitcity VARCHAR; --(coded varchar (1))

  ALTER TABLE NashvilleHousing
  ALTER COLUMN Propertysplitcity VARCHAR (255); --(converted the varchar (1) to varchar (255))

 --(Seems the Alter command is to the table and column whereas the update, to the rows)

  UPDATE Nashvillehousing
  SET Propertysplitcity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


  SELECT PropertyAddress, PropertysplitAddress, Propertysplitcity
  FROM NashvilleHousing


  SELECT OwnerAddress,
  PARSENAME (REPLACE(OwnerAddress, ',', '.') ,3),
  PARSENAME (REPLACE(OwnerAddress, ',', '.') ,2), 
  PARSENAME (REPLACE(OwnerAddress, ',', '.') ,1)
  FROM NashvilleHousing

  --SELECT PropertyAddress,OwnerAddress,
  --SUBSTRING (OwnerAddress, 1, CHARINDEX(',' ,OwnerAddress) -1 ),
  --SUBSTRING (OwnerAddress,CHARINDEX(',' ,OwnerAddress) +1, CHARINDEX(' ' ,OwnerAddress))
  --FROM NashvilleHousing

  ALTER TABLE NashvilleHousing
  ADD OwnerSplitAddress nvarchar(255)

  UPDATE NashvilleHousing
  SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.') ,3)

  ALTER TABLE NashvilleHousing
  ADD OwnerSplitCity varchar(255)

  UPDATE NashvilleHousing
  SET OwnerSplitCity =  PARSENAME (REPLACE(OwnerAddress, ',', '.') ,2)

  ALTER TABLE NashvilleHousing
  ADD OwnerSplitState nvarchar(255)

  UPDATE NashvilleHousing
  SET OwnerSplitState =  PARSENAME (REPLACE(OwnerAddress, ',', '.') ,1)

  SELECT  OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
  FROM NashvilleHousing

  

  --CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD

  SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
  FROM NashvilleHousing
  GROUP BY SoldAsVacant
  ORDER BY COUNT(SoldAsVacant)

  SELECT soldasvacant,
   CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
   END
  FROM NashvilleHousing
 

 UPDATE NashvilleHousing
 SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
				    END


   --REMOVING DUPLICATES

    WITH RowNumCTE AS(
	SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY Parcelid,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID) row_num

	FROM Nashvillehousing
	)
	DELETE
	FROM RowNumCTE
	where ROW_NUM > 1


	--(CHECK)
    WITH RowNumCTE AS(
	SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY Parcelid,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID) row_num

	FROM Nashvillehousing
	)
	SELECT *
	FROM RowNumCTE
	where ROW_NUM > 1

    --DELETE UNUSED COLUMNS

	SELECT *
	FROM NashvilleHousing

	ALTER TABLE NashvilleHousing
	DROP COlUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

	
