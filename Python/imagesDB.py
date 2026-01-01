from fastapi import APIRouter, UploadFile, File, Form
from fastapi.responses import Response
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

@router.get('/select/{images_product_id}')
async def select(images_product_id:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("select images_id from images where images_product_id = %s",(images_product_id))
        rows = curs.fetchall()
        conn.close()

        result = [{'images_id' : row[0]} for row in rows]
        return {'results' : result}
    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}    

@router.get('/view/{images_id}')
async def view(images_id:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("select image from images where images_id = %s",(images_id))
        row = curs.fetchone()
        conn.close()
        if row and row[0]:
            return Response(
                content = row[0],
                media_type='image/jpeg',
                headers={"Cache-Control":"no-cachem no-store, must-revalidate"}
            )
        else:
            return {"results" : "No Image Found"}
    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}    

@router.post('/insert')
async def insert(images_product_id: int = Form(...), file: UploadFile = File(...)):
    try:
        image_data = await file.read()
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into images (images_product_id, image, update_date) values (%s, %s, now())'
        curs.execute(sql, (images_product_id, image_data))
        conn.commit()
        conn.close()
        return {"results": "OK"}
    except Exception as e:
        print("Error ", e)
        return {"results": "Error"}

@router.post('/update')
async def update(images_product_id: int = Form(...), file: UploadFile = File(...), images_id: int = Form(...)):
    try:
        image_data = await file.read()
        conn = connect()
        curs = conn.cursor()
        sql = 'update images set images_product_id=%s, image=%s, update_date=now() where images_id=%s'
        curs.execute(sql, (images_product_id, image_data, images_id))
        conn.commit()
        conn.close()
        return {"results": "OK"}
    except Exception as e:
        print("Error ", e)
        return {"results": "Error"}

@router.delete('/delete/{images_id}')
async def delete(images_id: int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute('delete from images where images_id = %s', (images_id,))
        conn.commit()
        conn.close()
        return {"results": "OK"}
    except Exception as e:
        print("Error ", e)
        return {"results": "Error"}
