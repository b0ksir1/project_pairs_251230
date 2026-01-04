from fastapi import APIRouter, Form
from typing import Optional  
import pymysql
import config

router = APIRouter()

# -------------------------
# DB 연결
# -------------------------
def connect():
    return pymysql.connect(
        host=config.DB_HOST,
        user=config.DB_USER,
        password=config.DB_PASSWORD,
        database=config.DB_NAME,
        charset="utf8"
    )

# -------------------------
# 공통 Response
# -------------------------
def res_list(rows):
    return {"results": rows}

def res_ok():
    return {"results": "OK"}

def res_error(e):
    return {"results": "Error", "message": str(e)}

def status_guard(status: int):
    # returns_status는 0(대기) / 1(완료)만 허용
    if status not in (0, 1):
        raise ValueError("returns_status must be 0 or 1")

# -------------------------
# 1) 전체 조회
# -------------------------
@router.get("/select")
async def select():
    conn = connect()
    try:
        curs = conn.cursor(pymysql.cursors.DictCursor)
        sql = """
        SELECT
            returns_id,
            returns_customer_id,
            returns_employee_id,
            returns_description,
            returns_orders_id,
            store_store_id,
            returns_status,
            returns_create_date,
            returns_update_date
        FROM returns
        ORDER BY returns_id DESC
        """
        curs.execute(sql)
        rows = curs.fetchall()
        return res_list(rows)
    except Exception as e:
        print("Error:", e)
        return res_error(e)
    finally:
        conn.close()

# -------------------------
# 2) 고객별 조회
# -------------------------
@router.get("/selectByCustomer/{customer_id}")
async def select_by_customer(customer_id: int):
    conn = connect()
    try:
        curs = conn.cursor(pymysql.cursors.DictCursor)
        sql = """
        SELECT
            returns_id,
            returns_orders_id,
            returns_status,
            returns_create_date,
            returns_update_date
        FROM returns
        WHERE returns_customer_id = %s
        ORDER BY returns_id DESC
        """
        curs.execute(sql, (customer_id,))
        rows = curs.fetchall()
        return res_list(rows)
    except Exception as e:
        print("Error:", e)
        return res_error(e)
    finally:
        conn.close()

# -------------------------
# 3) 관리자용 상세 조회
# -------------------------
@router.get("/selectAdmin")
async def select_admin():
    conn = connect()
    try:
        curs = conn.cursor(pymysql.cursors.DictCursor)

        sql = """
        SELECT
            r.returns_id,
            r.returns_customer_id,
            r.returns_employee_id,
            r.returns_description,
            r.returns_orders_id,
            r.store_store_id,
            r.returns_status,
            r.returns_create_date,
            r.returns_update_date,

            c.customer_name,
            s.store_name,

            o.orders_number,
            o.orders_date,
            o.orders_quantity,

            p.product_id,
            p.product_name,
            p.product_price,

            sz.size_name,

            (
                SELECT im.images_id
                FROM images im
                WHERE im.images_product_id = p.product_id
                ORDER BY im.images_id DESC
                LIMIT 1
            ) AS images_id,

            (p.product_price * o.orders_quantity) AS total_price

        FROM returns r
        INNER JOIN orders o
            ON o.orders_id = r.returns_orders_id
        INNER JOIN customer c
            ON c.customer_id = r.returns_customer_id
        INNER JOIN store s
            ON s.store_id = r.store_store_id
        INNER JOIN product p
            ON p.product_id = o.orders_product_id
        LEFT JOIN size sz
            ON sz.size_id = p.product_size_id
        ORDER BY r.returns_id DESC
        """
        curs.execute(sql)
        rows = curs.fetchall()
        return res_list(rows)
    except Exception as e:
        print("Error:", e)
        return res_error(e)
    finally:
        conn.close()

# -------------------------
# 4) 반품 요청 등록
#    - 고객앱에서는 returns_employee_id가 없으니 0 또는 None이 오면 NULL로 저장
#    - returns_orders_id UNIQUE 때문에 같은 주문은 1번만 요청 가능
# -------------------------
@router.post("/insert")
async def insert(
    returns_customer_id: int = Form(...),
    returns_employee_id: Optional[int] = Form(None),
    returns_description: str = Form(...),
    returns_orders_id: int = Form(...),
    store_store_id: int = Form(...),
):
    conn = connect()
    try:
        curs = conn.cursor()

        emp_id = None if (returns_employee_id in (None, 0)) else returns_employee_id

        #  같은 주문 중복 반품 요청 방지 
        check_sql = "SELECT returns_id FROM returns WHERE returns_orders_id = %s LIMIT 1"
        curs.execute(check_sql, (returns_orders_id,))
        already = curs.fetchone()
        if already:
            return {"results": "Error", "message": "이미 해당 주문은 반품 요청이 접수되어 있어요."}

        sql = """
        INSERT INTO returns
            (returns_customer_id, returns_employee_id, returns_description,
             returns_orders_id, store_store_id, returns_status, returns_create_date)
        VALUES
            (%s, %s, %s, %s, %s, 0, NOW())
        """
        curs.execute(
            sql,
            (returns_customer_id, emp_id, returns_description, returns_orders_id, store_store_id)
        )
        conn.commit()
        return res_ok()

    except Exception as e:
        conn.rollback()
        print("Error:", e)
        return res_error(e)
    finally:
        conn.close()

# -------------------------
# 5) 상태 업데이트 (관리자)
# -------------------------
@router.post("/updateStatus")
async def update_status(
    returns_id: int = Form(...),
    returns_status: int = Form(...),
):
    conn = connect()
    try:
        status_guard(returns_status)
        curs = conn.cursor()
        sql = """
        UPDATE returns
        SET returns_status = %s,
            returns_update_date = NOW()
        WHERE returns_id = %s
        """
        curs.execute(sql, (returns_status, returns_id))
        conn.commit()
        return res_ok()
    except Exception as e:
        conn.rollback()
        print("Error:", e)
        return res_error(e)
    finally:
        conn.close()

# -------------------------
# 6) 삭제
# -------------------------
@router.delete("/delete/{returns_id}")
async def delete(returns_id: int):
    conn = connect()
    try:
        curs = conn.cursor()
        curs.execute("DELETE FROM returns WHERE returns_id = %s", (returns_id,))
        conn.commit()
        return res_ok()
    except Exception as e:
        conn.rollback()
        print("Error:", e)
        return res_error(e)
    finally:
        conn.close()
