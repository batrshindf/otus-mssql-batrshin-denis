/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT YEAR(OrderDate) AS 'Год продажи'
    , MONTH(OrderDate) AS 'Месяц продажи'
    , AVG(SIL.UnitPrice) AS 'Средняя цена за месяц по всем товарам'
    , SUM(ExtendedPrice) AS 'Общая сумма продаж за месяц'
FROM Sales.Invoices AS SI
    INNER JOIN Sales.Orders AS SO ON SO.OrderID = SI.OrderID
    INNER JOIN Sales.InvoiceLines AS SIL ON SI.InvoiceID = SIL.InvoiceID
GROUP BY YEAR(SO.OrderDate),
    MONTH(SO.OrderDate)
ORDER BY [Год продажи] ASC, [Месяц продажи] ASC

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT YEAR(OrderDate) AS 'Год продажи'
    , MONTH(OrderDate) AS 'Месяц продажи'
    , SUM(ExtendedPrice) AS 'Общая сумма продаж за месяц'
FROM Sales.Invoices AS SI
    INNER JOIN Sales.Orders AS SO ON SO.OrderID = SI.OrderID
    INNER JOIN Sales.InvoiceLines AS SIL ON SI.InvoiceID = SIL.InvoiceID
GROUP BY YEAR(SO.OrderDate),
    MONTH(SO.OrderDate)
HAVING SUM(ExtendedPrice) > 4600000
ORDER BY [Год продажи] ASC, [Месяц продажи] ASC

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT YEAR(OrderDate) AS 'Год продажи'
    , MONTH(OrderDate) AS 'Месяц продажи'
    , [Description] AS 'Наименование товара'
    , SUM(ExtendedPrice) AS 'Сумма продаж'
    , MIN(InvoiceDate) AS 'Дата первой продажи'
    , SUM(Quantity) AS 'Количество проданного'
FROM Sales.Invoices AS SI
    INNER JOIN Sales.Orders AS SO ON SO.OrderID = SI.OrderID
    INNER JOIN Sales.InvoiceLines AS SIL ON SI.InvoiceID = SIL.InvoiceID
GROUP BY YEAR(OrderDate),
    MONTH(OrderDate),
    [Description]
HAVING SUM(Quantity) < 50
ORDER BY [Год продажи] ASC
    , [Месяц продажи] ASC
    , [Наименование товара] ASC

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
