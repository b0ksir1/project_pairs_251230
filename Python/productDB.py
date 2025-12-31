from fastapi import FastAPI, Form
import pymysql

fastAPIAddress = "127.0.0.1"
dbAddress = "127.0.0.1"
app = FastAPI()

def connect():
    return pymysql.connect(
        host=dbAddress,
        user="root",
        password="qwer1234",
        database="test",
        charset="utf8"
    )

@app.get('/select')
async def select():
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
        '''
        select product_id, 
        product_color_id, 
        product_size_id, 
        product_store_id, 
        product_brand_id, 
        product_category_id, 
        product_name, 
        product_description, 
        product_sell, 
        product_pty from product order by product_name
    '''
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'product_id' : row[0], 
               'product_color_id' : row[1], 
               'product_size_id' : row[2], 
               'product_store_id' : row[3],
               'product_brand_id' : row[4],
               'product_category_id' : row[5],
               'product_name' : row[6],
               'product_description' : row[7],
               'product_sell' : row[8],
               'product_pty' : row[9],
               } for row in rows]
    return {'results' : result}

@app.post('/insert')
async def insert(product_color_id :int = Form(...), 
                 product_size_id:int = Form(...), 
                 product_store_id:int = Form(...),
                 product_brand_id:int = Form(...),
                 product_category_id:int = Form(...),
                 product_name:str = Form(...),
                 product_description:str = Form(...),
                 product_sell:str = Form(...),
                 product_pty:str = Form(...)
                 ):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
        insert into product (
        product_color_id, product_size_id, product_store_id, product_brand_id, product_category_id,
        product_name, product_description, product_sell, product_pty
        ) values (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        curs.execute(sql, (
            product_color_id, 
            product_size_id, 
            product_store_id,
            product_brand_id, 
            product_category_id,
            product_name, 
            product_description, 
            product_sell,
            product_pty ))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@app.post('/update')
async def update(product_color_id :int = Form(...), 
                 product_size_id:int = Form(...), 
                 product_store_id:int = Form(...),
                 product_brand_id:int = Form(...),
                 product_category_id:int = Form(...),
                 product_name:str = Form(...),
                 product_description:str = Form(...),
                 product_sell:str = Form(...),
                 product_pty:str = Form(...),
                 product_id:int = Form(...)
                 ):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = '''
        update product set 
        product_color_id = %s, 
        product_size_id = %s, 
        product_store_id = %s, 
        product_brand_id = %s, 
        product_category_id = %s,
        product_name = %s, 
        product_description = %s, 
        product_sell = %s, 
        product_pty = %s
        where seq = %s
        '''
        curs.execute(sql, ( product_color_id, 
            product_size_id, 
            product_store_id,
            product_store_id, 
            product_brand_id, 
            product_category_id,
            product_name, 
            product_description, 
            product_sell,
            product_pty,
            product_id ))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"} 
    
@app.delete('/delete/{seq}')

async def delete(product_id:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute('delete from product where product_id = %s', (product_id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=fastAPIAddress, port=8000)

