# stripe_api.py
import os
import stripe
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
# from dotenv import load_dotenv                          # .env형식으로 secretkey관리

router = APIRouter()

# load_dotenv()
# stripe.api_key = "sk_test_51SlPLl2Ypir8wPmXE6tJqonLkRKTQfhluchG1F2jYn57wqRMyjAUI6l3i2zEo1RDIalumysZPx9beC0vpzdg1E8z00wGFrWVXm"

class CreatePIReq(BaseModel):
    amount: int          # 예: 229000 (원)
    currency: str = "krw"

@router.post("/create-payment-intent")
def create_payment_intent(req: CreatePIReq):
    if not stripe.api_key:
        raise HTTPException(500, "STRIPE_SECRET_KEY not set")

    if req.amount <= 0:
        raise HTTPException(400, "amount must be > 0")

    # PaymentIntent 생성 (서버에서!)
    intent = stripe.PaymentIntent.create(
        amount=req.amount,
        currency=req.currency,
        automatic_payment_methods={"enabled": True},
    )
    return {"clientSecret": intent["client_secret"]}

# print("STRIPE KEY:", os.getenv("STRIPE_SECRET_KEY"))

