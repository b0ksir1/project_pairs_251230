from fastapi import APIRouter, Form
import pymysql
import config
router = APIRouter()
# 260101. 1월 2일 DB에서 orders_date를 datetime으로 수정// 260102.반영 완료
# 260101. 1월 2일 DB에서 orders_status를 int로 추가// 260102.반영 완료

def connect():
    return pymysql.connect(
        host=config.DB_HOST,
        user=config.DB_USER,
        password=config.DB_PASSWORD,
        database=config.DB_NAME,
        charset="utf8"
    )

@router.get('/select')
async def select():
        conn = connect()
        curs = conn.cursor()    
        curs.execute(
            '''
            select 
            orders_id, 
            orders_customer_id, 
            orders_store_id, 
            orders_employee_id, 
            orders_product_id, 
            orders_quantity, 
            orders_number, 
            orders_payment, 
            orders_date,
            orders_status
            from orders
            '''
        )
        rows = curs.fetchall()
        conn.close()

        result = [{'orders_id' : row[0], 
                'orders_customer_id' : row[1], 
                'orders_store_id' : row[2], 
                'orders_employee_id' : row[3], 
                'orders_product_id' : row[4], 
                'orders_quantity' : row[5], 
                'orders_number' : row[6], 
                'orders_payment' : row[7], 
                'orders_date' : row[8],
                'orders_status' : row[9],
                } for row in rows]
        return {'results' : result}

# 매출 (s)
@router.get("/month")
async def month_sales():
        conn = connect()
        curs = conn.cursor(pymysql.cursors.DictCursor)

        sql = """
            SELECT
            COALESCE(SUM(orders_totalprice), 0) AS month_sales
            FROM orders
            WHERE orders_status = 1     
            AND orders_totalprice IS NOT NULL
            AND orders_date >= DATE_FORMAT(NOW(), '%Y-%m-01')
            AND orders_date <  DATE_ADD(DATE_FORMAT(NOW(), '%Y-%m-01'), 
            INTERVAL 1 MONTH);

            """
        curs.execute(sql)
        row = curs.fetchone()
        conn.close()

        return {"month_sales": row["month_sales"]}
# 매출 (e)

@router.get('/select/{customer_id}')
async def select(customer_id:int):
    try:
        conn = connect()
        curs = conn.cursor()    
        curs.execute(
            '''
            select 
            o.orders_id, 
            o.orders_customer_id, 
            o.orders_store_id, 
            o.orders_employee_id, 
            o.orders_product_id, 
            o.orders_quantity, 
            o.orders_number,
            o.orders_payment, 
            o.orders_date,
            o.orders_status,
            s.store_name,
            p.product_name
            from orders as o
                inner join product as p
                    on p.product_id = o.orders_product_id
                inner join store as s
                    on s.store_id = o.orders_store_id   
            where o.orders_customer_id = %s
            ''',(customer_id)
        )
        rows = curs.fetchall()

        result = [{'orders_id' : row[0], 
                'orders_customer_id' : row[1], 
                'orders_store_id' : row[2], 
                'orders_employee_id' : row[3], 
                'orders_product_id' : row[4], 
                'orders_quantity' : row[5], 
                'orders_number' : row[6], 
                'orders_payment' : row[7], 
                'orders_date' : row[8],
                'orders_status' : row[9],
                'store_name' : row[10],
                'product_name' : row[11],
                } for row in rows]
        return {'results' : result}
    finally:
        conn.close()

@router.get('/selectByCustomer/{customer_id}')
async def select(customer_id:int):
    try:
        conn = connect()
        curs = conn.cursor()    
        curs.execute(
            '''
            select o.orders_id, o.orders_quantity, o.orders_number, o.orders_payment, o.orders_date, o.orders_status, s.store_name, p.product_name, p.product_price, size.size_name, brand.brand_name, category.category_name, color.color_name
            from orders as o
                inner join product as p
                    on p.product_id = o.orders_product_id
                inner join store as s
                    on s.store_id = o.orders_store_id   
                inner join size
                    on size.size_id = p.product_size_id 
                 inner join category
					on category.category_id = p.product_category_id
				inner join brand
					on brand.brand_id = p.product_brand_id
                 inner join color
					on color.color_id = p.product_color_id   
            where o.orders_customer_id = %s
            ''',(customer_id)
        )
        rows = curs.fetchall()

        result = [{'orders_id' : row[0], 
                'orders_quantity' : row[1], 
                'orders_number' : row[2], 
                'orders_payment' : row[3], 
                'orders_date' : row[4], 
                'orders_status' : row[5], 
                'store_name' : row[6], 
                'product_name' : row[7], 
                'product_price' : row[8],
                'size_name' : row[9],
                'brand_name' : row[10],
                'category_name' : row[11],
                'color_name' : row[12],
                } for row in rows]
        return {'results' : result}
    finally:
        conn.close()

@router.get('/selectByStatus/{orders_status}')
async def select(orders_status:int):
    try:
        conn = connect()
        curs = conn.cursor()    
        curs.execute(
            '''
            select o.orders_id, o.orders_quantity, stock.stock_quantity, o.orders_number, o.orders_payment, o.orders_date, s.store_name, p.product_name, c.customer_name
            from orders as o
                inner join product as p
                    on p.product_id = o.orders_product_id
                inner join store as s
                    on s.store_id = o.orders_store_id   
                inner join stock
                    on orders_product_id = stock.stock_product_id
                 inner join customer as c
					on c.customer_id = o.orders_customer_id
            where o.orders_status = %s
            ''',(orders_status)
        )
        rows = curs.fetchall()

        result = [{'orders_id' : row[0], 
                'orders_quantity' : row[1], 
                'stock_quantity' : row[2], 
                'orders_number' : row[3], 
                'orders_payment' : row[4], 
                'orders_date' : row[5], 
                'store_name' : row[6], 
                'product_name' : row[7], 
                'customer_name' : row[8],
                } for row in rows]
        return {'results' : result}
    finally:
        conn.close()

@router.get('/selectRequestByStore/{store_id}')
async def select(store_id:int):
    try:
        conn = connect()
        curs = conn.cursor()    
        curs.execute(
            '''
            select o.orders_id, o.orders_quantity, stock.stock_quantity, o.orders_number, o.orders_payment, o.orders_date, s.store_name, p.product_name, c.customer_name, o.orders_product_id 
            from orders as o
                inner join product as p
                    on p.product_id = o.orders_product_id
                inner join store as s
                    on s.store_id = o.orders_store_id   
                inner join stock
                    on orders_product_id = stock.stock_product_id
                 inner join customer as c
					on c.customer_id = o.orders_customer_id
            where o.orders_status = 0 and o.orders_store_id = %s
            ''',(store_id)
        )
        rows = curs.fetchall()

        result = [{'orders_id' : row[0], 
                'orders_quantity' : row[1], 
                'stock_quantity' : row[2], 
                'orders_number' : row[3], 
                'orders_payment' : row[4], 
                'orders_date' : row[5], 
                'store_name' : row[6], 
                'product_name' : row[7], 
                'customer_name' : row[8],
                'product_id' : row[9],
                } for row in rows]
        return {'results' : result}
    finally:
        conn.close()
@router.get('/selectRequestByStoreKeyword')
async def select(store_id:int, search:str):
    try:
        conn = connect()
        curs = conn.cursor()    
        curs.execute(
            '''
            select o.orders_id, o.orders_quantity, stock.stock_quantity, o.orders_number, o.orders_payment, o.orders_date, s.store_name, p.product_name, c.customer_name, o.orders_product_id 
            from orders as o
                inner join product as p
                    on p.product_id = o.orders_product_id
                inner join store as s
                    on s.store_id = o.orders_store_id   
                inner join stock
                    on orders_product_id = stock.stock_product_id
                 inner join customer as c
					on c.customer_id = o.orders_customer_id
            where o.orders_status = 0 and o.orders_store_id = %s c.customer_name like %s 
            ''',(store_id, search)
        )
        rows = curs.fetchall()

        result = [{'orders_id' : row[0], 
                'orders_quantity' : row[1], 
                'stock_quantity' : row[2], 
                'orders_number' : row[3], 
                'orders_payment' : row[4], 
                'orders_date' : row[5], 
                'store_name' : row[6], 
                'product_name' : row[7], 
                'customer_name' : row[8],
                'product_id' : row[9],
                } for row in rows]
        return {'results' : result}
    finally:
        conn.close()

@router.post('/insert')
async def insert(orders_customer_id :int = Form(...), orders_store_id:int = Form(...), orders_employee_id:int = Form(...), orders_product_id:int = Form(...), orders_quantity:int = Form(...), orders_number:str = Form(...), orders_payment:str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into orders (orders_customer_id, orders_store_id, orders_employee_id, orders_product_id, orders_quantity, orders_number, orders_payment, orders_date, orders_status) values (%s, %s, %s, %s, %s, %s, %s, now(),0)'
        curs.execute(sql, (orders_customer_id, orders_store_id, orders_employee_id, orders_product_id, orders_quantity, orders_number, orders_payment,))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
@router.get('/selectByCustomerStatus')
async def select(customer:int, status:int):
    try:
        conn = connect()
        curs = conn.cursor()    
        curs.execute(
            '''
            select o.orders_id, o.orders_quantity, o.orders_number, o.orders_payment, o.orders_date, o.orders_status, s.store_name, p.product_name, p.product_price, size.size_name, brand.brand_name, category.category_name, color.color_name
            from orders as o
                inner join product as p
                    on p.product_id = o.orders_product_id
                inner join store as s
                    on s.store_id = o.orders_store_id   
                inner join size
                    on size.size_id = p.product_size_id 
                 inner join category
					on category.category_id = p.product_category_id
				inner join brand
					on brand.brand_id = p.product_brand_id
                 inner join color
					on color.color_id = p.product_color_id   
            where o.orders_customer_id = %s and o.orders_status = %s
            ''',(customer, status)
        )
        rows = curs.fetchall()

        result = [{'orders_id' : row[0], 
                'orders_quantity' : row[1], 
                'orders_number' : row[2], 
                'orders_payment' : row[3], 
                'orders_date' : row[4], 
                'orders_status' : row[5], 
                'store_name' : row[6], 
                'product_name' : row[7], 
                'product_price' : row[8],
                'size_name' : row[9],
                'brand_name' : row[10],
                'category_name' : row[11],
                'color_name' : row[12],
                } for row in rows]
        return {'results' : result}
    finally:
        conn.close()

@router.get('/selectByKeyword')
async def select(customer:int, search:str):
    try:
        conn = connect()
        keyword = f"%{search}" if search else None
        curs = conn.cursor()    
        curs.execute(
            '''
            select o.orders_id, o.orders_quantity, o.orders_number, o.orders_payment, o.orders_date, o.orders_status, s.store_name, p.product_name, p.product_price, size.size_name, brand.brand_name, category.category_name, color.color_name
            from orders as o
                inner join product as p
                    on p.product_id = o.orders_product_id
                inner join store as s
                    on s.store_id = o.orders_store_id   
                inner join size
                    on size.size_id = p.product_size_id 
                 inner join category
					on category.category_id = p.product_category_id
				inner join brand
					on brand.brand_id = p.product_brand_id
                 inner join color
					on color.color_id = p.product_color_id   
            where o.orders_customer_id = %s and (
            %s is null
            or p.product_name like %s 
            or o.orders_number like %s)
            ''',(customer, keyword, keyword, keyword)
        )
        rows = curs.fetchall()

        result = [{'orders_id' : row[0], 
                'orders_quantity' : row[1], 
                'orders_number' : row[2], 
                'orders_payment' : row[3], 
                'orders_date' : row[4], 
                'orders_status' : row[5], 
                'store_name' : row[6], 
                'product_name' : row[7], 
                'product_price' : row[8],
                'size_name' : row[9],
                'brand_name' : row[10],
                'category_name' : row[11],
                'color_name' : row[12],
                } for row in rows]
        return {'results' : result}
    finally:
        conn.close()

@router.get('/selectByCustomerStatusKeyword')
async def select(customer:int, status:int, search:str):
    try:
        conn = connect()
        keyword = f"%{search}" if search else None
        curs = conn.cursor()    
        curs.execute(
            '''
            select o.orders_id, o.orders_quantity, o.orders_number, o.orders_payment, o.orders_date, o.orders_status, s.store_name, p.product_name, p.product_price, size.size_name, brand.brand_name, category.category_name, color.color_name
            from orders as o
                inner join product as p
                    on p.product_id = o.orders_product_id
                inner join store as s
                    on s.store_id = o.orders_store_id   
                inner join size
                    on size.size_id = p.product_size_id 
                 inner join category
					on category.category_id = p.product_category_id
				inner join brand
					on brand.brand_id = p.product_brand_id
                 inner join color
					on color.color_id = p.product_color_id   
            where o.orders_customer_id = %s and o.orders_status = %s and (
            %s is null
            or p.product_name like %s 
            or o.orders_number like %s)
            ''',(customer, status, keyword, keyword, keyword)
        )
        rows = curs.fetchall()

        result = [{'orders_id' : row[0], 
                'orders_quantity' : row[1], 
                'orders_number' : row[2], 
                'orders_payment' : row[3], 
                'orders_date' : row[4], 
                'orders_status' : row[5], 
                'store_name' : row[6], 
                'product_name' : row[7], 
                'product_price' : row[8],
                'size_name' : row[9],
                'brand_name' : row[10],
                'category_name' : row[11],
                'color_name' : row[12],
                } for row in rows]
        return {'results' : result}
    finally:
        conn.close()     
@router.post('/update')
async def update(orders_customer_id :int = Form(...), orders_store_id:int = Form(...), orders_employee_id:int = Form(...), orders_product_id:int = Form(...), orders_quantity:int = Form(...), orders_number:int = Form(...), orders_payment:str = Form(...),orders_status:int=Form(...),  orders_id :int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'update orders set orders_customer_id = %s, orders_store_id = %s, orders_employee_id =%s, orders_product_id =%s, orders_quantity =%s, orders_number =%s, orders_payment =%s, orders_status= %s where orders_id = %s'
        curs.execute(sql, (orders_customer_id,orders_store_id, orders_employee_id,orders_product_id,orders_quantity, orders_number, orders_payment, orders_status, orders_id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"} 
    
@router.post('/updateStatus')
async def update(orders_status:int=Form(...),  orders_id :int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'update orders set orders_status= %s where orders_id = %s'
        curs.execute(sql, (orders_status, orders_id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"} 

    
@router.delete('/delete/{orders_id}')
async def delete(orders_id:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute('delete from orders where orders_id = %s', (orders_id,))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  

