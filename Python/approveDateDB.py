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

@router.get('select')
async def select(approve_id:int, status:int):
    try:
        conn = connect()
        curs = conn.cursor()    
        curs.execute(
            ''' 
            select approve_id, status, update_date from approve_update
            where approve_id = %s and status = %s 
            ''',(approve_id, status)
        )
        row = curs.fetchone()
        result = {'approve_id' : row[0], 
                'status' : row[1], 
                'update_date' : row[2], 
                }
        return {'results' : result}
    finally:
        conn.close()


@router.post('/insert')
async def insert(approve_id:int = Form(...), 
                 status:int = Form(...) ):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
        insert into approve_update (
        approve_id,
        status,
        update_date
                ) values (%s, %s, now())
        """
        curs.execute(sql, (
            approve_id, 
            status 
            ))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  