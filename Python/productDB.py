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

@router.get('/select/{query}')      # 검색(중복없이)
async def select(query: str):
    conn = connect()
    curs = conn.cursor()

    like = f"%{query}%"

    sql = """
  SELECT
      p.product_id,
      p.product_name,
      p.product_price,
      p.product_description,
      c.color_name     AS product_color,
      b.brand_name     AS product_brand,
      cg.category_name AS product_category,
      COALESCE(s.total_stock, 0) AS total_stock
    FROM product p
    JOIN (
      SELECT product_name, product_color_id, MAX(product_id) AS max_id
      FROM product
      GROUP BY product_name, product_color_id
    ) x ON p.product_id = x.max_id
    JOIN color c     ON c.color_id = p.product_color_id
    JOIN brand b     ON b.brand_id = p.product_brand_id
    JOIN category cg ON cg.category_id = p.product_category_id
    LEFT JOIN (
      SELECT stock_product_id, SUM(stock_quantity) AS total_stock
      FROM stock
      GROUP BY stock_product_id
    ) s ON s.stock_product_id = p.product_id
    WHERE
      p.product_name LIKE %s
      OR b.brand_name LIKE %s
      OR cg.category_name LIKE %s
    """

    curs.execute(sql, (like, like, like))
    rows = curs.fetchall()
    conn.close()

    result = [{
        'product_id': row[0],
        "product_name": row[1],
        "product_price": row[2],
        "product_description": row[3],
        "product_color": row[4],
        "product_brand": row[5],
        "product_category": row[6],
        "total_stock": row[7],
    } for row in rows]

    return {'results': result}


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

    
# @router.get('/selectById/{product_id}')
# async def select(product_id:int):
#     conn = connect()
#     curs = conn.cursor()    
#     curs.execute(
#         '''
#         select 
#         product_color_id, 
#         product_size_id, 
#         product_brand_id, 
#         product_category_id, 
#         product_name, 
#         product_description, 
#         product_price 
#         from product 
#         where product_id = %s
#     ''',(product_id)
#     )
#     rows = curs.fetchall()
#     conn.close()

#     result = [{
#                'product_color_id' : row[0], 
#                'product_size_id' : row[1], 
#                'product_brand_id' : row[2],
#                'product_category_id' : row[3],
#                'product_name' : row[4],
#                'product_description' : row[5],
#                'product_price' : row[6],
#                } for row in rows]
#     return {'results' : result}

@router.get('/selectById/{product_id}')
async def select(product_id:int):
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
        '''
        select p.product_id, p.product_name, p.product_color_id, color.color_name, p.product_size_id, size.size_name, p.product_brand_id, p.product_category_id, p.product_description, p.product_price, stock.stock_quantity 
        from product as p 
            inner join stock on stock.stock_product_id = p.product_id
            inner join size on size.size_id = p.product_size_id    
            inner join color on color.color_id = p.product_color_id    
        where p.product_id = %s
    ''',(product_id)
    )
    rows = curs.fetchall()
    conn.close()

    result = [{
               'product_id' : row[0], 
               'product_name' : row[1], 
               'product_color_id' : row[2], 
               'product_color_name' : row[3],
               'product_size_id' : row[4],
               'product_size_name' : row[5],
               'product_brand_id' : row[6],
               'product_category_id' : row[7],
               'product_description' : row[8],
               'product_price' : row[9],
               'stock_quantity' : row[10],
               } for row in rows]
    return {'results' : result}

@router.get('/selectByName/{product_name}')
async def select(product_name:str):
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
        '''
        select p.product_id, p.product_name, p.product_color_id, color.color_name, p.product_size_id, size.size_name, p.product_brand_id, p.product_category_id, p.product_description, p.product_price, stock.stock_quantity 
        from product as p 
            inner join stock on stock.stock_product_id = p.product_id
            inner join size on size.size_id = p.product_size_id    
            inner join color on color.color_id = p.product_color_id    
        where product_name = %s
    ''',(product_name)
    )

    rows = curs.fetchall()
    conn.close()

    result = [{
               'product_id' : row[0], 
               'product_name' : row[1], 
               'product_color_id' : row[2], 
               'product_color_name' : row[3],
               'product_size_id' : row[4],
               'product_size_name' : row[5],
               'product_brand_id' : row[6],
               'product_category_id' : row[7],
               'product_description' : row[8],
               'product_price' : row[9],
               'stock_quantity' : row[10],
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
        p.product_price,
        stock.stock_quantity 
        from product as p
            inner join size
                on size.size_id = p.product_size_id
            inner join color
                on color.color_id = p.product_color_id
            inner join brand
                on brand.brand_id = p.product_brand_id
            inner join category
                on category.category_id = p.product_category_id
            inner join stock
                on stock.stock_product_id = p.product_id     
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
               'qty' : row[7],
               } for row in rows]
    return {'results' : result}

@router.get('/getAllSizeByName')
async def select(product_name:str, color_id:int):
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
        '''
        select p.product_id, size.size_id, size.size_name 
	from product as p 
            inner join size on size.size_id = p.product_size_id    
        where product_name = %s and product_color_id = %s;
    ''',(product_name,color_id)
    )

    rows = curs.fetchall()
    conn.close()

    result = [{
               'product_id' : row[0], 
               'size_id' : row[1], 
               'size_name' : row[2]
               } for row in rows]
    return {'results' : result}

@router.get('/getAllColorByName')
async def select(product_name:str):
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
        '''
        select min(p.product_id) as product_id, min(p.product_color_id) as color_id
        from product p 
            inner join color 
                on color.color_id = p.product_color_id 
        where p.product_name = %s 
        group by p.product_color_id
    ''',(product_name)
    )

    rows = curs.fetchall()
    conn.close()

    result = [{
               'product_id' : row[0], 
               'color_id' : row[1]
               } for row in rows]
    return {'results' : result}

@router.get('/getMainImageToColorByName/{product_name}')
async def select(product_name:str):
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
        '''
        select min(i.images_id) as image_id
            from(
                select min(p.product_id ) as product_id
                from product p
                where p.product_name = %s
                group by p.product_color_id) as pmin
            join images as i
                on i.images_product_id = pmin.product_id
             group by pmin.product_id    
    ''',(product_name,)
    )

    rows = curs.fetchall()
    conn.close()

    result = [{
               'image_id' : row[0]
               } for row in rows]
    return {'results' : result}

@router.get('/selectProductByNameSizeColor')
async def select(product_name:str, size:int, color:int):
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
        '''
        select product_id
            from product
        where product_name = %s and product_size_id = %s and product_color_id = %s    
    ''',(product_name, size, color)
    )

    rows = curs.fetchall()
    conn.close()

    result = [{
               'product_id' : row[0]
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
