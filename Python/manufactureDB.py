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
        'select manufacture_id, manufacture_name, manufacture_address, manufacture_phone from manufacture order by manufacture_name'
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'manufacture_id' : row[0], 'manufacture_name' : row[1], 'manufacture_address' : row[2], 'manufacture_phone' : row[3]} for row in rows]
    return {'results' : result}

@app.post('/insert')
async def insert(manufacture_name :str = Form(...), manufacture_address:str = Form(...), manufacture_phone:str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into manufacture (manufacture_name, manufacture_address, manufacture_phone) values (%s, %s, %s)'
        curs.execute(sql, (manufacture_name, manufacture_address, manufacture_phone))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@app.post('/update')
async def update(id:int = Form(...), manufacture_name :str = Form(...), manufacture_address:str = Form(...), manufacture_phone:str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'update manufacture set manufacture_name = %s, manufacture_address = %s,manufacture_phone =%s where seq = %s'
        curs.execute(sql, (manufacture_name,manufacture_address, manufacture_phone, id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"} 
    
@app.delete('/delete/{seq}')

async def delete(id:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute('delete from manufacture where seq = %s', (id))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=fastAPIAddress, port=8000)

