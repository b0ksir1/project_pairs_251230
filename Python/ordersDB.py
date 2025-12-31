from fastapi import APIRouter, Form
import pymysql
import config
router = APIRouter()

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
        'select orders_id, orders_customer_id, orders_store_id, orders_employee_id, orders_product_id, orders_quantity, orders_number, orders_payment , orders_date from orders'
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'orders_id' : row[0], 'orders_customer_id' : row[1], 'orders_store_id' : row[2], 'orders_employee_id' : row[3], 'orders_product_id' : row[4], 'orders_quantity' : row[5], 'orders_number' : row[6], 'orders_payment' : row[7], 'orders_date' : row[8]} for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(orders_customer_id :int = Form(...), orders_store_id:int = Form(...), orders_employee_id:int = Form(...), orders_product_id:int = Form(...), orders_quantity:int = Form(...), orders_number:int = Form(...), orders_payment:str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into orders (orders_customer_id, orders_store_id, orders_employee_id, orders_product_id, orders_quantity, orders_number, orders_payment, orders_date) values (%s, %s, %s, %s, %s, %s, %s, now())'
        curs.execute(sql, (orders_customer_id, orders_store_id, orders_employee_id, orders_product_id, orders_quantity, orders_number, orders_payment,))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(orders_customer_id :int = Form(...), orders_store_id:int = Form(...), orders_employee_id:int = Form(...), orders_product_id:int = Form(...), orders_quantity:int = Form(...), orders_number:int = Form(...), orders_payment:str = Form(...), orders_id :int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'update orders set orders_customer_id = %s, orders_store_id = %s, orders_employee_id =%s, orders_product_id =%s, orders_quantity =%s, orders_number =%s, orders_payment =%s where orders_id = %s'
        curs.execute(sql, (orders_customer_id,orders_store_id, orders_employee_id,orders_product_id,orders_quantity, orders_number, orders_payment, orders_id))
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

