from fastapi import APIRouter, UploadFile, File, Form
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
        'select images_id, images_product_id, image, update_date from images order by images_id'
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'images_id' : row[0], 'images_product_id' : row[1], 'image' : row[2], 'images_date' : row[3]} for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(images_product_id :int = Form(...), file:UploadFile = File(...)):
    try:
        image_data = await file.read()
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into images (images_product_id, image, update_date) values (%s, %s, now())'
        curs.execute(sql, (images_product_id, image_data))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def insert(images_product_id :int = Form(...), file:UploadFile = File(...), images_id:int=Form(...)):
    try:
        image_data = await file.read()
        conn = connect()
        curs = conn.cursor()
        sql = 'update address set images_product_id = %s, image = %s, update_date = now() where images_id = %s'
        curs.execute(sql, (images_product_id, image_data ))
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
        curs.execute('delete from images where images_id = %s', (id,))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  

