FROM mcr.microsoft.com/powershell:lts-7.2-ubuntu-22.04

WORKDIR /app

ENV APP_ENV=test \
    NO_STOCKS=2 \
    MONGO_SERVER=192.168.100.40 \
    MONGO_PORT=27017 \
    MONGO_DB=stocks \
    STOCK_API_NAME=192.168.100.40 \
    STOCK_API_PORT=8080

COPY ./modules* ./

RUN pwsh modules.ps1 -NoDev

COPY . ./

RUN chown -R nobody:nogroup . && mkdir /nonexistent && chown -R nobody:nogroup /nonexistent

USER nobody

ENTRYPOINT ["pwsh"]