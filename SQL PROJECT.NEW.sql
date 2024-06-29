
-------RETAIL EVENT ANALYSIS WITH SQL----------

create database new;
use new;

------SELECTING TABLES.

SELECT
campaign_id,campaign_name,start_date,end_date 
FROM new.dim_campaigns;

SELECT
product_code,product_name,category 
FROM new.dim_products;

SELECT 
store_id,city 
FROM new.dim_stores;

SELECT
event_id,store_id,campaign_id,product_code,base_price,promo_type,quantity_soldafter,quantity_soldafter
FROM new.fact_event;


desc new.fact_event;
desc new.dim_campaigns;
desc new.dim_products;
desc new.dim_stores;

------PROVIDE LIST OF PRODUCTS WITH BASE PRICE GREATER THAN 500 AND THAT ARE FEATURED IN PROMO TYPE OF "BOGOF".

select dim_products.product_code,dim_products.product_name,dim_products.category,
fact_event.base_price,fact_event.promo_type from new.dim_products
inner join new.fact_event on 
dim_products.product_code = fact_event.product_code
where base_price > 500 and promo_type ="BOGOF";



select distinct dim_products.product_code,dim_products.product_name,dim_products.category,
fact_event.base_price,fact_event.promo_type from new.dim_products
inner join new.fact_event on 
dim_products.product_code =fact_event.product_code
where base_price > 500 and promo_type ="BOGOF";



SELECT DISTINCT 
dim_products.product_code,dim_products.product_name,dim_products.category,
fact_event.base_price,fact_event.promo_type 
FROM new.dim_products
INNER JOIN new.fact_event on 
dim_products.product_code =fact_event.product_code
WHERE base_price > 500 ;


------GENERATE A REPORT THAT PROVIDES AN OVERVIEW OF THE NUMBER OF STORES IN EACH CITY.THE REULT WII BE STORED IN DESCENDING ORDER OF 
STORE COUNTS,ALLOWING US TO IDENTIFY THE CITIES WITH THE HIGHEST STORE PRESENCE.


SELECT 
city,count(store_id) as storecount 
FROM new.dim_stores
GROUP BY city
ORDER BY storecount DESC;

-----GENERATE REPORT THAT DISPLAYS EACH CAMPAIGN ALONG WITH THE TOTAL REVENUE GENERATED BEFORE AND AFTER THE CAMPAIGN.


SELECT campaign_name,
SUM(fact_event.quantity_soldbefore * fact_event.base_price /1000000) as total_revenue_before_promotion,
SUM(fact_event.quantity_soldafter * fact_event.base_price /1000000) as total_revenue_after_promotion
FROM new.dim_campaigns 
INNER JOIN new.fact_event on 
dim_campaigns.campaign_id = fact_event.campaign_id
GROUP BY campaign_name;

------PRODUCE A REPORT TAHT CALCULATES THE INCREMENTAL SOLD QUANTITY(ISU%) FOR EACH CATEGORY DURING THE DIWALI CAMPAIGN.


SELECT dim_products.category ,
(SUM(fact_event.quantity_soldafter) - sum(fact_event.quantity_soldbefore))/sum(fact_event.quantity_soldbefore)*100
as ISUpercentage,
RANK() OVER(ORDER BY(sum(fact_event.quantity_soldafter) - sum(fact_event.quantity_soldbefore))/sum(fact_event.quantity_soldbefore)*100 desc)
as rank_order
FROM new.dim_products
INNER JOIN new.fact_event on
fact_event.product_code = dim_products.product_code
INNER JOIN new.dim_campaigns on
dim_campaigns.campaign_id = fact_event.campaign_id
WHERE  dim_campaigns.campaign_name ="Diwali"
GROUP BY dim_products.category;

-------CREATE A REPORT FEATURING THE TOP 5 PRODUCTS ,RANKED BY INCREMENTAL REVENUE PERCENTAGE(IR%),ACROSS ALL CAMPAIGNS.


SELECT dim_products.product_name,dim_products.category,
SUM(fact_event.quantity_soldafter * fact_event.base_price) -sum(fact_event.quantity_soldafter * fact_event.base_price)/
SUM(fact_event.quantity_soldafter * fact_event.base_price)*100 as IRpercentage
FROM new.dim_products
INNER JOIN new.fact_event on
dim_products.product_code = fact_event.product_code
GROUP BY dim_products.product_name,dim_products.category LIMIT 5;


-----WHICH ARE THE TOP 10 STORES IN TERM OF INCREMENTAL REVENUE (IR) GENERATED FROM THE PROMOTIONS.


SELECT dim_stores.store_id,dim_stores.city,
SUM(fact_event.quantity_soldafter * fact_event.base_price) -sum(fact_event.quantity_soldafter * fact_event.base_price)/
SUM(fact_event.quantity_soldafter * fact_event.base_price)*100 as IRpercentage
FROM new.dim_stores
INNER JOIN  new.fact_event on
fact_event.store_id = dim_stores.store_id
GROUP BY dim_stores.store_id,dim_stores.city 
ORDER BY IRpercentage desc limit 10;


-----WHICH ARE THE BOTTOM 10 STORES WHEN IT COMES TO INCREMENTAL SOLD UNITS(ISU) DURING THE PROMOTIONAL PERIOD.


SELECT dim_stores.store_id,dim_stores.city,
(sum(fact_event.quantity_soldafter) - sum(fact_event.quantity_soldbefore))/sum(fact_event.quantity_soldbefore)*100 as ISUpercentage
FROM new.dim_stores
INNER JOIN new.fact_event on
fact_event.store_id = dim_stores.store_id
GROUP BY dim_stores.store_id,dim_stores.city 
ORDER BY ISUpercentage asc limit 10;


-----HOW DOES THE PERFORMANCE OF STORES VARY BY CITY?ARE THERE ANY COMMON CHARACTERISTICS AMONG THE TOP-PERFORMING STORES THAT 
COULD BE LEVERAGED ACROSS OTHER STORES.


SELECT dim_stores.city,
COUNT(dim_stores.store_id) as storecount,
SUM((fact_event.quantity_soldafter - fact_event.quantity_soldbefore )* fact_event.base_price) as total_sales,
AVG((fact_event.quantity_soldafter - fact_event.quantity_soldbefore) * fact_event.base_price) as avg_sales
FROM new.dim_stores
INNER JOIN new.fact_event on
dim_stores.store_id = fact_event.store_id
GROUP BY dim_stores.city
ORDER BY storecount DESC;

-----WHAT ARE TOP 2 PROMOTIONS TYPES THAT RESULTED IN THE HIGHEST INCREMENTAL REVENUE.


SELECT fact_event.promo_type ,
SUM(fact_event.quantity_soldafter * fact_event.base_price) -sum(fact_event.quantity_soldafter * fact_event.base_price)/
SUM(fact_event.quantity_soldafter * fact_event.base_price)*100 as highest_IRpercentage
FROM new.fact_event
GROUP BY fact_event.promo_type 
ORDER BY highest_IRpercentage DESC LIMIT 2;


-------WHAT ARE THE BOTTOM 2 TYPES IN TERMS OF THEIR IMPACT ON INCREMENTAL SOLD UNITS?


SELECT fact_event.promo_type,
(SUM(fact_event.quantity_soldafter) - sum(fact_event.quantity_soldbefore))/sum(fact_event.quantity_soldbefore)*100 as ISU
FROM new.fact_event
GROUP BY fact_event.promo_type
ORDER BY ISU asc limit 2;


-------IS THERE A SIGNIFICANT DIFFERENCE IN THE PERFORMANCE OF DISCOUNT BASED PROMOTIONS VERSUS BOGOF OR CASHBACK PROMOTIONS.



SELECT fact_event.promo_type,
SUM(fact_event.quantity_soldbefore * fact_event.base_price /100) as total_revenue_before_promotion,
SUM(fact_event.quantity_soldafter * fact_event.base_price /1000) as total_revenue_after_promotion,
SUM(fact_event.quantity_soldbefore * fact_event.base_price /100) -
sum(fact_event.quantity_soldafter * fact_event.base_price /1000) as significant_difference
FROM new.fact_event
WHERE fact_event.promo_type ="BOGOF" or fact_event.promo_type ="500 cashback"
GROUP BY fact_event.promo_type;


------WHICH PROMOTIONS STRIKE THE BEST BALANCE BETWEEN INCREMENTAL SOLD UNITS AND MAINTAINING HEALTHY MARGINS.


SELECT fact_event.promo_type,
(SUM(fact_event.quantity_soldafter) - sum(fact_event.quantity_soldbefore))/sum(fact_event.quantity_soldbefore)*100 as ISU,
SUM(fact_event.quantity_soldafter * fact_event.base_price) -sum(fact_event.quantity_soldafter * fact_event.base_price)/
SUM(fact_event.quantity_soldafter * fact_event.base_price)*100 as healthy_margins
FROM new.fact_event
GROUP BY fact_event.promo_type
ORDER BY healthy_margins DESC;


-----WHICH PRODUCT CATEGORIES SAW THE MOST SIGNIFICANT LIFT IN SALES FROM THE PROMOTIONS.


SELECT dim_products.category,
SUM(fact_event.quantity_soldbefore) as quantity_sold_before,
SUM(fact_event.quantity_soldafter) as quantity_sold_after,
SUM(fact_event.quantity_soldafter) - sum(fact_event.quantity_soldbefore) as most_significant_lift
FROM new.dim_products
INNER JOIN new.fact_event on 
dim_products.product_code = fact_event.product_code
GROUP BY  dim_products.category
ORDER BY most_significant_lift DESC;


-----ARE THERE SPECIFIC PRODUCTS THAT RESPOND EXCEPTIONALLY WELL OR POORLY TO PROMOTIONS.


SELECT dim_products.product_name,
SUM(case when fact_event.quantity_soldafter - fact_event.quantity_soldbefore > 0
then fact_event.quantity_soldafter - fact_event.quantity_soldbefore else 0 end) as well_promotions,
SUM(case when fact_event.quantity_soldafter - fact_event.quantity_soldbefore < 0
 then fact_event.quantity_soldafter - fact_event.quantity_soldbefore else 0 end) as poorly_promotions
FROM new.dim_products
INNER JOIN new.fact_event on 
dim_products.product_code = fact_event.product_code
GROUP BY dim_products.product_name;


-----WHAT IS THE CORRELATION BETWEEN PRODUCT CATEGORY AND PROMOTION TYPE EFFECTIVENESS.


SELECT dim_products.category,fact_event.promo_type,count(promo_type) as frequency
FROM new.dim_products
INNER JOIN new.fact_event on
dim_products.product_code = fact_event.product_code
GROUP BY dim_products.category,fact_event.promo_type
ORDER BY dim_products.category , frequency desc;







                                                                                                                                                                            
































