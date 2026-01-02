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
    curs.execute("""
            select delivery_id, delivery_quantity, delivery_date, product_id, store_id
            from delivery
            order by delivery_date
            """
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'delivery_id' : row[0], 'delivery_quantity' : row[1], 'delivery_date' : row[2], 'product_id' : row[3], 'store_id' : row[4]} for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(delivery_quantity : int = Form(...), product_id : int = Form(...), store_id : int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
            insert into delivery
            (delivery_quantity, delivery_date, product_id, store_id)
            values
            (%s, now(), %s, %s)
            """
        curs.execute(sql, (delivery_quantity, product_id, store_id))
        conn.commit()
        conn.close()
        return {'results' : "OK"}

    except Exception as e:
        print("Error", e)
        return {'results' : "Error"}  
    
@router.post('/update')
async def update(delivery_id : int = Form(...), delivery_quantity : int = Form(...), product_id : int = Form(...), store_id : int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
            update delivery
            set delivery_quantity = %s, product_id = %s, store_id =%s
            where delivery_id = %s
            """
        curs.execute(sql, (delivery_quantity, product_id, store_id, delivery_id))
        conn.commit()
        conn.close()
        return {'results' : "OK"}

    except Exception as e:
        print("Error", e)
        return {'results' : "Error"} 
    
@router.delete('/delete/{delivery_id}')
async def delete(delivery_id : int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("delete from store where delivery_id = %s", (delivery_id))
        conn.commit()
        conn.close()
        return {'results' : "OK"}

    except Exception as e:
        print("Error ", e)
        return {'results' : "Error"}  
