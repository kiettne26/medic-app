@echo off
REM Copy this file to payment-env.bat, then fill your ZaloPay merchant credentials.
REM Do not commit payment-env.bat.

REM ZaloPay sandbox/prod application id from ZaloPay Merchant/Business portal.
REM Replace 0 with the numeric app id.
set ZALOPAY_APP_ID=0

REM Secret key used to sign CreateOrder and QueryOrder requests.
set ZALOPAY_KEY1=

REM Callback key used to verify payment callbacks from ZaloPay.
set ZALOPAY_KEY2=

REM Use sandbox endpoints while testing. Change to production endpoints after ZaloPay approval.
set ZALOPAY_CREATE_ENDPOINT=https://sb-openapi.zalopay.vn/v2/create
set ZALOPAY_QUERY_ENDPOINT=https://sb-openapi.zalopay.vn/v2/query

REM Optional: must be public if you want ZaloPay server-to-server callbacks.
REM set ZALOPAY_CALLBACK_URL=https://your-domain.com/api/bookings/payment/zalopay/callback

REM Optional: deep link or web page to return after payment.
REM set ZALOPAY_REDIRECT_URL=medicapp://payment-result

set ZALOPAY_MERCHANT_NAME=MediBook
