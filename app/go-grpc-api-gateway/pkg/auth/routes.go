package auth

import (
	"github.com/gin-gonic/gin"

	"github.com/anazibinurasheed/go-grpc-microservice/go-grpc-api-gateway/pkg/config"

	"github.com/anazibinurasheed/go-grpc-microservice/go-grpc-api-gateway/pkg/auth/routes"
)

func RegisterRoutes(r *gin.Engine, c *config.Config) *ServiceClient {
	svc := &ServiceClient{
		Client: InitServiceClient(c),
	}
	r.GET("/healthz", func(ctx *gin.Context) {
        ctx.JSON(200, gin.H{"status": "ok"})
    })

    r.GET("/ready", func(ctx *gin.Context) {
        ctx.JSON(200, gin.H{"status": "ready"})
    })


	routes := r.Group("/auth")
	routes.POST("/register", svc.Register)
	routes.POST("/login", svc.Login)
	return svc
}

func (svc *ServiceClient) Register(ctx *gin.Context) {
	routes.Register(ctx, svc.Client)
}

func (svc *ServiceClient) Login(ctx *gin.Context) {
	routes.Login(ctx, svc.Client)
}
