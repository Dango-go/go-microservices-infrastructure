FROM golang:1.22-alpine AS build

RUN apk update && apk add --no-cache git ca-certificates tzdata

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /app/product-service ./cmd

FROM alpine:latest AS final

RUN apk update && apk --no-cache add ca-certificates tzdata

WORKDIR /app

RUN adduser -D -g '' product-user

COPY --from=build /app/product-service .
COPY --from=build /app/pkg/config/envs ./pkg/config/envs

USER product-user

ENTRYPOINT ["./product-service"]