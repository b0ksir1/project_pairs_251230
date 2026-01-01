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
        'select returns_id, returns_customer_id, returns_employee_id, returns_description, returns_orders_id, store_store_id, returns_create_date, returns_update_date from returns'
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'returns_id' : row[0], 'returns_customer_id' : row[1], 'returns_employee_id' : row[2], 'returns_description' : row[3], 'returns_orders_id' : row[4], 'store_store_id' : row[5], 'returns_create_date' : row[6], 'returns_update_date' : row[7]} for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(returns_customer_id :int = Form(...), returns_employee_id:int = Form(...), returns_description:str = Form(...), returns_orders_id:int = Form(...), store_store_id:int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into returns (returns_customer_id, returns_employee_id, returns_description, returns_orders_id, store_store_id, returns_create_date) values (%s, %s, %s, %s, %s, now())'
        curs.execute(sql, (returns_customer_id, returns_employee_id, returns_description, returns_orders_id, store_store_id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(returns_customer_id :int = Form(...), returns_employee_id:int = Form(...), returns_description:str = Form(...), returns_orders_id:int = Form(...), store_store_id:int = Form(...), returns_id :int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'update returns set returns_customer_id = %s, returns_employee_id = %s, returns_description =%s, returns_orders_id =%s, store_store_id =%s, returns_update_date =now() where returns_id = %s'
        curs.execute(sql, (returns_customer_id,returns_employee_id, returns_description,returns_orders_id,store_store_id, returns_id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"} 
    
@router.delete('/delete/{returns_id}')
async def delete(returns_id:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute('delete from returns where returns_id = %s', (returns_id,))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  

