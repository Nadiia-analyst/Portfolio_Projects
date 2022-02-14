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
ADD SaleDateConverted Date; ---where we are adding a new column where "Date" is a format

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

---Then try:
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM ProjectPortfolio..NashvilleHousing 

---2) Populate Propery Address Data

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

--We use "ISNULL" to check what is it null, and if it is null what we want to populate. And we want to put b.PropertyAddress
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
   
  
