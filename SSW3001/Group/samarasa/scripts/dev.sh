#!/bin/bash

# SMAMRASA Development Start Script
# Starts all services in development mode

set -e

echo "=========================================="
echo "  SMAMRASA - Development Mode"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${RED}✗ .env file not found${NC}"
    echo "Please run ./scripts/setup.sh first"
    exit 1
fi

# Load environment variables
export $(grep -v '^#' .env | xargs)

# Function to check service health
check_service() {
    local name=$1
    local port=$2
    local max_attempts=30
    local attempt=1

    echo -e "${YELLOW}Waiting for $name to be ready...${NC}"

    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:$port/health > /dev/null 2>&1 || \
           curl -s http://localhost:$port > /dev/null 2>&1 || \
           nc -z localhost $port 2>/dev/null; then
            echo -e "${GREEN}✓ $name is ready${NC}"
            return 0
        fi
        echo "  Attempt $attempt/$max_attempts..."
        sleep 2
        attempt=$((attempt + 1))
    done

    echo -e "${RED}✗ $name failed to start${NC}"
    return 1
}

# Start infrastructure
echo -e "${YELLOW}Starting infrastructure services...${NC}"
docker-compose up -d postgres timescaledb redis kafka zookeeper elasticsearch kibana prometheus grafana

echo -e "${YELLOW}Waiting for infrastructure to be ready...${NC}"
sleep 15

# Check infrastructure
docker-compose exec -T postgres pg_isready -U smamrasa_admin || echo "PostgreSQL not ready yet"
docker-compose exec -T redis redis-cli ping > /dev/null 2>&1 || echo "Redis not ready yet"

echo -e "${GREEN}✓ Infrastructure started${NC}"

echo ""

# Start API Gateway
echo -e "${YELLOW}Starting API Gateway (Kong)...${NC}"
docker-compose up -d kong
sleep 10
check_service "Kong" 8000

echo ""

# Start backend services
echo -e "${YELLOW}Starting backend services...${NC}"

# Auth Service
echo "  Starting Auth Service..."
docker-compose up -d auth-service
check_service "Auth Service" 4001

# User Service
echo "  Starting User Service..."
docker-compose up -d user-service
check_service "User Service" 4002

# Appointment Service
echo "  Starting Appointment Service..."
docker-compose up -d appointment-service
check_service "Appointment Service" 5001

# Notification Service
echo "  Starting Notification Service..."
docker-compose up -d notification-service
check_service "Notification Service" 4003

# Video Service
echo "  Starting Video Service..."
docker-compose up -d video-service
check_service "Video Service" 4004

# IoT Service
echo "  Starting IoT Service..."
docker-compose up -d iot-service
check_service "IoT Service" 5002

# Prescription Service
echo "  Starting Prescription Service..."
docker-compose up -d prescription-service
check_service "Prescription Service" 4005

# Triage Service
echo "  Starting Triage Service..."
docker-compose up -d triage-service
check_service "Triage Service" 5003

echo -e "${GREEN}✓ All backend services started${NC}"

echo ""

# Start frontend services
echo -e "${YELLOW}Starting frontend portals...${NC}"

# Patient Portal
echo "  Starting Patient Portal..."
docker-compose up -d patient-portal
check_service "Patient Portal" 3001

# Doctor Portal
echo "  Starting Doctor Portal..."
docker-compose up -d doctor-portal
check_service "Doctor Portal" 3002

# Admin Portal
echo "  Starting Admin Portal..."
docker-compose up -d admin-portal
check_service "Admin Portal" 3003

echo -e "${GREEN}✓ All frontend portals started${NC}"

echo ""
echo "=========================================="
echo -e "${GREEN}  SMAMRASA Development Mode Ready!${NC}"
echo "=========================================="
echo ""
echo "Access Points:"
echo "  - Patient Portal:   http://localhost:3001"
echo "  - Doctor Portal:    http://localhost:3002"
echo "  - Admin Portal:     http://localhost:3003"
echo "  - API Gateway:      http://localhost:8000"
echo "  - Kong Admin:       http://localhost:8001"
echo "  - Grafana:          http://localhost:3000 (admin/admin123)"
echo "  - Kibana:           http://localhost:5601"
echo "  - Prometheus:       http://localhost:9090"
echo ""
echo "View logs:"
echo "  docker-compose logs -f <service-name>"
echo ""
echo "Stop services:"
echo "  docker-compose down"
echo ""
echo "Restart specific service:"
echo "  docker-compose restart <service-name>"
echo ""
