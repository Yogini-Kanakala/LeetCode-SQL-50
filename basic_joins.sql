-- 1378. Replace Employee ID With The Unique Identifier

select euni.unique_id, e.name 
from employees as e left join EmployeeUNI as euni on e.id=euni.id


-- 1068. Product Sales Analysis I

SELECT p.product_name, s.year, s.price FROM Sales s
LEFT JOIN Product p 
on s.product_id = p.product_id

-- 1581. Customer Who Visited but Did Not Make Any Transactions
select v.customer_id,  COUNT(v.visit_id) AS count_no_trans 
from visits as v left join transactions as t
on v.visit_id = t.visit_id
where t.transaction_id is null
group by  v.customer_id

