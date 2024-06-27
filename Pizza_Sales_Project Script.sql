create database pizzahut;
use pizzahut;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));


-- 1. Retrieve the total number of orders placed
SELECT 
    COUNT(order_id) AS total_orders_placed
FROM
    orders;

-- 2. Calculate the total revenue generated from the pizza sale.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM                                                   --  To beautify query- ctrl+b
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;      
    
    -- 3. Identify the highest-priced pizza.alter
    select pizza_types.name, pizzas.price
    from pizza_types join pizzas
    on pizzas.pizza_type_id = pizza_types.pizza_type_id
    order by pizzas.price desc
    limit 1;
    
-- 4. Identify the most common pizza size ordered.
select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by order_count desc;

-- 5. List Five most ordered pizza types along with quantity.
select pizza_types.name, sum(order_details.quantity) as total_quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by total_quantity desc limit 5;


-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category, sum(order_details.quantity) as total_quantity
from pizzas join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details 
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by total_quantity desc;


-- 7. Determine the distribution of orders by hour of the day
select hour(order_time), count(order_id) from orders
group by hour(order_time);


-- 8. Join relevant tables to find the category wise distribution of pizza.
select category, count(name) from pizza_types
group by category;


-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(pizzas_ordered),0) as average_pizza_ordered_per_day from
(select orders.order_date, sum(order_details.quantity) as pizzas_ordered
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity;


-- 10. Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name 
order by revenue desc
limit 3;


-- 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(pizzas.price * order_details.quantity) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;





-- Revenue = quantity x price


select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date, 
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;


-- 12. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name, sum(pizzas.price * order_details.quantity) as revenue
from pizzas join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;











