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
        'select brand_id, brand_name from brand order by brand_name'
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'brand_id' : row[0], 'brand_name' : row[1]} for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(brand_name :str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into brand (brand_name) values (%s)'
        curs.execute(sql, (brand_name))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(id:int = Form(...), brand_name :str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'update brand set brand_name = %s where seq = %s'
        curs.execute(sql, (brand_name, id))
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
        curs.execute('delete from brand where seq = %s', (id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  

