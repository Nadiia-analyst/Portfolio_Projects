---Cleaning Data in SQL Queries

SELECT *
FROM ProjectPortfolio..NashvilleHousing 
---or ProjectPortdolio.dbo.NashvilleHousing


---1) Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM ProjectPortfolio..NashvilleHousing 

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) ---doesn't work all the time

---Or,
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date ---where we are adding a new column where "Date" is a format

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

---Then try:
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM ProjectPortfolio..NashvilleHousing 

---2) Populate Propery Address Data

SELECT *
FROM PortfolioProject..NashvilleHousing
--HWERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT PropertyAddresss
FROM ProjectPortfolio..NashvilleHousing 
WHERE PropertyAddress is NULL--to check NULL values

SELECT *
FROM ProjectPortfolio..NashvilleHousing 

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing as a
JOIN ProjectPortfolio.dbo.NashvilleHousing as b 
   ON a.ParcelID=b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID] ---where the two doesn't equal (<>) each other

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM ProjectPortfolio.dbo.NashvilleHousing as a
JOIN ProjectPortfolio.dbo.NashvilleHousing as b 
   ON a.ParcelID=b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID] ---where the two doesn't equal (<>) each other
WHERE a.PropertyAddress is NULL --we have an address but we are not populating it

--We use "ISNULL" to check if a.PropertyAddresse is null, and if it is null, then populate it with b.PropertyAddress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)                                                                            
FROM ProjectPortfolio.dbo.NashvilleHousing as a
JOIN ProjectPortfolio.dbo.NashvilleHousing as b 
   ON a.ParcelID=b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID] ---where the two doesn't equal (<>) each other
WHERE a.PropertyAddress is NULL --we have an address but we are not populating it


UPDATE a ---We can't put "NashvilleHousing" because we changed it to "a"
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvilleHousing as a
JOIN ProjectPortfolio.dbo.NashvilleHousing as b 
   ON a.ParcelID=b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID] 
WHERE a.PropertyAddress is NULL --- Now, none has NULL in it
  
---Run again above query, this time without "WHERE" function
UPDATE a ---We can't put "NashvilleHousing" because we changed it to "a"
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvilleHousing as a
JOIN ProjectPortfolio.dbo.NashvilleHousing as b 
   ON a.ParcelID=b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID] 
   
   
---3) Breaking out Address into Individual Columns (Address, City, State)
   
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
--CHARINDEX(',', PropertyAddress)). Will give some # of the position where this comas is
FROM PortfolioProject..NashvilleHousing       

--where SUBSTRING function retrieves characters from the string
-- "1" means starting at the very first value, and goes until the coma
--and, CHARINDEX function locates  searches for a substring (e.g coma, word, etc.) in a string, and returns the position, In our case it is coma in PropertyAddress column
  
  
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
FROM PortfolioProject..NashvilleHousing             
         
 --To exclude coma from the Address column we put "-1" to go one character back     
          
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1), LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing            

--To skip coma and start with the letter characeter in the second Address column we need to put "+1" to start with one character forward 
--LEN funciton is to specify where 2nd SUBSTRING needs to finish
--To see the difference run with and without LEN function
   
            
--NOW, 
--We can't create two columns without creating 2 different columns. Thus, we are going to add them 
                       
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);
         
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)     
            
ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar (255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1), LEN(PropertyAddress))               
   
SELECT *
FROM PortfolioProject..NashvileHousing