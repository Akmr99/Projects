# SQL Query Collection for Music Store Database

![Music Store](https://github.com/Akmr99/Projects/blob/main/SQL/Music%20Store%20Analysis/music.jpg?raw=true)

This repository contains SQL queries designed to analyze a music store database. The queries are categorized into three difficulty levels: Easy, Moderate, and Advanced.

## Question Set 1 - Easy

### Q1: Senior Most Employee by Job Title
```sql
SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1;
```

### Q2: Countries with the Most Invoices
```sql
SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;
```

### Q3: Top 3 Invoice Totals
```sql
SELECT total 
FROM invoice
ORDER BY total DESC;
```

### Q4: City with Highest Revenue
```sql
SELECT billing_city, SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;
```

### Q5: Best Customer (Highest Spending)
```sql
SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;
```

---
## Question Set 2 - Moderate

### Q1: Rock Music Listeners (By Email)
#### Method 1
```sql
SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN (
    SELECT track_id FROM track
    JOIN genre ON track.genre_id = genre.genre_id
    WHERE genre.name LIKE 'Rock'
)
ORDER BY email;
```
#### Method 2
```sql
SELECT DISTINCT email AS Email, first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoiceline ON invoiceline.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoiceline.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;
```

### Q2: Top 10 Rock Music Artists
```sql
SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;
```

### Q3: Tracks Longer than Average Length
```sql
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) FROM track
)
ORDER BY milliseconds DESC;
```

---
## Question Set 3 - Advanced

### Q1: Customer Spending on Artists
```sql
WITH best_selling_artist AS (
    SELECT artist.artist_id, artist.name, SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY 1
    ORDER BY 3 DESC
    LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC;
```

### Q2: Most Popular Genre by Country
#### Using CTE
```sql
WITH popular_genre AS (
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY 2, 3, 4
)
SELECT * FROM popular_genre WHERE RowNo <= 1;
```

### Q3: Top-Spending Customers by Country
#### Using CTE
```sql
WITH customer_with_country AS (
    SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending,
    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
    FROM invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY 1, 2, 3, 4
)
SELECT * FROM customer_with_country WHERE RowNo <= 1;
```


