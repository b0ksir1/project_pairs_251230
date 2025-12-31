from fastapi import APIRouter, Form
import pymysql
router = APIRouter()

fastAPIAddress = "172.16.250.171"
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
        'select size_id, size_name from size order by size_name'
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'size_id' : row[0], 'size_name' : row[1]} for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(size_name :str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into size (size_name) values (%s)'
        curs.execute(sql, (size_name))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(id:int = Form(...), size_name :str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'update size set size_name = %s where seq = %s'
        curs.execute(sql, (size_name, id))
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
        curs.execute('delete from size where seq = %s', (id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
