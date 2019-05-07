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


