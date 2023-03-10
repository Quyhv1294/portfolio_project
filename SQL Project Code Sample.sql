--CREATE TABLE DIM_ADVW_CUSTOMERS
SELECT T.CUSTOMERKEY,
       T.PREFIX,
       T.FIRSTNAME,
       (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')) -
       TO_NUMBER(TO_CHAR(T.BIRTHDATE, 'YYYY'))) AGE,
       CASE WHEN T.GENDER = 'F' THEN 'FeMale' ELSE 'Male' END GENDER,
       TO_NUMBER(REPLACE(TRIM(REPLACE(T.ANNUALINCOME,'$','')),',','')) ANNUALINCOME,
       T.HOMEOWNER,
       T.TOTALCHILDREN
  FROM ADVW_CUSTOMERS T;
 
--CREATE TABLE DIM_ADVW_PRODUCT_SUBCATEGORIES
    SELECT T.PRODUCTKEY,
           T3.CATEGORYNAME,
           T2.SUBCATEGORYNAME,
           T.PRODUCTNAME,
           T.MODELNAME,
           T.PRODUCTCOLOR
      FROM ADVW_PRODUCTS T
      LEFT JOIN ADVW_PRODUCT_SUBCATEGORIES T2
        ON T.PRODUCTSUBCATEGORYKEY = T2.PRODUCTSUBCATEGORYKEY
      LEFT JOIN ADVW_PRODUCT_CATEGORIES T3
        ON T2.PRODUCTCATEGORYKEY = T3.PRODUCTCATEGORYKEY
        
  --CREATE TABLE TIMER_DIM
  SELECT TO_NUMBER(TO_CHAR(T.CALENDAR_DATE, 'YYYYMMDD')) ORDERDATE,
         T.CALENDAR_DATE,
         T.YEAR_NUMBER,
         T.QUARTER_NUMBER,
         T.MONTH_NUMBER,
         SUBSTR(T.DAY_WEEKNAME,'1','3') DAY_SHORT,
         T.WEEK_NUMBER
    FROM TIMER_DIM T
   WHERE T.YEAR_NUMBER >= 2015 AND T.YEAR_NUMBER <= 2017
   ORDER BY T.YEAR_NUMBER;
  
  --CREATE TABLE DIM_ADVW_RETURNS
  SELECT TO_NUMBER(TO_CHAR(T.RETURNDATE,'YYYYMMDD'))RETURNDATE,T.TERRITORYKEY,T.PRODUCTKEY,T.RETURNQUANTITY FROM ADVW_RETURNS T
 
--CREATE TABLE FACT_ADVW_SALES
WITH DATA_A AS (
  SELECT  A.PRODUCTKEY,
         A.CUSTOMERKEY,
         A.TERRITORYKEY,
         A.ORDERDATE,
         SUM(A.ORDERQUANTITY)ORDERQUANTITY
          FROM(
  SELECT M.PRODUCTKEY,
         M.CUSTOMERKEY,
         M.TERRITORYKEY,
         M.ORDERLINEITEM,
         M.ORDERQUANTITY,
         TO_NUMBER(TO_CHAR(M.ORDERDATE, 'YYYYMMDD')) ORDERDATE
    FROM (SELECT *
            FROM ADVW_SALES_2015
          UNION ALL
          SELECT *
            FROM ADVW_SALES_2016
          UNION ALL
          SELECT *
            FROM ADVW_SALES_2017) M)A
            GROUP BY
            A.PRODUCTKEY,         
         A.CUSTOMERKEY,
         A.TERRITORYKEY,
         A.ORDERDATE),
DATA_B AS (SELECT R.PRODUCTKEY,
                  SUM(R.PRODUCTPRICE)PRODUCTPRICE,
                  SUM(R.PRODUCTCOST)PRODUCTCOST
            FROM ADVW_PRODUCTS R
            GROUP BY R.PRODUCTKEY)
SELECT A.*,B.PRODUCTPRICE,B.PRODUCTCOST
        FROM DATA_A A LEFT JOIN DATA_B B
         ON A.PRODUCTKEY = B.PRODUCTKEY
