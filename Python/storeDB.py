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
            select store_id, store_name, store_phone, store_lat, store_lng
            from store
            order by store_name
            """
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'store_id' : row[0], 'store_name' : row[1], 'store_phone' : row[2], 'store_lat' : row[3], 'store_lng' : row[4]} for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(store_name : str = Form(...), store_phone : str = Form(...), store_lat : float = Form(...), store_lng : float = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
            insert into store
            (store_name, store_phone, store_lat, store_lng)
            values
            (%s, %s, %s, %s)
            """
        curs.execute(sql, (store_name, store_phone, store_lat, store_lng))
        conn.commit()
        conn.close()
        return {'results' : "OK"}

    except Exception as e:
        print("Error", e)
        return {'results' : "Error"}  
    
@router.post('/update')
async def update(store_id : int = Form(...), store_name : str = Form(...), store_phone : str = Form(...), store_lat : float = Form(...), store_lng : float = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
            update store
            set store_name = %s, store_phone = %s, store_lat =%s, store_lng =%s
            where store_id = %s
            """
        curs.execute(sql, (store_name, store_phone, store_lat, store_lng, store_id))
        conn.commit()
        conn.close()
        return {'results' : "OK"}

    except Exception as e:
        print("Error", e)
        return {'results' : "Error"} 
    
@router.delete('/delete/{store_id}')
async def delete(store_id : int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("delete from store where store_id = %s", (store_id))
        conn.commit()
        conn.close()
        return {'results' : "OK"}

    except Exception as e:
        print("Error ", e)
        return {'results' : "Error"}  
