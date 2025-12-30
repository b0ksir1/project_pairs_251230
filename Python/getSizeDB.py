from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import Response
import pymysql

fastAPIAddress = "172.16.250.171"
dbAddress = "172.16.250.171"
app = FastAPI()

def connect():
    return pymysql.connect(
        host=dbAddress,
        user="root",
        password="qwer1234",
        database="project_onandtap",
        charset="utf8"
    )

@app.get('/select')
async def select():
    conn = connect()
    curs = conn.cursor()    
    curs.execute(
        'select seq, name, phone, address, relation from address order by name'
    )
    rows = curs.fetchall()
    conn.close()

    result = [{'seq' : row[0], 'name' : row[1], 'phone' : row[2], 'address' : row[3], 'relation' : row[4]} for row in rows]
    return {'results' : result}

@app.get('/view/{seq}')
async def view(seq:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("select image from address where seq = %s",(seq))
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

@app.post('/upload')
async def upload(name :str = Form(...), phone:str = Form(...), address:str=Form(...), relation:str = Form(...), file:UploadFile = File(...)):
    try:
        image_data = await file.read()
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into address (name, phone, address, relation, image) values (%s,%s,%s,%s,%s)'
        curs.execute(sql, (name, phone, address, relation, image_data))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  
    
@app.post('/update')
async def update(seq:int = Form(...), name :str = Form(...), phone:str = Form(...), address:str=Form(...), relation:str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'update address set name = %s, phone = %s, address = %s, relation = %s where seq = %s'
        curs.execute(sql, (name, phone, address, relation, seq))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"} 
    
@app.post('/update_with_image')
async def update(seq:int = Form(...), name :str = Form(...), phone:str = Form(...), address:str=Form(...), relation:str = Form(...), file:UploadFile = File(...)):
    try:
        image_data = await file.read()
        conn = connect()
        curs = conn.cursor()
        sql = 'update address set name = %s, phone = %s, address = %s, relation = %s, image=%s where seq = %s'
        curs.execute(sql, (name, phone, address, relation, image_data, seq))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}     

@app.delete('/delete/{seq}')

async def delete(seq:int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute('delete from address where seq = %s', (seq))
        conn.commit()
        conn.close()
        return {"results" : "OK"}

    except Exception as e:
        print("Error ", e)
        return {"results" : "Error"}  

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=fastAPIAddress, port=8000)

