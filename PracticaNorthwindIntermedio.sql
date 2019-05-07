
select * from Products;
--20
--For this problem, we’d like to see the total number of products in each category. Sort the results by the
--total number of products, in descending order.
select c.CategoryName,count(p.CategoryID) as TotalProducts
from Categories as c inner join Products as p
on c.CategoryID=p.CategoryID
group by c.CategoryName
order by TotalProducts desc;
--21
--In the Customers table, show the total number of customers per Country and City.

select c.Country,c.City, count(c.customerID) as TotalCustomers
from Customers as c
group by c.Country,c.City;
--22
--What products do we have in our inventory that should be reordered? For now, just use the fields
--UnitsInStock and ReorderLevel, where UnitsInStock is less than the ReorderLevel, ignoring the fields
--UnitsOnOrder and Discontinued.
--Order the results by ProductID.
select p.ProductID,p.ProductName,p.UnitsInStock,p.ReorderLevel
from Products as p 
where p.UnitsInStock<p.ReorderLevel
order by p.ProductID;
--23
--Now we need to incorporate these fields—UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued—
--into our calculation. We’ll define “products that need reordering” with the following:
--
--UnitsInStock plus UnitsOnOrder are less than or equal to ReorderLevel
--The Discontinued flag is false (0).

select p.ProductID, p.ProductName,p.UnitsInStock,p.UnitsOnOrder,p.ReorderLevel,p.Discontinued
from Products as p
where p.UnitsInStock+p.UnitsOnOrder<=p.ReorderLevel
and p.Discontinued=0;

--24
--A salesperson for Northwind is going on a business trip to visit customers, and would like to see a list of
--all customers, sorted by region, alphabetically.
--However, he wants the customers with no region (null in the Region field) to be at the end, instead of at
--the top, where you’d normally find the null values. Within the same region, companies should be sorted
--by CustomerID.

select c.CustomerID,c.CompanyName,c.Region
from Customers as c
order by  
	(case when Region is not null   then 0 else 1 end),
	c.Region,c.CustomerID;

--25
--Some of the countries we ship to have very high freight charges. We'd like to investigate some more
--shipping options for our customers, to be able to offer them lower freight charges. Return the three ship
--countries with the highest average freight overall, in descending order by average freight.
select top 3 o.ShipCountry, avg(o.Freight)
from  Orders as o
group by o.ShipCountry
order by avg(Freight) desc;

--26/27
--We're continuing on the question above on high freight charges. Now, instead of using all the orders we
--have, we only want to see orders from the year 1997. 
--???????????????????

select o.ShipCountry,avg(o.Freight) as AverageFreigth
from  Orders as o
where year(o.OrderDate)=1997
group by o.ShipCountry
order by avg(o.Freight) desc;

--28
--We're continuing to work on high freight charges. We now want to get the three ship countries with the
--highest average freight charges. But instead of filtering for a particular year, we want to use the last 12
--months of order data, using as the end date the last OrderDate in Orders. 


select top 3 o.ShipCountry,avg(o.Freight) as AverageFreigth
from  Orders as o
where o.OrderDate >= DATEADD(month, -12, (select max(OrderDate) from Orders))
group by o.ShipCountry
order by avg(o.Freight) desc;

--29
--We're doing inventory, and need to show information like the below, for all orders. Sort by OrderID and
--Product ID.
--EmployeeID LastName OrderID ProductName Quantity

select o.EmployeeID, e.LastName, o.OrderID, p.ProductName, od.Quantity
from Orders as o inner join [Order Details] as od
on o.OrderID=od.OrderID
inner join Employees as e
on o.EmployeeID=e.EmployeeID 
inner join Products as p
on od.ProductID=p.ProductID
order by o.OrderID,od.ProductID;

--30
--There are some customers who have never actually placed an order. Show these customers.beginselect * from Customers where CustomerID not in (select CustomerID from Orders);select c.CustomerID as Customers_CustomerID, o.CustomerID as Orders_CustomerID  from Customers as c left  join Orders as oon c.CustomerID=o.CustomerIDwhere o.CustomerID is null;

--31
--One employee (Margaret Peacock, EmployeeID 4) has placed the most orders. However, there are some
--customers who've never placed an order with her. Show only those customers who have never placed an
--order with her.

select CustomerID
from Customers 
where CustomerID not in (select CustomerID from Orders where EmployeeId=4 );

select c.CustomerID, o.CustomerID
from Customers as c left join Orders as o
on (c.CustomerID=o.CustomerID
	and o.EmployeeID=4)
where o.CustomerID is null;







