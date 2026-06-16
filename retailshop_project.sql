-- BASIC 
use retail_shop;
-- 1.  RETRIVE CUSTOMER NAMES AND EMAILS FOR EMAIL MARKETING 

select name, email FROM customers;
 
-- 2.VIEW COMPLETE PRODUCT CATELOG WITH ALL AVAILABLE DETAILS

select * from products;

-- 3. List all unique product categories
-- Useful for analyzing the range of departments or for creating filters on the website.
select distinct category from products;


-- 4. Show all products priced above ₹1,000
-- This helps identify high-value items for premium promotions or pricing strategy reviews.

select * from products where price > 1000;

-- 5. Display products within a mid-range price bracket (₹2,000 to ₹5,000)
-- A merchandising team might need this to create a mid-tier pricing campaign.

select * from products where price between 2000 and 5000;

-- 6. Fetch data for specific customer IDs (e.g., from loyalty program list)
-- This is used when customer IDs are pre-selected from another system.

select * from customers where customer_id in (2,4,6,8);

-- 7. Identify customers whose names start with the letter ‘A’
-- Used for alphabetical segmentation in outreach or app display.z

select * from customers where name like 'A%';


-- 8. List electronics products priced under ₹3,000
-- Used by merchandising or frontend teams to showcase budget electronics.

select * from products where category = 'Electronics'and price < 3000;

-- 9. Display product names and prices in descending order of price
-- This helps teams easily view and compare top-priced items.

select name, price from products order by price desc;

-- 10. Display product names and prices, sorted by price and then by name
-- The merchandising or catalog team may want to list products from most expensive to cheapest. If
-- multiple products have the same price, they should be sorted alphabetically for clarity on storefronts or
-- printed catalogs.

select name, price from products order by price desc , name asc;


-- Level 2: Filtering and Formatting
-- 1. Retrieve orders where customer information is missing (possibly due to data migration or deletion) 
-- Used to identify orphaned orders or test data where customer_id is not linked.

select * from orders where customer_id is null;

-- 2. Display customer names and emails using column aliases for frontend readability
-- Useful for feeding into frontend displays or report headings that require user-friendly labels.

select name AS FULL_NAME, email as CUSTOMER_EMAIL_ADDRESS from customers;


-- 3. Calculate total value per item ordered by multiplying quantity and item price
-- This can help generate per-line item bill details or invoice breakdowns.

select order_item_id , (quantity * item_price) as total_value_per_item from order_items;


-- 4. Combine customer name and phone number in a single column
-- Used to show brief customer summaries or contact lists.

select concat( name, ' - ', phone) as customer_contact from customers; 


-- 5. Extract only the date part from order timestamps for date-wise reporting
-- Helps group or filter orders by date without considering time.

select order_id, customer_id, date(order_date) as 'date',status,total_amount from orders;

-- 6. List products that do not have any stock left
-- This helps the inventory team identify out-of-stock items.

select * from products where stock_quantity =0;

-- Level 3: Aggregations

-- 1. Count the total number of orders placed
-- Used by business managers to track order volume over time.

select count(order_id) from orders;

-- 2. Calculate the total revenue collected from all orders
-- This gives the overall sales value.

select sum(amount_paid) as total_revenue from payments;


-- 3. Calculate the average order value
-- Used for understanding customer spending patterns.

select round(avg(total_amount),2) as average_order from orders;

-- 4. Count the number of customers who have placed at least one order
-- This identifies active customers.

select count(distinct(customer_id)) as active_customer from orders;
 
-- 5. Find the number of orders placed by each customer
-- Helpful for identifying top or repeat customers.

select customer_id , count(order_id) AS TOTAL_ORDER from orders group by customer_id;

-- 6. Find total sales amount made by each customer

select customer_id, sum(total_amount) as TOTAL_AMOUNT_EACH_CUSTOMER from orders group by customer_id;

-- 7. List the number of products sold per category
-- This helps category managers assess performance by department.

select category, count(product_id) as product_count from products group by category;
-- 8. Find the average item price per category
-- Useful to compare pricing across departments.

select category, round(avg(price),2) as AVG_ITEM_PRICE from products group by category;


-- 9. Show number of orders placed per day
-- Used to track daily business activity and demand trends.

select date(order_date), count(order_id) as ORDER_PER_DAY from orders group by date(order_date) order by ORDER_PER_DAY desc;

-- 10. List total payments received per payment method
-- Helps the finance team understand preferred transaction modes.

select method, sum(amount_paid) as payment_recieved from payments group by method order by payment_recieved desc;


-- Level 4: Multi-Table Queries (JOINS)

-- 1. Retrieve order details along with the customer name (INNER JOIN)
-- Used for displaying which customer placed each order.

select o.order_id, c.name, o.total_amount from customers c inner join orders o on o.customer_id = c.customer_id;

-- 2. Get list of products that have been sold (INNER JOIN with order_items)
-- Used to find which products were actually included in orders.

select distinct p.product_id, p.name, p.category from products p inner join order_items o on p.product_id = o.product_id;

-- 3. List all orders with their payment method (INNER JOIN)
-- Used by finance or audit teams to see how each order was paid for.

select o.*, p.method from orders o inner join payments p on o.order_id = p.order_id;


-- 4. Get list of customers and their orders (LEFT JOIN)
-- Used to find all customers and see who has or hasn’t placed orders.

select c.name, o.order_id from customers c left join orders o on c.customer_id= o.customer_id ;

-- 5. List all products along with order item quantity (LEFT JOIN)
-- Useful for inventory teams to track what sold and what hasn’t.

select p.name as product_name, p.category, sum(o.quantity) as total_quantity from products p left join order_items o on p.product_id = o.product_id
group by p.category , p.name;

-- 6. List all payments including those with no matching orders (RIGHT JOIN)
-- Rare but used when ensuring all payments are mapped correctly.


select p.* from orders o right join payments p on o.order_id = p.order_id where o.order_id is null;

-- 7. Combine data from three tables: customer, order, and payment
-- Used for detailed transaction reports./*

select c.name, o.order_id , o.total_amount, p.method, date(payment_date) as order_date from customers c
join orders o on c.customer_id = o.customer_id
join payments p on o.order_id = p.order_id;

-- Level 5: Subqueries (Inner Queries) 
-- 1. List all products priced above the average product price
-- Used by pricing analysts to identify premium-priced products.


select * from products where price > (select avg(price) from products) order by price desc;

-- 2. Find customers who have placed at least one order
-- Used to identify active customers for loyalty campaigns.

select * from customers c where (select count(*) from orders o where o.customer_id = c.customer_id) > 0;


-- 3. Show orders whose total amount is above the average for that customer
-- Used to detect unusually high purchases per customer.

select customer_id, order_id, sum(total_amount) as total_spent from orders
group by customer_id, order_id
having total_spent > (select avg(amount_paid) from payments) order by total_spent desc;

-- 4. Display customers who haven’t placed any orders
-- Used for re-engagement campaigns targeting inactive users.

select c.* from customers c left join orders o on c.customer_id = o.customer_id where o.order_id is null;

-- 5. Show products that were never ordered
-- Helps with inventory clearance decisions or product deactivation.

select p.* from products p left join order_items oi on p.product_id = oi.product_id where oi.product_id is null;


-- 6. Show highest value order per customer
-- Used to identify the largest transaction made by each customer.

select o.customer_id, o.order_id, o.total_amount from orders o where o.total_amount = (select max(o2.total_amount) from orders o2 where o2.customer_id = o.customer_id ) order by o.total_amount desc;


-- 7. Highest Order Per Customer (Including Names)
-- Used to identify the largest transaction made by each customer. Outputs name as well.


select c.name, o.customer_id, o.order_id, o.total_amount as highest_order from orders o join customers c on o.customer_id = c.customer_id
where o.total_amount = (select max(o2.total_amount) from orders o2 where o2.customer_id = o.customer_id) order by highest_order desc;

-- Level 6: Set Operations
-- 1. List all customers who have either placed an order or written a product review
-- Used to identify engaged customers from different activity areas.

select distinct c.customer_id, c.name, c.email from customers c left join orders o on c.customer_id = o.customer_id left join product_reviews pr on c.customer_id = pr.customer_id
where o.customer_id is not null or pr.customer_id is not null;


-- 2. List all customers who have placed an order as well as reviewed a product [intersect not supported]
-- Used to identify highly engaged customers for rewards. 

select customer_id, name, email from customers where customer_id in (select customer_id from orders)
and customer_id in (select customer_id from product_reviews);
