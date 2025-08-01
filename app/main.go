package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"
)

// Response represents the API response structure
type Response struct {
	Message   string    `json:"message"`
	Timestamp time.Time `json:"timestamp"`
	Status    string    `json:"status"`
}

// HealthResponse represents the health check response
type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Service   string    `json:"service"`
}

func main() {
	// Define routes
	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/api/hello", helloHandler)
	http.HandleFunc("/api/health", healthHandler)

	// Start server
	port := ":8080"
	fmt.Printf("🚀 Starting Hello World API server on port %s\n", port)
	fmt.Printf("📡 Available endpoints:\n")
	fmt.Printf("   - GET  /api/hello    - Hello World message\n")
	fmt.Printf("   - GET  /api/health   - Health check\n")
	fmt.Printf("   - GET  /             - API info\n")

	log.Fatal(http.ListenAndServe(port, nil))
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	response := map[string]interface{}{
		"service": "Hello World API",
		"version": "1.0.0",
		"endpoints": map[string]string{
			"hello":  "/api/hello",
			"health": "/api/health",
		},
		"timestamp": time.Now(),
	}

	json.NewEncoder(w).Encode(response)
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	response := Response{
		Message:   "Hello, World dev2!!!",
		Timestamp: time.Now(),
		Status:    "success",
	}

	json.NewEncoder(w).Encode(response)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Service:   "hello-world-api",
	}

	json.NewEncoder(w).Encode(response)
}
