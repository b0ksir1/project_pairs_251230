from fastapi import APIRouter, Form
import pymysql
router = APIRouter()

fastAPIAddress = "192.168.10.66"
dbAddress = "192.168.10.66"
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
        '''
        select obtain_id,
        obtain_approve_id,
        obtain_employee_id,
        obtain_date
        , 
        from obtain 
    '''
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'obtain_id' : row[0], 
               'obtain_approve_id' : row[1], 
               'obtain_employee_id' : row[2], 
               'obtain_date' : row[3]
               } for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(obtain_approve_id :int = Form(...), 
                 obtain_employee_id:int = Form(...), 
                
                 ):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
        insert into obtain (
        obtain_approve_id, obtain_employee_id , obtain_date
        ) values (%s, %s, now())
        """
        curs.execute(sql, (
            obtain_approve_id, 
            obtain_employee_id, 
            ))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(obtain_approve_id :int = Form(...), 
                 obtain_employee_id:int = Form(...),
                 obtain_id: int = Form(...) 
                 ):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = '''
        update obtain set 
        obtain_approve_id= %s, 
        obtain_employee_id = %s, 
        where seq = %s
        '''
        curs.execute(sql, ( obtain_approve_id, 
            obtain_employee_id,
            obtain_id 
            ))
        conn.commit()   
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"} 
    
@router.delete('/delete/{seq}')
async def delete(obtain_id:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute('delete from obtain where obtain_id = %s', (obtain_id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
