package db
import (
	"log"
	"time"

	"github.com/anazibinurasheed/go-grpc-microservice/go-grpc-product-svc/pkg/models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Handler struct {
	DB *gorm.DB
}

// Init tries to connect to the DB with retries and exponential backoff.
func Init(url string) Handler {
	var db *gorm.DB
	var err error

	attempts := 5
	for i := 0; i < attempts; i++ {
		db, err = gorm.Open(postgres.Open(url), &gorm.Config{})
		if err == nil {
			db.AutoMigrate(
				&models.Product{},
			)
			return Handler{DB: db}
		}
		wait := time.Second * time.Duration(1<<i)
		log.Printf("DB connect failed (attempt %d/%d): %v; retrying in %s", i+1, attempts, err, wait)
		time.Sleep(wait)
	}

	log.Fatalln("could not connect to database:", err)
	return Handler{}
}

