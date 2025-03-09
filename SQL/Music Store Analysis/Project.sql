/*	Question Set 1 - Easy */

/* 1. Who is the senior most employee based on job title? */
select last_name, first_name,levels
from employee
order by levels desc;

-- 2. Which countries have the most Invoices?
select * from invoice

select billing_country, count(customer_id) as invoice_count
from invoice
group by billing_country
order by invoice_count desc;

-- 4. What are top 3 values of total invoice?
select total
from invoice
order by total desc
limit 3;

/* 5. Which city has the best customers? We would like to throw a promotional Music
 Festival in the city we made the most money. Write a query that returns one city that
 has the highest sum of invoice totals. Return both the city name & sum of all invoice
 totals */
 
select sum(total) as money, billing_city 
from invoice
group by billing_city
order by money desc

/* 6. Who is the best customer? The customer who has spent the most money will be
 declared the best customer. Write a query that returns the person who has spent the
 most money */
 
select customer.customer_id, customer.first_name, customer.last_name,sum(invoice.total) as spend  from invoice
join customer 
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by spend desc 
limit 1



/*	Question Set 2 - Medium */

/* 1. Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. 
Return your list ordered alphabetically by email starting with A */

/* Method 1 */
select DISTINCT genre.name, email,customer.first_name, customer.last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
order by email 


/* Method 2 */

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;



/* 2. Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */


SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


select Artist.Name,Artist.Artist_Id, count(Track_Id) as total
from Artist
join Album on Artist.Artist_Id = Album.Artist_Id
join Track on Album.Album_Id = Track.Album_Id
join Genre on Track.Genre_Id = Genre.Genre_Id
where Track_Id in (
SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
group by 2
order by total desc
limit 10;

/*3. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first*/


select name , milliseconds
from Track t
where t.milliseconds > (
select avg(milliseconds) as base
from Track
)


/* Advanced
1.Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent */


SELECT c.customer_id, c.first_name, c.last_name, ar.name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN artist ar ON ar.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


/* Q2: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres. */

WITH popular_genre as (
SELECT customer.country, genre.name, genre.genre_id  ,COUNT(genre.name) AS purchases, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(genre.name) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 1,2,3)


SELECT * FROM popular_genre WHERE RowNo <= 1
order by purchases desc





