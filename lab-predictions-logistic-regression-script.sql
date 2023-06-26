with film_rental_join as(
	select film_id, store_id,
		date_format(rental_date, "%m") rental_m,
		rental_duration, length, rating, special_features
	from film
	join inventory using(film_id)
	left join rental using(inventory_id)
),
cte_2 as(
	select film_id, 
		count(case when store_id = '1' then film_id end) as 'rentals_store_1',
		count(case when store_id = '2' then film_id end) as 'rentals_store_2',
		rental_duration, length, rating, special_features
	from film_rental_join
	where rental_m is not null
	group by film_id
	order by film_id
),
cte_3 as(
select distinct film_id, case when rental_m = '02' then 1 end as 'rented_last_month'
from film_rental_join
where rental_m is not null
having rented_last_month = 1
order by film_id
)
select case when rented_last_month = 1 then 1 else 0 end as rented_last_month,
    rentals_store_1, rentals_store_2,
	rental_duration, length, rating,
    case when special_features like '%Trailers%' then 1 else 0 end as trailers,
    case when special_features like '%Deleted Scenes%' then 1 else 0 end as deleted_scenes,
    case when special_features like '%Behind the Scenes%' then 1 else 0 end as behind_scenes
from cte_2
left join cte_3 using(film_id);