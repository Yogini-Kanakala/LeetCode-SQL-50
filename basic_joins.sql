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

-- 197. Rising Temperature

select w1.id from weather as w1 
inner join 
weather as w2 
on w1.recordDate= w2.recordDate+ INTERVAL  '1 day'
where w1.temperature> w2.temperature

-- 577. Employee Bonus
# Write your MySQL query statement below
select e.name, b.bonus
from employee e left join bonus b 
on e.empId=b.empId
where b.bonus<1000 or b.bonus is null

-- 570. Managers with at Least 5 Direct Reports

with data as (
select managerId
from employee
group by managerId
having count(id)>=5
)
select e.name
from data inner join employee e on e.id=data.managerId

-- 1934. Confirmation Rate
SELECT 
    s.user_id,
    ROUND(
        COALESCE(SUM(CASE WHEN c.action = 'confirmed' THEN 1 ELSE 0 END)::decimal 
        / NULLIF(COUNT(c.action), 0), 0), 2
    ) AS confirmation_rate
FROM 
    signups s
LEFT JOIN 
    confirmations c 
ON 
    s.user_id = c.user_id
GROUP BY 
    s.user_id;