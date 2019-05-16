--32
--We want to send all of our high-value customers a special VIP gift. We're defining high-value customers
--as those who've made at least 1 order with a total value (not including the discount) equal to $10,000 or
--more. We only want to consider orders made in the year 1998

select o.CustomerID,cus.CompanyName,o.OrderID,sum(ord.UnitPrice*ord.Quantity) as TotalOrderAmount
from Orders as o inner join Customers as cus
on o.CustomerID=cus.CustomerID
inner join [Order Details] as ord
on o.OrderID=ord.OrderID
where year(o.OrderDate)=1998
group by o.CustomerID,cus.CompanyName,o.OrderID
having sum(ord.UnitPrice*ord.Quantity) >10000
order by TotalOrderAmount desc;

select o.CustomerID,cus.CompanyName,o.OrderID,sum(ord.UnitPrice*ord.Quantity) as TotalOrderAmount
from Orders as o inner join Customers as cus
on o.CustomerID=cus.CustomerID
inner join [Order Details] as ord
on o.OrderID=ord.OrderID
where year(o.OrderDate)=1998
group by o.CustomerID,cus.CompanyName,o.OrderID
order by o.CustomerID desc;

--33
--The manager has changed his mind. Instead of requiring that customers have at least one individual orders
--totaling $10,000 or more, he wants to define high-value customers as those who have orders totaling
--$15,000 or more in 2016. How would you change the answer to the problem above?

select o.CustomerID,cus.CompanyName,sum(ord.UnitPrice*ord.Quantity) as TotalOrderAmount
from Orders as o inner join Customers as cus
on o.CustomerID=cus.CustomerID
inner join [Order Details] as ord
on o.OrderID=ord.OrderID
where year(o.OrderDate)=1998
group by o.CustomerID,cus.CompanyName
having sum(ord.UnitPrice*ord.Quantity) >15000
order by TotalOrderAmount desc;

--34
--Change the above query to use the discount when calculating high-value customers. Order by the total
--amount which includes the discount.
select o.CustomerID,cus.CompanyName,sum(ord.UnitPrice*ord.Quantity) as TotalWithoutDiscount,
sum((ord.UnitPrice*ord.Quantity)*(1-ord.Discount)) as TotalWithDiscount 
from Orders as o inner join Customers as cus
on o.CustomerID=cus.CustomerID
inner join [Order Details] as ord
on o.OrderID=ord.OrderID
where year(o.OrderDate)=1998
group by o.CustomerID,cus.CompanyName
having sum(ord.UnitPrice*ord.Quantity) >15000
order by TotalWithDiscount desc;

--35
--At the end of the month, salespeople are likely to try much harder to get orders, to meet their month-end
--quotas. Show all orders made on the last day of the month. Order by EmployeeID and OrderID
--EmployeeID OrderID OrderDate

select o.EmployeeID,o.OrderID,o.OrderDate
from Orders as o
where (o.OrderDate)=EOMONTH(o.OrderDate)
order by o.EmployeeID,o.OrderID;

--36
--The Northwind mobile app developers are testing an app that customers will use to show orders. In order
--to make sure that even the largest orders will show up correctly on the app, they'd like some samples of
--orders that have lots of individual line items. Show the 10 orders with the most line items, in order of total
--line items.
select top 10 o.OrderID, count(od.OrderID) as LineItems
from Orders as o inner join [Order Details] as od
on o.OrderID=od.OrderID
group by o.OrderID
order by LineItems desc;


--37
--The Northwind mobile app developers would now like to just get a random assortment of orders for beta
--testing on their app. Show a random set of 2% of all orders.
select top (select CAST((ROUND(count(o.OrderID)*(0.02), 0, 0)) AS INT)
 from Orders as o) OrderID
from Orders
order by rand();


--38
--Janet Leverling, one of the salespeople, has come to you with a request. She thinks that she accidentally
--double-entered a line item on an order, with a different ProductID, but the same quantity. She remembers
--that the quantity was 60 or more. Show all the OrderIDs with line items that match this, in order of
--OrderID.

select od.OrderID
from [Order Details] as od
where od.Quantity>=60
group by od.OrderID,od.Quantity
order by od.OrderID;


select od.OrderID,od.Quantity
from [Order Details] as od inner join (select * from [Order Details] as od1 where od1.Quantity>=60 )as od1
on (od.OrderID=od1.OrderID
and  od.Quantity=od1.Quantity
and not od.ProductID=od1.ProductID
)
group by od.OrderID,od.Quantity;

--EL RESULTADO ESPERA TENER 5 COLUMNAS DONDE SE REPITE EL 10263 AUNQUE NO TENDRIA SENTIDO
--PORQUE PARA ESA ORDEN SOLO SE REPITE UNA VEZ LA CANTIDAD 
select od.OrderID,od.ProductID,od.Quantity
from [Order Details] as od
where od.OrderID=10263;



--39
--Based on the previous question, we now want to show details of the order, for orders that match the above
--criteria. 
select o.OrderID,od.ProductID,od.UnitPrice,od.Quantity,od.Discount
from Orders as o,[Order Details] as od
where o.OrderID in (select od.OrderID
from [Order Details] as od inner join (select * from [Order Details] as od1 where od1.Quantity>=60 )as od1
on (od.OrderID=od1.OrderID
and  od.Quantity=od1.Quantity
and not od.ProductID=od1.ProductID
)
group by od.OrderID,od.Quantity)
AND o.OrderID=od.OrderID;

--otra opcion
with OrdersRepeat(OrderID)
as (select od.OrderID
from [Order Details] as od inner join (select * from [Order Details] as od1 where od1.Quantity>=60 )as od1
on (od.OrderID=od1.OrderID
and  od.Quantity=od1.Quantity
and not od.ProductID=od1.ProductID
)
group by od.OrderID,od.Quantity
)
select o.OrderID,od.ProductID,od.UnitPrice,od.Quantity,od.Discount
from Orders as o,[Order Details] as od
where o.OrderID in (select * from OrdersRepeat)
and o.OrderID=od.OrderID;

--40
--Here's another way of getting the same results as in the previous problem, using a derived table instead of
--a CTE. However, there's a bug in this SQL. It returns 20 rows instead of 16. Correct the SQL.
--Problem SQL:
select od.OrderID,od.ProductID,od.UnitPrice,od.Quantity,od.Discount
from [Order Details] as od inner join 
(Select OrderID
 From [Order Details]
 Where Quantity >= 60
 Group By OrderID, Quantity
 Having Count(*) > 1
 ) PotentialProblemOrders
 on PotentialProblemOrders.OrderID = od.OrderID
Order by OrderID, od.ProductID;
-- ---------------------------------------------------------------
--41
--Some customers are complaining about their orders arriving late. Which orders are late?
--OrderID OrderDate RequiredDate ShippedDate
select o.OrderID, o.OrderDate, o.RequiredDate,o.ShippedDate
from Orders as o
where o.RequiredDate<o.ShippedDate;
--42
--Some salespeople have more orders arriving late than others. Maybe they're not following up on the order
--process, and need more training. Which salespeople have the most orders arriving late?
--EmployeeID LastName TotalLateOrders
select o.EmployeeID , e.LastName ,count(o.OrderID) as TotalLateOrders
from Orders as o inner join Employees as e
on o.EmployeeID=e.EmployeeID
where o.RequiredDate<o.ShippedDate
group by o.EmployeeID,e.LastName
order by TotalLateOrders desc;


--43
--Andrew, the VP of sales, has been doing some more thinking some more about the problem of late orders.
--He realizes that just looking at the number of orders arriving late for each salesperson isn't a good idea. It
--needs to be compared against the total number of orders per salesperson. Return results like the following:
--EmployeeID LastName AllOrders LateOrders

select o.EmployeeID, count(o.OrderID) 
from Orders as o
group by o.EmployeeID;


select o.EmployeeID , e.LastName ,tpe.TotalOrders as AllOrders,count(o.OrderID) as LateOrders
from Orders as o inner join Employees as e
on o.EmployeeID=e.EmployeeID
inner join (select o.EmployeeID, count(o.OrderID) as TotalOrders 
from Orders as o
group by o.EmployeeID) as tpe
on tpe.EmployeeID= o.EmployeeID
where o.RequiredDate<o.ShippedDate
group by o.EmployeeID,e.LastName,tpe.TotalOrders
order by o.EmployeeID;
--41
--Some customers are complaining about their orders arriving late. Which orders are late?

select o.OrderID,o.OrderDate,o.RequiredDate,o.ShippedDate
from Orders as o
where o.RequiredDate<o.ShippedDate;

select e.EmployeeID,o.OrderID,o.OrderDate,o.RequiredDate,o.ShippedDate
from Orders as o inner join Employees as e
on o.EmployeeID= e.EmployeeID
where o.RequiredDate<o.ShippedDate
order by e.EmployeeID;

--42
--Some salespeople have more orders arriving late than others. Maybe they're not following up on the order
--process, and need more training. Which salespeople have the most orders arriving late?
with LateOrders(OrderID)
as (select o.OrderID
from Orders as o
where o.RequiredDate<o.ShippedDate)
select e.EmployeeID,e.LastName,count(o.OrderID) as TotalOrdersLate
from Orders as o inner join Employees as e
on o.EmployeeID=e.EmployeeID
inner join LateOrders as lo
on o.OrderID=lo.OrderID
group by e.EmployeeID,e.LastName
order by TotalOrdersLate desc;




--43
--Andrew, the VP of sales, has been doing some more thinking some more about the problem of late orders.
--He realizes that just looking at the number of orders arriving late for each salesperson isn't a good idea. It
--needs to be compared against the total number of orders per salesperson. Return results like the following:
--EmployeeID LastName AllOrders LateOrders





with LateOrders(OrderID)
as (select o.OrderID
from Orders as o
where o.RequiredDate<o.ShippedDate)
select e.EmployeeID,e.LastName,toO.totalOrders as AllOrders,count(o.OrderID) as LateOrders
from Orders as o inner join Employees as e
on o.EmployeeID=e.EmployeeID
inner join LateOrders as lo
on o.OrderID=lo.OrderID
inner join (select e.EmployeeID,count(o.OrderID) as totalOrders
from Orders as o inner join Employees as e
on o.EmployeeID=e.EmployeeID 
group by e.EmployeeID) as toO
on e.EmployeeID=toO.EmployeeID 
group by e.EmployeeID,e.LastName,toO.totalOrders
order by e.EmployeeID;

--extra
select e.EmployeeID,count(o.OrderID)
from Orders as o inner join Employees as e
on o.EmployeeID=e.EmployeeID 
group by e.EmployeeID;

--extra
select e.EmployeeID,count(o.OrderID) LateOrders
from Orders as o inner join Employees as e
on o.EmployeeID= e.EmployeeID
where o.RequiredDate<o.ShippedDate
group by (e.EmployeeID);

--46
--There's an employee missing in the answer from the problem above. Fix the SQL to show all employees
--who have taken orders.
--EmployeeID LastName AllOrders LateOrders PercentLateOrders

select o.EmployeeID , e.LastName ,tpe.TotalOrders as AllOrders,o.LateOrders, cast(o.LateOrders as float)/cast(tpe.TotalOrders as float) as PercentLateOrders 
from (select o.EmployeeID,count(o.OrderID) as LateOrders 
from Orders as o
where o.RequiredDate<o.ShippedDate
group by o.EmployeeID) as o
inner join Employees as e
on o.EmployeeID=e.EmployeeID
inner join (select o.EmployeeID, count(o.OrderID) as TotalOrders 
from Orders as o
group by o.EmployeeID) as tpe
on tpe.EmployeeID= o.EmployeeID
group by o.EmployeeID,e.LastName,tpe.TotalOrders,o.LateOrders
order by o.EmployeeID;


--47
--Late orders vs. total orders - fix decimal
--So now for the PercentageLateOrders, we get a decimal value like we should. But to make the output
--easier to read, let's cut the PercentLateOrders off at 2 digits to the right of the decimal point.

select o.EmployeeID , e.LastName ,tpe.TotalOrders as AllOrders,o.LateOrders,
-- round(cast(o.LateOrders as float)/cast(tpe.TotalOrders as float),2,1) as PercentLateOrders 
 convert(decimal(10,2),cast(o.LateOrders as float)/cast(tpe.TotalOrders as float)) as PercentLateOrders
from (select o.EmployeeID,count(o.OrderID) as LateOrders 
from Orders as o
where o.RequiredDate<o.ShippedDate
group by o.EmployeeID) as o
inner join Employees as e
on o.EmployeeID=e.EmployeeID
inner join (select o.EmployeeID, count(o.OrderID) as TotalOrders 
from Orders as o
group by o.EmployeeID) as tpe
on tpe.EmployeeID= o.EmployeeID
group by o.EmployeeID,e.LastName,tpe.TotalOrders,o.LateOrders
order by o.EmployeeID;

--48
--Andrew Fuller, the VP of sales at Northwind, would like to do a sales campaign for existing customers.
--He'd like to categorize customers into groups, based on how much they ordered in 2016. Then, depending
--on which group the customer is in, he will target the customer with different sales materials.
--The customer grouping categories are 0 to 1,000, 1,000 to 5,000, 5,000 to 10,000, and over 10,000.
--A good starting point for this query is the answer from the problem “High-value customers - total orders.
--We don’t want to show customers who don’t have any orders in 2016.
--Order the results by CustomerID
--2014==1996
--CustomerID CompanyName TotalOrderAmount CustomerGroup

select i.CustomerID,i.CompanyName,i.TotalOrderAmount,
	CustomerGroup=
	case
		when i.TotalOrderAmount >= 0 and  i.TotalOrderAmount <= 1000 then 'Low'
		when i.TotalOrderAmount > 1000 and i.TotalOrderAmount<= 5000 then 'Medium'
		when i.TotalOrderAmount > 5000 and i.TotalOrderAmount<=10000 then 'High'
		when i.TotalOrderAmount > 10000 then 'Very High'
	end
from 
(select o.CustomerID,c.CompanyName, sum(od.Quantity*od.UnitPrice) as TotalOrderAmount
from [Order Details] as od inner join (select o.CustomerID,o.OrderID from orders as o where year(o.OrderDate)=1998) as o
on od.OrderID=o.OrderID
inner join Customers as c
on c.CustomerID=o.CustomerID
group by o.CustomerID,c.CompanyName) as i
group by i.CustomerID,i.CompanyName,i.TotalOrderAmount
order by CustomerGroup;

