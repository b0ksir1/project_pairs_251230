from fastapi import APIRouter, Form
import pymysql
import config
router = APIRouter()
# 260101. 1월 2일 DB에서 orders_date를 datetime으로 수정// 260102.반영 완료
# 260101. 1월 2일 DB에서 orders_status를 int로 추가// 260102.반영 완료
# 260103. 1월 2일 DB에서 orders_totalprice int로 추가 // 260102. 반영완료

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
            orders_status,
            orders_totalprice
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
                'orders_totalprice' : row[10],                
                } for row in rows]
        return {'results' : result}

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
            o.orders_totalprice,
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
                'orders_totalprice' : row[10],
                'store_name' : row[11],
                'product_name' : row[12],
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
            select o.orders_id, o.orders_quantity, o.orders_number, o.orders_payment, o.orders_totalprice , o.orders_date, o.orders_status, s.store_name, p.product_name, p.product_price, size.size_name, brand.brand_name, category.category_name, color.color_name
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
                'orders_totalprice' : row[4], 
                'orders_date' : row[5], 
                'orders_status' : row[6], 
                'store_name' : row[7], 
                'product_name' : row[8], 
                'product_price' : row[9],
                'size_name' : row[10],
                'brand_name' : row[11],
                'category_name' : row[12],
                'color_name' : row[13],
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
            select o.orders_id, o.orders_quantity, o.orders_number, o.orders_date, s.store_name, p.product_name, c.customer_name
            from orders as o
                inner join product as p
                    on p.product_id = o.orders_product_id
                inner join store as s
                    on s.store_id = o.orders_store_id   
                inner join size
                    on size.size_id = p.product_size_id 
                 inner join customer as c
					on c.customer_id = o.orders_customer_id
            where o.orders_status = %s
            ''',(orders_status)
        )
        rows = curs.fetchall()

        result = [{'orders_id' : row[0], 
                'orders_quantity' : row[1], 
                'orders_number' : row[2], 
                'orders_date' : row[3], 
                'store_name' : row[4], 
                'product_name' : row[5], 
                'customer_name' : row[6],
                } for row in rows]
        return {'results' : result}
    finally:
        conn.close()

@router.post('/insert')
async def insert(orders_customer_id :int = Form(...), orders_store_id:int = Form(...), orders_employee_id:int = Form(...), orders_product_id:int = Form(...), orders_quantity:int = Form(...), orders_number:str = Form(...), orders_payment:str = Form(...), orders_totalprice:int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into orders (orders_customer_id, orders_store_id, orders_employee_id, orders_product_id, orders_quantity, orders_number, orders_payment, orders_date, orders_status, orders_totalprice) values (%s, %s, %s, %s, %s, %s, %s, now(),0, %s)'
        curs.execute(sql, (orders_customer_id, orders_store_id, orders_employee_id, orders_product_id, orders_quantity, orders_number, orders_payment,orders_totalprice))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(orders_customer_id :int = Form(...), orders_store_id:int = Form(...), orders_employee_id:int = Form(...), orders_product_id:int = Form(...), orders_quantity:int = Form(...), orders_number:int = Form(...), orders_payment:str = Form(...),orders_status:int=Form(...), orders_totalprice:int=Form(...),  orders_id :int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'update orders set orders_customer_id = %s, orders_store_id = %s, orders_employee_id =%s, orders_product_id =%s, orders_quantity =%s, orders_number =%s, orders_payment =%s, orders_status= %s, orders_totalprice= %s where orders_id = %s'
        curs.execute(sql, (orders_customer_id,orders_store_id, orders_employee_id,orders_product_id,orders_quantity, orders_number, orders_payment, orders_status, orders_totalprice, orders_id))
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

