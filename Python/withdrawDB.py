from fastapi import APIRouter, Form
import pymysql
import config
router = APIRouter()

# 회원탈퇴는 insert만

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
        'select withdraw_id, withdraw_customer_id, withdraw_date from withdraw'
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'withdraw_id' : row[0], 'withdraw_customer_id' : row[1], 'withdraw_date' : row[2]} for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(withdraw_customer_id:int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into withdraw (withdraw_customer_id, withdraw_date) values (%s, now())'
        curs.execute(sql, (withdraw_customer_id,))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.delete('/delete/{seq}')             # 이거는 test용
async def delete(id:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute('delete from withdraw where withdraw_id = %s', (id,))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"} 