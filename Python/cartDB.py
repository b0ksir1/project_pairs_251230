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

@router.get('/select/{cart_customer_id}')
async def select(cart_customer_id: int):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = """
        SELECT
            c.cart_id,
            c.cart_customer_id,
            c.cart_product_id,
            c.cart_product_quantity,
            c.cart_date,
            p.product_name,
            p.product_price,
            s.size_name,
            (
                SELECT i.images_id
                FROM images i
                WHERE i.images_product_id = p.product_id
                ORDER BY i.images_id ASC
                LIMIT 1
            ) AS images_id
        FROM cart c
        JOIN product p ON p.product_id = c.cart_product_id
        LEFT JOIN size s ON s.size_id = p.product_size_id
        WHERE c.cart_customer_id = %s
        ORDER BY c.cart_id DESC
        """
        curs.execute(sql, (cart_customer_id,))
        rows = curs.fetchall()

        results = []
        for row in rows:
            results.append({
                "cart_id": row[0],
                "cart_customer_id": row[1],
                "cart_product_id": row[2],
                "cart_product_quantity": row[3],
                "cart_date": str(row[4]) if row[4] is not None else "",
                "product_name": row[5] if row[5] is not None else "",
                "product_price": int(row[6]) if row[6] is not None else 0,
                "size_name": row[7] if row[7] is not None else "",
                "images_id": int(row[8]) if row[8] is not None else 0
            })

        return {"results": results}

    except Exception as e:
        return {"results": "Error", "message": str(e)}
    finally:
        conn.close()


@router.post('/insert')
async def insert(
    cart_customer_id: int = Form(...),
    cart_product_id: int = Form(...),
    cart_product_quantity: int = Form(...)
):
    conn = connect()
    curs = conn.cursor()

    try:
        check_sql = """
        SELECT cart_id
        FROM cart
        WHERE cart_customer_id = %s AND cart_product_id = %s
        ORDER BY cart_id DESC
        LIMIT 1
        """
        curs.execute(check_sql, (cart_customer_id, cart_product_id))
        row = curs.fetchone()

        if row:
            update_sql = """
            UPDATE cart
            SET cart_product_quantity = %s,
                cart_date = CURDATE()
            WHERE cart_id = %s
            """
            curs.execute(update_sql, (cart_product_quantity, row[0]))
        else:
            insert_sql = """
            INSERT INTO cart (cart_customer_id, cart_product_id, cart_product_quantity, cart_date)
            VALUES (%s, %s, %s, CURDATE())
            """
            curs.execute(insert_sql, (cart_customer_id, cart_product_id, cart_product_quantity))

        conn.commit()
        return {"results": "OK"}

    except Exception as e:
        return {"results": "Error", "message": str(e)}
    finally:
        conn.close()


@router.delete('/delete/{cart_id}')
async def delete(cart_id: int):
    conn = connect()
    curs = conn.cursor()

    try:
        curs.execute("DELETE FROM cart WHERE cart_id = %s", (cart_id,))
        conn.commit()
        return {"results": "OK"}
    except Exception as e:
        return {"results": "Error", "message": str(e)}
    finally:
        conn.close()


@router.delete('/deleteAll/{cart_customer_id}')
async def delete_all(cart_customer_id: int):
    conn = connect()
    curs = conn.cursor()

    try:
        curs.execute("DELETE FROM cart WHERE cart_customer_id = %s", (cart_customer_id,))
        conn.commit()
        return {"results": "OK"}
    except Exception as e:
        return {"results": "Error", "message": str(e)}
    finally:
        conn.close()
