from fastapi import APIRouter, Form, HTTPException
import pymysql
import config
from pydantic import BaseModel
router = APIRouter()

def connect():
    return pymysql.connect(
        host=config.DB_HOST,
        user=config.DB_USER,
        password=config.DB_PASSWORD,
        database=config.DB_NAME,
        charset="utf8"
    )

# --------------------------------------------------------------
# Customer Login

def select_customer_by_email(email: str): # 로그인 전용 DB 조회 함수
    conn = connect()
    curs = conn.cursor(pymysql.cursors.DictCursor) # Dict형태로 반환

    sql = """
    select customer_id, customer_email, customer_password
    from customer
    where customer_email = %s
    """
    curs.execute(sql, (email,))
    result = curs.fetchone() # 로그인은 단건 조회

    conn.close()
    return result

class LoginCustomer(BaseModel): # 프론트에서 받은 데이터 검증 단계
    email: str
    password: str

@router.post("/login")
def login(data: LoginCustomer):
    customer = select_customer_by_email(data.email)

    if not customer:
        raise HTTPException(status_code=404, detail="이메일이 존재하지 않습니다.")

    if customer["customer_password"] != data.password:
        raise HTTPException(status_code=401, detail="비밀번호가 틀렸습니다.")

    return {
        "id": customer["customer_id"],
        "email": customer["customer_email"],
    }
# --------------------------------------------------------------


@router.get('/select')
async def select():
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
        'select customer_id, customer_email, customer_password, customer_name, customer_phone, customer_address, customer_signup_date, customer_withdraw_date from customer'
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
    
@router.delete('/delete/{customer_id}')
async def delete(customer_id:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute('delete from customer where customer_id = %s', (customer_id,))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  

@router.get('/select/{customer_id}')
async def select_by_id(customer_id: int):
    conn = connect()
    curs = conn.cursor(pymysql.cursors.DictCursor) # 필드명을 키로 받기 위해 DictCursor 사용
    sql = "select * from customer where customer_id = %s"
    curs.execute(sql, (customer_id,))
    result = curs.fetchone()
    conn.close()
    return result


class CustomerUpdate(BaseModel):
    customer_email: str
    customer_password: str
    customer_name: str
    customer_phone: str
    customer_address: str

@router.post('/update/{customer_id}')
async def update_by_id(customer_id: int, customer: CustomerUpdate):
    try:
        conn = connect()
        curs = conn.cursor(pymysql.cursors.DictCursor) # 필드명을 키로 받기 위해 DictCursor 사용
        sql = 'update customer set customer_email = %s, customer_password = %s, customer_name =%s, customer_phone =%s, customer_address =%s where customer_id = %s'
        curs.execute(sql, (customer.customer_email,customer.customer_password, customer.customer_name,customer.customer_phone,customer.customer_address, customer_id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"} 