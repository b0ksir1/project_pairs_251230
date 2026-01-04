from fastapi import APIRouter, Form
import pymysql
import config
router = APIRouter()
# 260101. 1월 2일 DB에서 approve_senior_id, approve_director_id int로 추가// 260102.반영 완료
# 260101. 1월 2일 DB에서 approve_senior_assign_date, approve_director_assign_date date로 추가// 260102.반영 완료
# 260104. 1월 4일 DB에서 approve_senior_assgin_date, approve_director_assgin_date 오타난 것 바로잡기
# 260104. 1월 4일 DB에서 approve_status 추가
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
        approve_product_id, 
        approve_quantity,
        approve_employee_id, 
        approve_date, 
        approve_senior_assign_date,
        approve_director_assign_date
        from approve
         
    '''
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'approve_id' : row[0], 
               'approve_product_id' : row[1], 
               'approve_quantity' : row[2],
               'approve_employee_id' : row[3], 
               'approve_date' : row[4],
               'approve_senior_assign_date' : row[5],
               'approve_director_assign_date' : row[6],
               } for row in rows]
    return {'results' : result}

@router.get('/select/{employee_id}')
async def select(employee_id:int):
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
        '''
        select 
        approve_id, 
        approve_product_id, 
        p.product_name, 
        approve_quantity,
        approve_employee_id, 
        approve_senior_id,
        approve_director_id,
        e.employee_name as approve_employee_name,
        s.employee_name as approve_senior_name,
        d.employee_name as approve_director_name,
        approve_date, 
        approve_senior_assign_date,
        approve_director_assign_date,
        approve_status
        from approve as a
            inner join product as p
                on p.product_id = approve_product_id
            left join employee as e
                on e.employee_id = a.approve_employee_id
            left join employee as s
                on s.employee_id = a.approve_senior_id
            left join employee as d
                on d.employee_id = a.approve_director_id
        where approve_employee_id = %s or approve_senior_id = %s or approve_director_id = %s
    ''',(employee_id,employee_id,employee_id)
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'approve_id' : row[0], 
               'approve_product_id' : row[1], 
               'product_name' : row[2], 
               'approve_quantity' : row[3],
               'approve_employee_id' : row[4], 
               'approve_senior_id' : row[5],
               'approve_director_id' : row[6],
               'approve_employee_name' : row[7],
               'approve_senior_name' : row[8],
               'approve_director_name' : row[9],
               'approve_date' : row[10],
               'approve_senior_assign_date' : row[11],
               'approve_director_assign_date' : row[12],
               'approve_status' : row[13],
               } for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(approve_product_id:int = Form(...), 
                 approve_quantity:int = Form(...),
                 approve_employee_id:int = Form(...),
                 approve_senior_id:int = Form(...),
                 approve_director_id:int = Form(...),
                 ):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
        insert into approve (
        approve_employee_id,
        approve_product_id,
        approve_senior_id,
        approve_director_id,
        approve_quantity,
        approve_date,
        approve_status
                ) values (%s, %s, %s, %s, %s, now(),0 )
        """
        curs.execute(sql, (
            approve_employee_id, 
            approve_product_id, 
            approve_senior_id,
            approve_director_id, 
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
    
# @router.delete('/delete/{approve_id}')
# async def delete(approve_id:int):
#     try:
#         conn = connect()
#         curs = conn.cursor()
#         curs.execute('delete from approve where approve_id = %s', (approve_id,))
#         conn.commit()
#         conn.close()
#         return {"results" : "OK"}
#     except Exception as e:
#         print("Error ", e)
#         return {"results" : "Error"}  
