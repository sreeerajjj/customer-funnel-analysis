SELECT * FROM customer_journey LIMIT 10;
create table clean_table as select distinct*from customer_journey;
select count(*) from clean_table;
select*from clean_table where UserId is NULL or pageType is NULL;
select distinct pageType from clean_table;



create table funnel_table as
select UserId, 
MAX(CASE WHEN PageType = 'home' THEN 1 ELSE 0 END) AS visited,
MAX(CASE WHEN PageType = 'product_page' THEN 1 ELSE 0 END) AS viewed_product,
MAX(CASE WHEN ItemsInCart > 0 THEN 1 ELSE 0 END) AS added_to_cart,
MAX(CASE WHEN Purchased = 1 THEN 1 ELSE 0 END) AS purchased
FROM clean_table
GROUP BY UserID;

select*from funnel_table;

select count(*) as total_users,
SUM(visited) AS visited_users,
SUM(viewed_product) AS product_view_users,
SUM(added_to_cart) AS cart_users,
SUM(purchased) AS buyers
FROM funnel_table;


SELECT 
    ROUND(SUM(viewed_product)*100.0/SUM(visited),2) AS visit_to_product,
    ROUND(SUM(added_to_cart)*100.0/SUM(viewed_product),2) AS product_to_cart,
    ROUND(SUM(purchased)*100.0/SUM(added_to_cart),2) AS cart_to_purchase
FROM funnel_table;



SELECT 'Visit → Product' AS stage,SUM(visited) - SUM(viewed_product) AS drop_users
FROM funnel_table
UNION
SELECT 'Product → Cart',SUM(viewed_product) - SUM(added_to_cart)
FROM funnel_table
UNION
SELECT 'Cart → Purchase',SUM(added_to_cart) - SUM(purchased)
FROM funnel_table;



SELECT ReferralSource,COUNT(DISTINCT cd.UserID) AS users,SUM(ft.purchased) AS conversions
FROM clean_table cd
JOIN funnel_table ft ON cd.UserID = ft.UserID
GROUP BY ReferralSource;

SELECT DeviceType,COUNT(DISTINCT cd.UserID) AS users,SUM(ft.purchased) AS conversions
FROM clean_table cd
JOIN funnel_table ft ON cd.UserID = ft.UserID
GROUP BY DeviceType;



SELECT DATE(Timestamp) AS day,COUNT(DISTINCT UserID) AS users
FROM clean_table
GROUP BY day
ORDER BY day;

select UserID,ReferralSource,Country from clean_table where date(Timestamp) between "2025-01-01" and "2025-04-01";


CREATE TABLE final_data AS
SELECT 
    ft.UserID,
    ft.visited,
    ft.viewed_product,
    ft.added_to_cart,
    ft.purchased,

    MAX(cd.DeviceType) AS DeviceType,
    MAX(cd.Country) AS Country,
    MAX(cd.ReferralSource) AS ReferralSource

FROM funnel_table ft
JOIN clean_table cd 
    ON ft.UserID = cd.UserID

GROUP BY 
    ft.UserID,
    ft.visited,
    ft.viewed_product,
    ft.added_to_cart,
    ft.purchased;




SELECT 
COUNT(*) AS total_users,
SUM(purchased) AS buyers,
ROUND(SUM(purchased)*100.0/COUNT(*),2) AS conversion_rate
FROM final_data;

SELECT 
    DeviceType,
    COUNT(*) AS users,
    SUM(purchased) AS buyers,
    ROUND(SUM(purchased)*100.0/COUNT(*),2) AS conversion_rate
FROM final_data
GROUP BY DeviceType;

SELECT 
    Country,
    COUNT(*) AS users,
    SUM(purchased) AS buyers
FROM final_data
GROUP BY Country
ORDER BY buyers DESC;


SELECT 
    SUM(visited) AS visited,
    SUM(viewed_product) AS viewed,
    SUM(added_to_cart) AS cart,
    SUM(purchased) AS purchased
FROM final_data;

SELECT COUNT(*) FROM final_data;
SELECT COUNT(*) FROM funnel_table;