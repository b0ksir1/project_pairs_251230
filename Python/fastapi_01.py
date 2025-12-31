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
from storeDB import router as store_router
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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=config.FASTAPI_HOST, port=8000)