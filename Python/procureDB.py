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
            select procure_id, procure_date, procure_approve_id, procure_employee_id
            from procure
            order by procure_date
            """
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'procure_id' : row[0], 'procure_date' : row[1], 'procure_approve_id' : row[3], 'procure_employee_id' : row[4]} for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(procure_approve_id : int = Form(...), procure_employee_id : int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
            insert into procure
            (procure_date, procure_approve_id, procure_employee_id)
            values
            (now(), %s, %s)
            """
        curs.execute(sql, (procure_approve_id, procure_employee_id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(procure_id : int = Form(...), procure_approve_id : int = Form(...), procure_employee_id : int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
            update procure
            set procure_approve_id = %s, procure_employee_id = %s
            where procure_id = %s
            """
        curs.execute(sql, (procure_approve_id, procure_employee_id, procure_id))
        conn.commit()
        conn.close()
        return {'results' : "OK"}

    except Exception as e:
        print("Error", e)
        return {'results' : "Error"} 
    
@router.delete('/delete/{procure_id}')
async def delete(procure_id : int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("delete from store where procure_id = %s", (procure_id))
        conn.commit()
        conn.close()
        return {'results' : "OK"}

    except Exception as e:
        print("Error ", e)
        return {'results' : "Error"}  