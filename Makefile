# Variables
IMAGE_NAME = hello-world-api
TAG = latest
CONTAINER_NAME = hello-world-api

# Default target
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make build     - Build Docker image"
	@echo "  make run       - Run container with docker run"
	@echo "  make up        - Start with docker-compose"
	@echo "  make down      - Stop docker-compose"
	@echo "  make logs      - Show container logs"
	@echo "  make clean     - Remove containers and images"
	@echo "  make test      - Test the API endpoints"

# Build Docker image
.PHONY: build
build:
	docker build -t $(IMAGE_NAME):$(TAG) .

# Run container with docker run
.PHONY: run
run:
	docker run -d --name $(CONTAINER_NAME) -p 8080:8080 $(IMAGE_NAME):$(TAG)

# Start with docker-compose
.PHONY: up
up:
	docker-compose up -d

# Stop docker-compose
.PHONY: down
down:
	docker-compose down

# Show logs
.PHONY: logs
logs:
	docker-compose logs -f

# Clean up containers and images
.PHONY: clean
clean:
	docker-compose down --rmi all --volumes --remove-orphans
	docker rmi $(IMAGE_NAME):$(TAG) 2>/dev/null || true
	docker container prune -f

# Test API endpoints
.PHONY: test
test:
	@echo "Testing API endpoints..."
	@echo "1. Testing health endpoint:"
	@curl -s http://localhost:8080/api/health | jq . || echo "Health endpoint not responding"
	@echo "2. Testing hello endpoint:"
	@curl -s http://localhost:8080/api/hello | jq . || echo "Hello endpoint not responding"
	@echo "3. Testing root endpoint:"
	@curl -s http://localhost:8080/ | jq . || echo "Root endpoint not responding"

# Build and run in one command
.PHONY: dev
dev: build up
	@echo "Application is starting up..."
	@sleep 3
	@make test 