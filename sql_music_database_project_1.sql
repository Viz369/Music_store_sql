/* Q1: Who is the senior most employee based on job title? */

Select *
from employee
order by levels desc 
;

/* Q2: Which countries have the most invoices ? */

select count(*) as c , billing_country 
from invoice
group by billing_country
order by c desc; 

/* Q3: What is the average invoice value? */

select round(avg(total),2)as avg_invoice from invoice 
order by total desc
;

/* Q4: What are the top 3 cities with highest sales? (city with highest invoice)*/

select round(sum(total) ,2) as invoice_total , billing_city
from invoice
group by billing_city
order by invoice_total desc 
limit 3;

/* Q5: TOP 3 Customers (one who has spent most) */

select i.customer_Id, c.first_name,c.last_name ,c.city,
c.country, round(sum(i.total),2) as total
from invoice i join customer c 
on i.customer_id = c.customer_id
group by 1,2,3,4,5
order by total desc
limit 3 ;


-- Q6: Write query to return email, first_name,last_name & genre of all rock music listeners
-- order by email alphabetically

select distinct c.email,c.first_name, c.last_name 
from customer c join invoice i 
on c.customer_id = i.customer_id
join invoice_line il on
i.invoice_Id = il.invoice_Id
 where il.track_id in (select t.track_id from track t join genre g
 		 			  on t.genre_id = g.genre_id
                    where g.name ='Rock')
order by email;
                      
-- Q7: Invite artists who have written most rock music in our dataset.
-- Return artist_name and total track count of top 10 rock bands

select ar.artist_id,ar.name , count(t.track_id) as total
from track t  join album2 al 
on al.album_id = t.album_id
join artist ar 
 on ar.artist_Id = al.artist_id     
join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
group by ar.artist_id,ar.name                      
order by total desc
limit 10;

-- Q8: What is avg song_length of Top 10 songs based on sales.

with avg_song_length as 
(select t.name ,round(sum(il.track_id*il.quantity),2) as quantity_sold,
 round(t.milliseconds/1000,2) as song_length_in_seconds
from track t join invoice_line il
using(track_id)
group by 1,3
order by quantity_sold desc
limit 10)
select concat(floor(avg(song_length_in_seconds)/60),'m',
floor(MOD(avg(song_length_in_seconds),60)),'s')
as average_length from avg_song_length
; 



-- Q9: Find how much amount is spent by each customer on highest earning artist?
-- return customer name, artist name  and total spent 

with best_selling_artist as (
select ar.artist_id as artist_id,ar.name as artist_name ,
sum(il.unit_price*il.quantity) as money_spent
from invoice_line il join track t 
on il.track_id = t.track_id
join album2 al on al.album_id = t.album_id
join artist ar on ar.artist_id = al.artist_id
group by 1,2
order by 3 desc
limit 1
)

select c.customer_id,c.first_name, c.last_name , bsa.artist_name,
sum(il.unit_price*il.quantity) as amount 
from invoice_line il join invoice i 
on il.invoice_id = i.invoice_id 
join customer c on c.customer_id  = i.customer_id
join track t on t.track_id = il.track_id
join album2 al on al.album_id  =t.album_id
join best_selling_artist bsa on bsa.artist_id  = al.artist_id
group by 1,2,3,4
order by 5 desc;

/* Q10: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres. */

with highest_purchases as (
select c.country,g.name,g.genre_Id,count(il.quantity) as purchases,
dense_rank() OVER(partition by C.COUNTRY order by count(il.quantity) desc) as rnk 
from customer c join invoice i 
on c.customer_id  = i.customer_id 
join invoice_line il on il.invoice_id  = i.invoice_id
join track t on t.track_id =  il.track_id 
join genre g on g.genre_id = t.genre_id
group by 1,2,3
order by 1 
) select * from highest_purchases where rnk<=1;

/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with customer_country as(
select c.customer_id,c.first_name,c.last_name,i.billing_country,sum(i.total) as total_spend,
dense_rank() over(partition by i.billing_country order by sum(i.total) desc) as rnk
from invoice i join customer c 
on i.customer_id = c.customer_id
group by 1,2,3,4
order by 4 
) select * from customer_country where rnk<=1;
