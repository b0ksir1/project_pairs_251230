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
        select employee_id,
        employee_role,
        employee_name,
        senior_id,
        employee_address,
        employee_phone,
        employee_email,
        employee_password,
        employee_workplace
        from employee order by employee_name
    '''
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'employee_id' : row[0], 
               'employee_role' : row[1], 
               'employee_name' : row[2], 
               'senior_id' : row[3],
               'employee_address' : row[4],
               'employee_phone' : row[5],
               'employee_email' : row[6],
               'employee_password' : row[7],
               'employee_workplace' : row[8],
               } for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(employee_role :int = Form(...), 
                 employee_name:str = Form(...), 
                 senior_id:int = Form(...),
                 employee_address:str = Form(...),
                 employee_phone:str = Form(...),
                 employee_email:str = Form(...),
                 employee_password:int = Form(...),
                 employee_workplace:str = Form(...),
                 ):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
        insert into employee (
        employee_role,employee_name , senior_id, employee_address,
        employee_phone, employee_email, employee_password,employee_workplace
        ) values (%s, %s, %s, %s, %s, %s,%s ,%s)
        """
        curs.execute(sql, (
            employee_role, 
            employee_name, 
            senior_id, 
            employee_address,
            employee_phone, 
            employee_email, 
            employee_password,
            employee_workplace
            ))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(employee_role :int = Form(...), 
                 employee_name:str = Form(...), 
                 senior_id:int = Form(...),
                 employee_address:str = Form(...),
                 employee_phone:str = Form(...),
                 employee_email:str = Form(...),
                 employee_password:int = Form(...),
                 employee_workplace:str = Form(...),
                 employee_id:int = Form(...)

                 ):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = '''
        update employee set 
        employee_role= %s, 
        employee_name = %s, 
        senior_id = %s, 
        employee_address = %s,
        employee_phone = %s, 
        employee_email = %s, 
        employee_password = %s,
        employee_workplace = %s
        where employee_id = %s
        '''
        curs.execute(sql, ( employee_role, 
            employee_name, 
            senior_id, 
            employee_address,
            employee_phone, 
            employee_email, 
            employee_password,
            employee_workplace,
            employee_id ))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"} 
    
@router.delete('/delete/{employee_id}')
async def delete(employee_id:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute('delete from employee where employee_id = %s', (employee_id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
