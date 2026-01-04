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

@router.get('/select/{wishlist_customer_id}')
async def select(wishlist_customer_id: int):
    try:
        conn = connect()
        curs = conn.cursor()

        sql = """
        SELECT
            w.wishlist_id,
            w.wishlist_customer_id,
            w.wishlist_product_id,
            w.wishlist_date,
            p.product_name,
            p.product_price,
            (
                SELECT i.images_id
                FROM images i
                WHERE i.images_product_id = p.product_id
                ORDER BY i.images_id ASC
                LIMIT 1
            ) AS images_id
        FROM wishlist w
        JOIN product p ON p.product_id = w.wishlist_product_id
        WHERE w.wishlist_customer_id = %s
        ORDER BY w.wishlist_id DESC
        """
        curs.execute(sql, (wishlist_customer_id,))
        rows = curs.fetchall()
        conn.close()

        result = []
        for row in rows:
            wishlist_id = row[0]
            customer_id = row[1]
            product_id = row[2]
            wishlist_date = row[3]
            product_name = row[4]
            product_price = row[5]
            images_id = row[6]

            result.append({
                "wishlist_id": wishlist_id,
                "wishlist_customer_id": customer_id,
                "wishlist_product_id": product_id,
                "wishlist_date": str(wishlist_date) if wishlist_date else None,
                "product_name": product_name,
                "product_price": int(product_price) if product_price is not None else 0,
                "images_id": images_id,
            })

        return {"results": result}

    except Exception as e:
        print("Error ", e)
        return {"results": "Error", "message": str(e)}


@router.get('/exists/{customer_id}/{product_id}')
async def exists(customer_id: int, product_id: int):
    try:
        conn = connect()
        curs = conn.cursor()

        curs.execute(
            """
            SELECT 1
            FROM wishlist
            WHERE wishlist_customer_id = %s AND wishlist_product_id = %s
            LIMIT 1
            """,
            (customer_id, product_id)
        )
        row = curs.fetchone()
        conn.close()

        return {"results": "OK", "exists": True if row else False}

    except Exception as e:
        print("Error ", e)
        return {"results": "Error", "message": str(e)}

@router.get('/hasProduct')
async def select(customer_id: int, product_id:int):
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
        '''
        SELECT
            count(wishlist_id) from wishlist
            where wishlist_customer_id = %s and wishlist_product_id = %s;
    ''',(customer_id,product_id)
    )

    rows = curs.fetchall()
    conn.close()

    result = [{
               'count' : row[0], 
               } for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(
    wishlist_customer_id: int = Form(...),
    wishlist_product_id: int = Form(...)
):
    try:
        conn = connect()
        curs = conn.cursor()

        curs.execute(
            """
            INSERT INTO wishlist (wishlist_customer_id, wishlist_product_id, wishlist_date)
            VALUES (%s, %s, CURDATE())
            """,
            (wishlist_customer_id, wishlist_product_id)
        )

        conn.commit()
        conn.close()
        return {"results": "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results": "Error", "message": str(e)}


@router.delete('/deleteByCustomerProduct/{customer_id}/{product_id}')
async def deleteByCustomerProduct(customer_id: int, product_id: int):
    try:
        conn = connect()
        curs = conn.cursor()

        curs.execute(
            """
            DELETE FROM wishlist
            WHERE wishlist_customer_id = %s AND wishlist_product_id = %s
            """,
            (customer_id, product_id)
        )

        conn.commit()
        conn.close()
        return {"results": "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results": "Error", "message": str(e)}


@router.post('/moveToCart')
async def moveToCart(
    customer_id: int = Form(...),
    product_id: int = Form(...),
    quantity: int = Form(1)
):
    conn = connect()
    curs = conn.cursor()

    try:
        curs.execute(
            """
            SELECT cart_id, cart_product_quantity
            FROM cart
            WHERE cart_customer_id = %s AND cart_product_id = %s
            LIMIT 1
            """,
            (customer_id, product_id)
        )
        row = curs.fetchone()

        if row:
            cart_id = row[0]
            current_qty = int(row[1] or 0)
            new_qty = current_qty + int(quantity)

            curs.execute(
                """
                UPDATE cart
                SET cart_product_quantity = %s,
                    cart_date = CURDATE()
                WHERE cart_id = %s
                """,
                (new_qty, cart_id)
            )
        else:
            curs.execute(
                """
                INSERT INTO cart (cart_customer_id, cart_product_id, cart_product_quantity, cart_date)
                VALUES (%s, %s, %s, CURDATE())
                """,
                (customer_id, product_id, int(quantity))
            )

        curs.execute(
            """
            DELETE FROM wishlist
            WHERE wishlist_customer_id = %s AND wishlist_product_id = %s
            """,
            (customer_id, product_id)
        )

        conn.commit()
        conn.close()
        return {"results": "OK"}

    except Exception as e:
        conn.rollback()
        conn.close()
        print("Error ", e)
        return {"results": "Error", "message": str(e)}
