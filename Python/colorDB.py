from fastapi import APIRouter, Form
import pymysql
router = APIRouter()

fastAPIAddress = "172.16.250.194"
dbAddress = "172.16.250.171"


def connect():
    return pymysql.connect(
        host=dbAddress,
        user="root",
        password="qwer1234",
        database="project_onandtap",
        charset="utf8"
    )

@router.get('/select')
async def select():
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
        'select color_id, color_name from color order by color_name'
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'color_id' : row[0], 'color_name' : row[1]} for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(color_name :str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into color (color_name) values (%s)'
        curs.execute(sql, (color_name))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(id:int = Form(...), color_name :str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'update color set color_name = %s where seq = %s'
        curs.execute(sql, (color_name, id))
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
        curs.execute('delete from color where seq = %s', (id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
