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
        '''
        select 
        approve_id, 
        approve_employee_id, 
        approve_product_id, 
        approve_senior_id,
        approve_quantity,
        approve_assign_date,
        approve_date 
        from approve
         
    '''
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'approve_id' : row[0], 
               'approve_employee_id' : row[1], 
               'approve_product_id' : row[2], 
               'approve_senior_id' : row[3],
               'approve_quantity' : row[4],
               'approve_assign_date' : row[5],
               'approve_date' : row[6],
               } for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(approve_employee_id:int = Form(...), 
                 approve_product_id:int = Form(...), 
                 approve_senior_id:int = Form(...),
                 approve_quantity:int = Form(...),
                 ):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
        insert into approve (
        approve_employee_id,approve_product_id,approve_senior_id,approve_quantity,approve_assign_date,approve_date
                ) values (%s, %s, %s, %s, now(), now() )
        """
        curs.execute(sql, (
            approve_employee_id, 
            approve_product_id, 
            approve_senior_id, 
            approve_quantity
            ))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(approve_employee_id :int = Form(...), 
                 approve_product_id:int = Form(...), 
                 approve_senior_id:int = Form(...),
                 approve_quantity:int = Form(...),
                 approve_assign_date:str = Form(...),
                 approve_date:str = Form(...),
                 approve_id:int = Form(...)
                 ):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = '''
        update approve set 
        approve_employee_id = %s, 
        approve_product_id = %s, 
        approve_senior_id = %s, 
        approve_quantity = %s,
        approve_assign_date = %s, 
        approve_date = %s 
        where approve_id = %s
        '''
        curs.execute(sql, ( approve_employee_id, 
            approve_product_id, 
            approve_senior_id, 
            approve_quantity,
            approve_assign_date, 
            approve_date, 
            approve_id ))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"} 
    
@router.delete('/delete/{approve_id}')
async def delete(approve_id:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute('delete from approve where approve_id = %s', (approve_id,))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
