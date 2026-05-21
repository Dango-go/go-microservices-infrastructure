FROM golang:1.22-alpine AS build

RUN apk update && apk add --no-cache git ca-certificates tzdata

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-w -s" \
    # Name of binary
    -o /app/gtw-service \ 
    ./cmd/main.go

FROM alpine:latest AS final

RUN apk update && apk --no-cache add ca-certificates tzdata

WORKDIR /app

RUN adduser -D -g '' gtway-user

COPY --from=build /app/gtw-service .
COPY --from=build /app/pkg/config/envs ./pkg/config/envs

USER gtway-user

ENTRYPOINT ["./gtw-service"]