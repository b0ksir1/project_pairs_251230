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

@router.get('/select')
async def select():
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
        '''
        select 
        product_id, 
        product_color_id, 
        product_size_id, 
        product_brand_id, 
        product_category_id, 
        product_name, 
        product_description, 
        product_price 
        from product order by product_name
    '''
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'product_id' : row[0], 
               'product_color_id' : row[1], 
               'product_size_id' : row[2], 
               'product_brand_id' : row[3],
               'product_category_id' : row[4],
               'product_name' : row[5],
               'product_description' : row[6],
               'product_price' : row[7],
               } for row in rows]
    return {'results' : result}

@router.get('/selectAll')       # 제품정보 다가져올려고 하나 만듬(반드시 workbench에 쿼리문 적어서 확인)
async def select():
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
    '''
    select p.product_id, p.product_name, p.product_price , p.product_description , c.color_name as product_color, b.brand_name as product_brand, 
    cg.category_name as product_category, s.size_name as product_size, 
    stock.stock_quantity from product as p
	    inner join color as c
		    on c.color_id = p.product_color_id
	    inner join brand as b
		    on b.brand_id = p.product_brand_id
	    inner join category as cg
		    on cg.category_id = p.product_category_id
	    inner join size as s
		    on s.size_id = p.product_size_id
        inner join stock
            on stock.stock_product_id = p.product_id
    '''
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'product_id' : row[0], 
               'product_name' : row[1], 
               'product_price' : row[2], 
               'product_description' : row[3],
               'product_color' : row[4],
               'product_brand' : row[5],
               'product_category' : row[6],
               'product_size' : row[7],
               'stock_quantity' : row[8],
               } for row in rows]
    return {'results' : result}


@router.get('/selectApprove')
async def selectApprove():
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
        '''
        select 
        p.product_id,
        p.product_name, 
        color.color_name,
        size.size_name,
        brand.brand_name,
        category.category_name,    
        p.product_price 
        from product as p
            inner join size
                on size.size_id = p.product_size_id
            inner join color
                on color.color_id = p.product_color_id
            inner join brand
                on brand.brand_id = p.product_brand_id
            inner join category
                on category.category_id = p.product_category_id
    '''
    )
    rows = curs.fetchall()
    conn.close()

    result = [{
               'productId' : row[0], 
               'productName' : row[1], 
               'color' : row[2], 
               'size' : row[3],
               'brand' : row[4],
               'category' : row[5],
               'price' : row[6],
               } for row in rows]
    return {'results' : result}

@router.post('/insert')
async def insert(product_color_id :int = Form(...), 
                 product_size_id:int = Form(...), 
                 product_brand_id:int = Form(...),
                 product_category_id:int = Form(...),
                 product_name:str = Form(...),
                 product_description:str = Form(...),
                 product_price:int = Form(...),
                 ):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
        insert into product (
        product_color_id, product_size_id, product_brand_id, product_category_id,
        product_name, product_description, product_price
        ) values (%s, %s, %s, %s, %s, %s, %s)
        """
        curs.execute(sql, (
            product_color_id, 
            product_size_id, 
            product_brand_id, 
            product_category_id,
            product_name, 
            product_description, 
            product_price))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@router.post('/update')
async def update(product_color_id :int = Form(...), 
                 product_size_id:int = Form(...), 
                 product_brand_id:int = Form(...),
                 product_category_id:int = Form(...),
                 product_name:str = Form(...),
                 product_description:str = Form(...),
                 product_price:int = Form(...),
                 product_id:int = Form(...)
                 ):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = '''
        update product set 
        product_color_id = %s, 
        product_size_id = %s, 
        product_brand_id = %s, 
        product_category_id = %s,
        product_name = %s, 
        product_description = %s, 
        product_price = %s 
        where product_id = %s
        '''
        curs.execute(sql, ( product_color_id, 
            product_size_id, 
            product_brand_id, 
            product_category_id,
            product_name, 
            product_description, 
            product_price,
            product_id ))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"} 
    
@router.delete('/delete/{product_id}')
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
