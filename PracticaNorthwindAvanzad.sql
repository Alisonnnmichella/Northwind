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
--amount which includes the discount.select o.CustomerID,cus.CompanyName,sum(ord.UnitPrice*ord.Quantity) as TotalWithoutDiscount,
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
--quotas. Show all orders made on the last day of the month. Order by EmployeeID and OrderID--EmployeeID OrderID OrderDate

select o.EmployeeID,o.OrderID,o.OrderDate
from Orders as o
where (o.OrderDate)=EOMONTH(o.OrderDate)
order by o.EmployeeID,o.OrderID

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



