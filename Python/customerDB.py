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
        'select customer_id, customer_email, customer_password, customer_name, customer_phone, customer_address, customer_signup_date, customer_withdraw_date from customer order by customer_name'
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'customer_id' : row[0], 'customer_email' : row[1], 'customer_password' : row[2], 'customer_name' : row[3], 'customer_phone' : row[4], 'customer_address' : row[5], 'customer_signup_date' : row[6], 'customer_withdraw_date' : row[7]} for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(customer_email :str = Form(...), customer_password:str = Form(...), customer_name:str = Form(...), customer_phone:str = Form(...), customer_address:str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into customer (customer_email, customer_password, customer_name, customer_phone, customer_address, customer_signup_date) values (%s, %s, %s, %s, %s, now())'
        curs.execute(sql, (customer_email, customer_password, customer_name, customer_phone, customer_address))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(customer_email :str = Form(...), customer_password:str = Form(...), customer_name:str = Form(...), customer_phone:str = Form(...), customer_address:str = Form(...), customer_id :int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'update customer set customer_email = %s, customer_password = %s, customer_name =%s, customer_phone =%s, customer_address =%s where customer_id = %s'
        curs.execute(sql, (customer_email,customer_password, customer_name,customer_phone,customer_address, customer_id))
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
        curs.execute('delete from customer where customer_id = %s', (id,))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  

