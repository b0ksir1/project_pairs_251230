from fastapi import FastAPI
from brandDB import router as brand_router
from categoryDB import router as category_router
from manufactureDB import router as manufacture_router
from productDB import router as product_router
from sizeDB import router as size_router
from colorDB import router as color_router
from customerDB import router as customer_router
from withdrawDB import router as withdraw_router
from obtainDB import router as obtain_router
from employeeDB import router as employee_router
from imagesDB import router as image_router
from approveDB import router as approve_router
from approveDateDB import router as approve_date_router
from ordersDB import router as orders_router
from procureDB import router as procure_router
from receiveDB import router as receive_router
from returnsDB import router as return_router
from stockDB import router as stock_router
from storeDB import router as store_router
from wishlistDB import router as wishlist_router
from cartDB import router as cart_router
import config


app = FastAPI()
app.include_router(brand_router,prefix='/brand',tags=['brand'])
app.include_router(category_router,prefix='/category',tags=['category'])
app.include_router(color_router,prefix='/color',tags=['color'])
app.include_router(manufacture_router,prefix='/manufacture',tags=['manufacture'])
app.include_router(product_router,prefix='/product',tags=['product'])
app.include_router(size_router,prefix='/size',tags=['size'])
app.include_router(customer_router,prefix='/customer',tags=['customer'])
app.include_router(withdraw_router,prefix='/withdraw',tags=['withdraw'])
app.include_router(obtain_router,prefix='/obtain',tags=['obtain'])
app.include_router(employee_router,prefix='/employee',tags=['employee'])
app.include_router(store_router,prefix='/store',tags=['store'])
app.include_router(image_router,prefix='/images',tags=['images'])
app.include_router(approve_router,prefix='/approve',tags=['approve'])
app.include_router(approve_date_router,prefix='/approve_date',tags=['approve_date'])
app.include_router(orders_router,prefix='/orders',tags=['orders'])
app.include_router(procure_router,prefix='/procure',tags=['procure'])
app.include_router(receive_router,prefix='/receive',tags=['receive'])
app.include_router(return_router,prefix='/return',tags=['return'])
app.include_router(stock_router,prefix='/stock',tags=['stock'])
app.include_router(wishlist_router,prefix='/wishlist',tags=['wishlist'])
app.include_router(cart_router,prefix='/cart',tags=['cart'])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=config.FASTAPI_HOST, port=8000)