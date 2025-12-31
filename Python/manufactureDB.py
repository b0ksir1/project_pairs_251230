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
        'select manufacture_id, manufacture_name, manufacture_address, manufacture_phone from manufacture order by manufacture_name'
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'manufacture_id' : row[0], 'manufacture_name' : row[1], 'manufacture_address' : row[2], 'manufacture_phone' : row[3]} for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(manufacture_name :str = Form(...), manufacture_address:str = Form(...), manufacture_phone:str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into manufacture (manufacture_name, manufacture_address, manufacture_phone) values (%s, %s, %s)'
        curs.execute(sql, (manufacture_name, manufacture_address, manufacture_phone))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(id:int = Form(...), manufacture_name :str = Form(...), manufacture_address:str = Form(...), manufacture_phone:str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'update manufacture set manufacture_name = %s, manufacture_address = %s,manufacture_phone =%s where seq = %s'
        curs.execute(sql, (manufacture_name,manufacture_address, manufacture_phone, id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"} 
    
@router.delete('/delete/{seq}')
async def delete(id:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute('delete from manufacture where seq = %s', (id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  

