//Hiển thị doanh thu bán ra của chi nhánh 4 trong 1 khoảng thời gian '2023-02-20' và '2023-02-21'
select purchase_branch_id as "Ma chi nhanh", sum(total_amount) as "Doanh thu chi nhanh" from "order".orders
where purchase_branch_id = 4 and order_date between '2023-02-20' and '2023-02-21'
group by purchase_branch_id

//Hiển thị doanh thu bán ra của 1 sản phẩm trong 1 khoảng thời gian '2023-02-20' và '2023-02-21'
select p.prod_id as "Ma san pham", sum(total_amount) as "Doanh thu" from "order".orders as o
join "product".product_instance p on p.order_id = o.order_id
where p.prod_id = 1 and o.order_date between '2023-02-20' and '2023-02-21'
group by p.prod_id


//Sản phẩm nào bán được bao nhiêu từ ngày '20/02/2023' đến '21/02/2023'
select prod_id as "Ma san pham", count(prod_id) as "So luong san pham da ban" from "product".product_instance p
join "order".orders o on p.order_id = o.order_id
where prod_id = 1 and order_date between '2023-02-20' and '2023-02-21'
group by prod_id



//Sản phẩm nào bán được bao nhiêu trong 1 chi nhánh từ ngày '20/02/2023' đến '21/02/2023'
select prod_id as "Ma san pham", o.purchase_branch_id as "Ma chi nhanh", count(prod_id) as "So luong san pham da ban" from "product".product_instance p
join "order".orders o on p.order_id = o.order_id
where prod_id = 1 and order_date between '2023-02-20' and '2023-02-21' and o.purchase_branch_id = 5
group by prod_id, o.purchase_branch_id










