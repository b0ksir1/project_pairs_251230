# wishlistDB.py
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

@router.get('/select/{wishlist_customer_id}')
async def select(wishlist_customer_id: int):
    conn = connect()
    curs = conn.cursor()

    curs.execute(
        """
        SELECT
            wishlist.wishlist_id,
            wishlist.wishlist_customer_id,
            wishlist.wishlist_product_id,
            wishlist.wishlist_date,
            product.product_name,
            product.product_price,
            product.product_size_id,
            size.size_name,
            images.image
        FROM wishlist
        JOIN product ON product.product_id = wishlist.wishlist_product_id
        LEFT JOIN size ON size.size_id = product.product_size_id
        LEFT JOIN images ON images.images_product_id = product.product_id
        WHERE wishlist.wishlist_customer_id = %s
        ORDER BY wishlist.wishlist_id DESC
        """,
        (wishlist_customer_id,)
    )

    rows = curs.fetchall()
    conn.close()

    results = []
    for row in rows:
        image_blob = row[8]

        image_base64 = None
        if image_blob is not None:
            image_base64 = base64.b64encode(image_blob).decode("utf-8")

        results.append({
            "wishlist_id": row[0],
            "wishlist_customer_id": row[1],
            "wishlist_product_id": row[2],
            "wishlist_date": str(row[3]) if row[3] is not None else None,
            "product_name": row[4],
            "product_price": row[5],
            "product_size_id": row[6],
            "size_name": row[7],
            "image_base64": image_base64
        })

    return {"results": results}

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

        sql = """
        INSERT INTO wishlist
        (wishlist_customer_id, wishlist_product_id, wishlist_date)
        VALUES (%s, %s, NOW())
        """
        curs.execute(sql, (wishlist_customer_id, wishlist_product_id))
        conn.commit()
        conn.close()

        return {"results": "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results": "Error"}





@router.delete('/delete/{wishlist_id}')
async def delete(wishlist_id: int):
    try:
        conn = connect()
        curs = conn.cursor()

        curs.execute("DELETE FROM wishlist WHERE wishlist_id = %s", (wishlist_id,))
        conn.commit()
        conn.close()

        return {"results": "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results": "Error"}


@router.delete('/deleteByCustomerProduct/{wishlist_customer_id}/{wishlist_product_id}')
async def delete_by_customer_product(wishlist_customer_id: int, wishlist_product_id: int):
    try:
        conn = connect()
        curs = conn.cursor()

        curs.execute(
            "DELETE FROM wishlist WHERE wishlist_customer_id = %s AND wishlist_product_id = %s",
            (wishlist_customer_id, wishlist_product_id)
        )
        conn.commit()
        conn.close()

        return {"results": "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results": "Error"}
