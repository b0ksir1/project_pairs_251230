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
            select stock_id, stock_update, stock_quantity, stock_product_id
            from stock
            """
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'stock_id' : row[0], 'stock_update' : row[1], 'stock_quantity' : row[3], 'stock_product_id' : row[4]} for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(stock_quantity : int = Form(...), stock_product_id : int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
            insert into stock
            (stock_update, stock_quantity, stock_product_id)
            values
            (now(), %s, %s)
            """
        curs.execute(sql, (stock_quantity, stock_product_id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(stock_id : int = Form(...), stock_quantity : int = Form(...), stock_product_id : int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
            update stock
            set stock_quantity = %s, stock_product_id = %s
            where stock_id = %s
            """
        curs.execute(sql, (stock_quantity, stock_product_id, stock_id))
        conn.commit()
        conn.close()
        return {'results' : "OK"}

    except Exception as e:
        print("Error", e)
        return {'results' : "Error"} 
    
@router.delete('/delete/{stock_id}')
async def delete(stock_id : int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("delete from store where stock_id = %s", (stock_id))
        conn.commit()
        conn.close()
        return {'results' : "OK"}

    except Exception as e:
        print("Error ", e)
        return {'results' : "Error"}  