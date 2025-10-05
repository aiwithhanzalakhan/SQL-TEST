









----Q1. List top 5 customers by total order amount.
-----Retrieve the top 5 customers who have spent the most across all sales orders. Show CustomerID, CustomerName, and TotalSpent.



select TOP 5 
    s.customeriD,
	C.Name  CustomerName,
    SUM(s.TotalAmount)  Totalspent


from 
     dbo.Customer C
	
	inner join dbo.SalesOrder  s
		on C.CustomerID = s.CustomerID
Group by s.CustomerID, 
       C.Name
order by TotalSpent DESC;




-- Q2. Find the number of products supplied by each supplier.
-- Display SupplierID, SupplierName, and ProductCount. Only include suppliers that have more than 10 products.

select  p.SupplierID,
s.Name,
Count(p.SupplierID)  ProductCount
from dbo.Supplier  s
	inner join dbo.PurchaseOrder  p
		on s.SupplierID = p.SupplierID
group by
p.SupplierID,
s.Name
having 
Count(p.SupplierID) > 10





-- Q3. Identify products that have been ordered but never returned.
-- Show ProductID, ProductName, and total order quantity.



SELECT 
    p.ProductID,
    p.Name  ProductName,
    SUM(sd.Quantity)  TotalOrderQuantity
FROM dbo.Product  p
INNER JOIN dbo.ShipmentDetail  sd
    ON p.ProductID = sd.ProductID
WHERE p.ProductID NOT IN (
    SELECT ProductID 
    FROM dbo.ReturnDetail
)
GROUP BY p.ProductID, p.Name;


-- Q4. For each category, find the most expensive product.
-- Display CategoryID, CategoryName, ProductName, and Price. Use a subquery to get the max price per category.

select
c.CategoryID,
c.Name  CategoryName,
p.Name  ProductName ,
p.Price
from dbo.Product  p
	inner join dbo.Category  c
		on p.CategoryID = c.CategoryID

	where p.Price >= (
		select MAX(pt.Price) from dbo.Category cd
				inner join dbo.Product as pt
					on cd.CategoryID = pt.CategoryID
	)


-- Q5. List all sales orders with customer name, product name, category, and supplier.
-- For each sales order, display:
-- OrderID, CustomerName, ProductName, CategoryName, SupplierName, and Quantity.

SELECT s.OrderID,
c.Name  CustomerName,
p.Name  ProductName, 
ct.Name  CategoryName,
sp.Name  SupplierName, 
od.Quantity
FROM dbo.Customer c
	inner join dbo.SalesOrder s
		ON c.CustomerID = s.CustomerID
	inner join dbo.SalesOrderDetail od
		ON od.OrderID = s.OrderID
	inner join dbo.Product p
		ON p.ProductID = od.ProductID
	inner join dbo.Category ct
		ON ct.CategoryID = p.CategoryID
	inner join dbo.PurchaseOrderDetail pd
		ON pd.ProductID = p.ProductID
	inner join dbo.PurchaseOrder po
		ON po.OrderID = pd.OrderID
	inner join dbo.Supplier sp
		ON sp.SupplierID = po.SupplierID
ORDER BY s.OrderID;






-- Q6. Find all shipments with details of warehouse, manager, and products shipped.
-- Display:
-- ShipmentID, WarehouseName, ManagerName, ProductName, QuantityShipped, and TrackingNumber.

select 
sp.ShipmentID,
lc.Name as WarehouseName,
ep.Name as ManagerName ,
p.Name as ProductName, 
sh.Quantity ,
sp.TrackingNumber 
from dbo.Shipment sp
	inner join dbo.Warehouse as w
		ON w.WarehouseID = sp.WarehouseID
	inner join dbo.Employee as ep
		ON w.ManagerID = ep.EmployeeID
	inner join dbo.ShipmentDetail as sh
		ON sh.ShipmentID = sp.ShipmentID
	inner join dbo.Location as lc
		ON lc.LocationID = w.LocationID
	inner join dbo.Product as p
		ON p.ProductID = sh.ProductID



--Q7. Find the top 3 highest-value orders per customer using RANK(). 
--Display CustomerID, CustomerName, OrderID, and TotalAmount.

select Top 3
c.CustomerID,
c.Name   CustomerName , 
s.OrderID,
s.TotalAmount,
RANK()
over(

order by s.TotalAmount
) from dbo.Customer  c
	inner join dbo.SalesOrder  s
		on s.CustomerID = c.CustomerID








-- Q8. For each product, show its sales history with the previous and next sales quantities 
-- (based on order date). Display ProductID, ProductName, OrderID, OrderDate, Quantity, PrevQuantity, and NextQuantity.

select p.ProductID,
p.Name as ProductName, 
sr.OrderID, 
sr.OrderDate ,
sd.Quantity
from 
dbo.Product  p
		inner join dbo.SalesOrderDetail  sd
			on sd.ProductID = p.ProductID
		inner join dbo.SalesOrder  sr
			on sr.OrderID = sd.OrderID
Group by p.ProductID, p.Name, sr.OrderID, sr.OrderDate,  sd.Quantity
order by ProductID;





-- Q9. Create a view named vw_CustomerOrderSummary that shows for each customer:
-- CustomerID, CustomerName, TotalOrders, TotalAmountSpent, and LastOrderDate.


create view vw_CustomerOrderSummary 
select 
    cust.CustomerID,
    cust.Name  CustomerName,
    COUNT(ord.OrderID)  TotalOrders,
    SUM(ord.TotalAmount)  TotalAmountSpent,
    MAX(ord.OrderDate)  LastOrderDate
from
    dbo.Customer cust
JOIN 
    dbo.SalesOrder ord 
    ON cust.CustomerID = ord.CustomerID
Group by 
    cust.CustomerID, cust.Name;


Select * From vw_CustomerOrderSummary;

--

-- Q10. Write a stored procedure sp_GetSupplierSales that takes a SupplierID as input and returns the total sales amount 
-- for all products supplied by that supplier.
create procedure sp_GetSupplierSales
    @SupplierID INT

begin
    set nocount on;

    select 
        s.SupplierID,
        s.name  SupplierName,
        sum(sod.TotalAmount)  TotalSalesAmount
    from 
        Supplier s
        join PurchaseOrder po 
            on s.SupplierID = po.SupplierID
        join PurchaseOrderDetail pod 
            on po.OrderID = pod.OrderID
        join Product p 
            on pod.ProductID = p.ProductID
        join SalesOrderDetail sod 
            on p.ProductID = sod.ProductID
    where 
        s.SupplierID = @SupplierID
    group by 
        s.SupplierID, s.Name;
end;


exec sp_GetSupplierSales 5;

