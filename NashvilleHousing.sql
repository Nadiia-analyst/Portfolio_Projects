--Cleaning Data in SQL Queries

SELECT *
FROM PortfolioProject..NashvilleHousing
---or ProjectPortdolio.dbo.NashvilleHousing

---1) STANDARDIZE DATE FORMAT 
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) ---doesn't work all the time

SELECT SaleDate
FROM PortfolioProject..NashvilleHousing --to check, if it is not working, then

ALTER TABLE NashvilleHousing--ALTER TABLE allows to add, modify, and delete columns of an existing table
ADD SaleDateConverted Date ---where we are adding a new column where "Date" is a format

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

---Then check:
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing 


---2) POPULATE PROPERTY ADDRESS DATE 
SELECT *
FROM PortfolioProject..NashvilleHousing
--HWERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing 
WHERE PropertyAddress is NULL--to check NULL values

SELECT *
FROM PortfolioProject..NashvilleHousing 

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b 
   ON a.ParcelID=b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID] ---where the two doesn't equal (<>) each other

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b 
   ON a.ParcelID=b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID] ---where the two doesn't equal (<>) each other
WHERE a.PropertyAddress is NULL --we have an address but we are not populating it

--We use "ISNULL" to check if a.PropertyAddress is null, and if it is null, then populate it with b.PropertyAddress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)                                                                            
FROM PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b 
   ON a.ParcelID=b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID] ---where the two doesn't equal (<>) each other
WHERE a.PropertyAddress is NULL --we have an address but we are not populating it


UPDATE a ---We can't put "NashvilleHousing" because we changed it to "a"
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b 
   ON a.ParcelID=b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID] 
WHERE a.PropertyAddress is NULL --- Now, none has NULL in it
  
---Run again above query, this time without "WHERE" function to verify that we don't have NULL values anymore
UPDATE a ---We can't put "NashvilleHousing" because we changed it to "a"
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b 
   ON a.ParcelID=b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID] 
   

 ---3)BREAKING OUT ADRESS INTO INDIVIDUAL COLUMN (ADDRESS, CITY, STATE) 
   
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--HWERE PropertyAddress is NULL
--ORDER BY ParcelID

--In PropertyAddress column we have together an address and state;
--It is seperated by a Delimiter - a character that marks the beginning or end of a unit of data; 
--or delimeter separates different columns/values
--In our case, the delimeter is coma in PropertyAddress column


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
--CHARINDEX(',', PropertyAddress)). Will give some # of the position where a coma is
FROM PortfolioProject..NashvilleHousing       


--where SUBSTRING function retrieves characters from the string. It needs 3 arguments: the name of the column, the starting point/character, the ending point.
-- "1" means starting at the very first value, and goes until the coma
--and, CHARINDEX function locates  searches for a substring (e.g coma, word, etc.) in a string, and returns the position, In our case it is coma in PropertyAddress column
  
  
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
FROM PortfolioProject..NashvilleHousing             
         
--To exclude coma from the Address column we put "-1" to go one character back     
--To skip coma and start with the letter characeter in the second Address column we need to put "+1" to start with one character forward 
--LEN funciton is to specify where 2nd SUBSTRING needs to finish
--To see the difference run with and without LEN function
            
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing                    
--NOW, 
--We can't create two columns without actually creating 2 different columns. Thus, we are going to add them                     
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);
         
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)     
            
ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar (255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))               
   
SELECT *
FROM PortfolioProject..NashvilleHousing

--Another way (easier one) of seperating characters in OwnerAdrress columns:
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing 


--We are using PARSENAME function to choose and seperate only that part of the string that we need. PARSENAME returns the specified part of an object name
SELECT PARSENAME(OwnerAddress,1)--But "PARSENAME" function works only with periods, hence we need to replace comas in OwnerAddress column to period
FROM PortfolioProject..NashvilleHousing 

--Thus, run again like this:
SELECT 
   PARSENAME(REPLACE(OwnerAddress,',','.'), 3),--In PARSENAME function, "3" indicates the first part seperated by period
   PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
   PARSENAME(REPLACE(OwnerAddress,',','.'), 1)--Here, "1" indicates the last part seperated by period
FROM PortfolioProject..NashvilleHousing 

ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress Nvarchar(255)
UPDATE NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity Nvarchar(255)
UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


ALTER TABLE NashvilleHousing 
ADD OwnerSplitState Nvarchar(255)
UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT *
FROM PortfolioProject..NashvilleHousing


 ---4) CHANGE "Y" AND "N" TO "Yes" AND "No" in "Sold as Vacant" FIELD

 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) --DISTINCT function returns, shows only distinct (different) values.
 FROM PortfolioProject..NashvilleHousing
 GROUP BY SoldAsVacant
 ORDER BY COUNT(SoldAsVacant)---or ORDER BY 2, where 2 is a 2nd column

 UPDATE NashvilleHousing
 SET SoldAsVacant=REPLACE(SoldAsVacant,'Yeses','Yes')--Possible way to rename Y to Yeses and then to Yes but don't recommend it since it involves unnessary steps


 --We're using CASE WHEN function to specify the condition we want it to return
 SELECT SoldAsVacant
 , CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant--ELSE means to leave as is
	  END
 FROM PortfolioProject..NashvilleHousing

 UPDATE NashvilleHousing
 SET SoldAsVacant=CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	  END

--Run following query to see the changes
 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) --DISTINCT function returns, shows only distinct (different) values.
 FROM PortfolioProject..NashvilleHousing
 GROUP BY SoldAsVacant
 ORDER BY COUNT(SoldAsVacant)---or ORDER BY 2, where 2 is a 2nd column


---5) REMOVING DUPLICATES AND UNUSED COLUMNS
--We will write CTE - Common Table Expression, also called as CTE in short form, is a temporary named result set that can be referenced within a SELECT, INSERT, UPDATE, or DELETE statement and View
--First, we want to partition(divide into groups) our data, we need to identify duplicate rows, and we can do to so by using functions RANK, ORDER RANK, ROW NUMBER
--We want to partition on things that should be unique to each row
--Thus, we are choosing following rows because they have to be one and only, and if not we will remove them later
--ROW_NUMBER is a window function to calculate number of each row within a partition of a result set
SELECT *
FROM PortfolioProject..NashvilleHousing

SELECT *,
      ROW_NUMBER() OVER (
      PARTITION BY ParcelID,
                   PropertyAddress, 
                   SalePrice,
                   LegalReference
                   ORDER BY UniqueID --ORDER BY is mandatory here
                         ) as row_num

FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID
--WHERE row_num > 1---> we need WHERE function, however,to run this query we need to add CTE(Temp.Table) to create a temporary table
   
WITH RowNumCTE AS (
SELECT *,
      ROW_NUMBER() OVER (
      PARTITION BY ParcelID,
                   PropertyAddress, 
                   SalePrice,
                   LegalReference
                   ORDER BY UniqueID 
                         ) as row_num

FROM PortfolioProject..NashvilleHousing
)
SELECT *--Now, we run the following to, finally, see how many rows with duplicates in the data
FROM RowNumCTE
WHERE row_num > 1  --where "1" in row_num means one unique result, and "2", a duplicate
ORDER BY PropertyAddress

--We have 121 duplicate rows!

--To delete duplicates, we use DELETE function after CTE
WITH RowNumCTE AS (
SELECT *,
      ROW_NUMBER() OVER (
      PARTITION BY ParcelID,
                   PropertyAddress, 
                   SalePrice,
                   LegalReference
                   ORDER BY UniqueID 
                         ) as row_num

FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1 
--ORDER BY PropertyAddress, doesn't work in this query


--Let's check if duplicates were deleted
WITH RowNumCTE AS (
SELECT *,
      ROW_NUMBER() OVER (
      PARTITION BY ParcelID,
                   PropertyAddress, 
                   SalePrice,
                   LegalReference
                   ORDER BY UniqueID 
                         ) as row_num

FROM PortfolioProject..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1 
ORDER BY PropertyAddress

--And there were deleted!!!


---6) DELETE UNUSED COLUMNS. 
---!!!NOTE!!!: Deletion of columns must be verified by manager. Usually raw data doesn't get deleted

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing--ALTER is used for creating, deleting columns, etc
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

--To check ho we did
SELECT *
FROM PortfolioProject..NashvilleHousing




