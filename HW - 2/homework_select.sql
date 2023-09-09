/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT StockItemID, StockItemName
FROM Warehouse.StockItems
WHERE StockItemName LIKE '%urgent%' OR StockItemName LIKE 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT DISTINCT ps.SupplierID, ps.SupplierName
FROM Purchasing.Suppliers AS ps
    INNER JOIN Purchasing.PurchaseOrders AS ppo ON ps.SupplierID = ppo.SupplierID

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

-- Постраничная выборка
DECLARE
    @pagesize BIGINT = 10, -- размер страницы
    @pagenum BIGINT = 1; -- номер страницы

SELECT DISTINCT SO.OrderID
    , FORMAT(SO.OrderDate, 'dd.MM.yyyy') AS OrderDate
    , MONTH(OrderDate) as 'OrderDate(Month)'
    , DATEPART(QUARTER, OrderDate) AS 'OrderDate(Quarter)'
    -- DATEPART()
    , CustomerName AS Customer
FROM Sales.Orders AS SO
    INNER JOIN Sales.OrderLines AS SOL ON SO.OrderID = SOL.OrderID
    INNER JOIN Sales.Customers AS SC ON SO.OrderID = SC.CustomerID
ORDER BY [OrderDate(Quarter)] ASC, OrderDate ASC
    OFFSET (@pagenum - 1) * @pagesize ROWS
    FETCH NEXT @pagesize ROWS ONLY

-- Уточнить по триместру и по выводу данных, т.к. всего 663 строки

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT ADM.DeliveryMethodName
    , PPO.ExpectedDeliveryDate
    , PS.SupplierName
    , AP.FullName AS ContactPerson
FROM Purchasing.PurchaseOrders AS PPO
    INNER JOIN Purchasing.Suppliers AS PS ON PPO.SupplierID = PS.SupplierID
    INNER JOIN Application.DeliveryMethods AS ADM ON PPO.DeliveryMethodID = ADM.DeliveryMethodID
    INNER JOIN Application.People AS AP ON PPO.ContactPersonID = AP.PersonID
WHERE (PPO.ExpectedDeliveryDate BETWEEN '20130115' AND '20130131' )
    AND (ADM.DeliveryMethodName = 'Air Freight' OR ADM.DeliveryMethodName = 'Refrigerated Air Freight')
    AND PPO.IsOrderFinalized = 1



/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT TOP (10) SC.CustomerName
    , AP.FullName AS SalespersonPerson 
FROM Sales.Orders AS SO
    INNER JOIN Sales.Customers AS SC ON SO.CustomerID = SC.CustomerID
    INNER JOIN Application.People AS AP ON SO.SalespersonPersonID = AP.PersonID
ORDER BY SO.OrderDate DESC

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT SC.CustomerID
    , SC.CustomerName
    , SC.PhoneNumber
FROM Warehouse.StockItemTransactions AS WSIT
    INNER JOIN Sales.Customers AS SC ON WSIT.CustomerID = SC.CustomerID
    INNER JOIN Warehouse.StockItems AS WSI ON WSIT.StockItemID = WSI.StockItemID
WHERE WSI.StockItemName = 'Chocolate frogs 250g'
