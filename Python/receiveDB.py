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
        receive_id, 
        receive_customer_id, 
        receive_store_id, 
        receive_order_id, 
        receive_employee_id, 
        receive_quantity, 
        receive_date 
        from receive
         
    '''
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'receive_id' : row[0], 
               'receive_customer_id' : row[1], 
               'receive_store_id' : row[2], 
               'receive_order_id' : row[3],
               'receive_employee_id' : row[4],
               'receive_quantity' : row[5],
               'receive_date' : row[6],
               } for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(receive_customer_id:int = Form(...), 
                 receive_store_id:int = Form(...), 
                 receive_order_id:int = Form(...),
                 receive_employee_id:int = Form(...),
                 receive_quantity:str = Form(...),
                 ):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
        insert into receive (
        receive_customer_id,receive_store_id,receive_order_id,receive_employee_id,receive_quantity,receive_date
        ) values (%s, %s, %s, %s, %s, now() )
        """
        curs.execute(sql, (
            receive_customer_id, 
            receive_store_id, 
            receive_order_id, 
            receive_employee_id,
            receive_quantity, 
            
            ))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(receive_customer_id :int = Form(...), 
                 receive_store_id:int = Form(...), 
                 receive_order_id:int = Form(...),
                 receive_employee_id:int = Form(...),
                 receive_quantity:str = Form(...),
                 receive_date:str = Form(...),
                 receive_id:int = Form(...)
                 ):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = '''
        update receive set 
        receive_customer_id = %s, 
        receive_store_id = %s, 
        receive_order_id = %s, 
        receive_employee_id = %s,
        receive_quantity = %s, 
        receive_date = %s 
        where receive_id = %s
        '''
        curs.execute(sql, ( receive_customer_id, 
            receive_store_id, 
            receive_order_id, 
            receive_employee_id,
            receive_quantity, 
            receive_date, 
            receive_id ))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"} 
    
@router.delete('/delete/{receive_id}')
async def delete(receive_id:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute('delete from receive where receive_id = %s', (receive_id,))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
