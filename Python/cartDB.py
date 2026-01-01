# cartDB.py
from fastapi import APIRouter, Form
import pymysql
import config
import base64

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

    curs.execute(
        """
        SELECT
            cart.cart_id,
            cart.cart_customer_id,
            cart.cart_product_id,
            cart.cart_product_quantity,
            cart.cart_date,
            product.product_name,
            product.product_price,
            product.product_size_id,
            size.size_name,

            (
                SELECT images.image
                FROM images
                WHERE images.images_product_id = product.product_id
                ORDER BY images.images_id DESC
                LIMIT 1
            ) AS image
        FROM cart
        JOIN product ON product.product_id = cart.cart_product_id
        LEFT JOIN size ON size.size_id = product.product_size_id
        WHERE cart.cart_customer_id = %s
        ORDER BY cart.cart_id DESC
        """,
        (cart_customer_id,)
    )

    rows = curs.fetchall()
    conn.close()

    results = []
    for row in rows:
        image_blob = row[9]
        image_base64 = None
        if image_blob is not None:
            image_base64 = base64.b64encode(image_blob).decode("utf-8")

        product_price = row[6] if row[6] is not None else 0
        qty = row[3] if row[3] is not None else 0
        item_total = product_price * qty

        results.append({
            "cart_id": row[0],
            "cart_customer_id": row[1],
            "cart_product_id": row[2],
            "cart_product_quantity": qty,
            "cart_date": str(row[4]) if row[4] is not None else None,

            "product_name": row[5],
            "product_price": product_price,
            "product_size_id": row[7],
            "size_name": row[8],

            "item_total": item_total,
            "image_base64": image_base64
        })

    return {"results": results}


@router.post('/insert')
async def insert(
    cart_customer_id: int = Form(...),
    cart_product_id: int = Form(...),
    cart_product_quantity: int = Form(...)
):
    try:
        conn = connect()
        curs = conn.cursor()

    
        sql = """
        INSERT INTO cart
        (cart_customer_id, cart_product_id, cart_product_quantity, cart_date)
        VALUES (%s, %s, %s, CURDATE())
        ON DUPLICATE KEY UPDATE
            cart_product_quantity = VALUES(cart_product_quantity),
            cart_date = CURDATE()
        """
        curs.execute(sql, (cart_customer_id, cart_product_id, cart_product_quantity))
        conn.commit()
        conn.close()

        return {"results": "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results": "Error", "message": str(e)}


@router.post('/update')
async def update(
    cart_id: int = Form(...),
    cart_product_quantity: int = Form(...)
):
    try:
        conn = connect()
        curs = conn.cursor()

        sql = """
        UPDATE cart
        SET cart_product_quantity = %s,
            cart_date = CURDATE()
        WHERE cart_id = %s
        """
        curs.execute(sql, (cart_product_quantity, cart_id))
        conn.commit()
        conn.close()

        return {"results": "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results": "Error", "message": str(e)}


@router.delete('/delete/{cart_id}')
async def delete(cart_id: int):
    try:
        conn = connect()
        curs = conn.cursor()

        curs.execute("DELETE FROM cart WHERE cart_id = %s", (cart_id,))
        conn.commit()
        conn.close()

        return {"results": "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results": "Error", "message": str(e)}


@router.delete('/deleteAll/{cart_customer_id}')
async def delete_all(cart_customer_id: int):
    try:
        conn = connect()
        curs = conn.cursor()

        curs.execute("DELETE FROM cart WHERE cart_customer_id = %s", (cart_customer_id,))
        conn.commit()
        conn.close()

        return {"results": "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results": "Error", "message": str(e)}


@router.delete('/deleteByCustomerProduct/{cart_customer_id}/{cart_product_id}')
async def delete_by_customer_product(cart_customer_id: int, cart_product_id: int):
    try:
        conn = connect()
        curs = conn.cursor()

        curs.execute(
            "DELETE FROM cart WHERE cart_customer_id = %s AND cart_product_id = %s",
            (cart_customer_id, cart_product_id)
        )
        conn.commit()
        conn.close()

        return {"results": "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results": "Error", "message": str(e)}
