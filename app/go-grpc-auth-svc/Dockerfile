FROM golang:1.22-alpine AS build

RUN apk update && apk add --no-cache git ca-certificates tzdata

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /app/auth-service ./cmd

FROM alpine:latest AS final

RUN apk update && apk --no-cache add ca-certificates tzdata

WORKDIR /app

RUN adduser -D -g '' auth-user

COPY --from=build /app/auth-service .
COPY --from=build /app/pkg/config/envs ./pkg/config/envs

USER auth-user

ENTRYPOINT ["./auth-service"]