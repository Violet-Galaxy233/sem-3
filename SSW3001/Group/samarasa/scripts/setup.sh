#!/bin/bash

# SMAMRASA Setup Script
# This script sets up the development environment

set -e

echo "=========================================="
echo "  SMAMRASA - Setup Script"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker is not installed${NC}"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
else
    echo -e "${GREEN}✓ Docker is installed${NC}"
fi

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}✗ Docker Compose is not installed${NC}"
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
else
    echo -e "${GREEN}✓ Docker Compose is installed${NC}"
fi

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}⚠ Node.js is not installed (optional for local service development)${NC}"
else
    echo -e "${GREEN}✓ Node.js is installed ($(node --version))${NC}"
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}⚠ Python 3 is not installed (optional for local service development)${NC}"
else
    echo -e "${GREEN}✓ Python 3 is installed ($(python3 --version))${NC}"
fi

# Check Go
if ! command -v go &> /dev/null; then
    echo -e "${YELLOW}⚠ Go is not installed (optional for local service development)${NC}"
else
    echo -e "${GREEN}✓ Go is installed ($(go version))${NC}"
fi

echo ""

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ .env file created${NC}"
    echo -e "${YELLOW}⚠ Please edit .env file with your actual credentials${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

echo ""

# Create necessary directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p logs
mkdir -p certs
mkdir -p backups
echo -e "${GREEN}✓ Directories created${NC}"

echo ""

# Build Docker images
echo -e "${YELLOW}Building Docker images...${NC}"
docker-compose build --parallel

echo ""
echo -e "${GREEN}✓ All images built successfully${NC}"

echo ""

# Start infrastructure services
echo -e "${YELLOW}Starting infrastructure services (PostgreSQL, Redis, Kafka)...${NC}"
docker-compose up -d postgres timescaledb redis kafka zookeeper

echo ""
echo -e "${YELLOW}Waiting for services to be ready...${NC}"
sleep 10

# Check if PostgreSQL is ready
echo -e "${YELLOW}Checking PostgreSQL health...${NC}"
if docker-compose exec -T postgres pg_isready -U smamrasa_admin > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PostgreSQL is ready${NC}"
else
    echo -e "${RED}✗ PostgreSQL failed to start${NC}"
    exit 1
fi

# Check if Redis is ready
echo -e "${YELLOW}Checking Redis health...${NC}"
if docker-compose exec -T redis redis-cli ping > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Redis is ready${NC}"
else
    echo -e "${RED}✗ Redis failed to start${NC}"
    exit 1
fi

# Check if Kafka is ready
echo -e "${YELLOW}Checking Kafka health...${NC}"
if docker-compose exec -T kafka kafka-topics --list --bootstrap-server localhost:9092 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Kafka is ready${NC}"
else
    echo -e "${RED}✗ Kafka failed to start${NC}"
    exit 1
fi

echo ""

# Run database migrations
echo -e "${YELLOW}Running database migrations...${NC}"
docker-compose exec -T postgres psql -U smamrasa_admin -d smamrasa -f /docker-entrypoint-initdb.d/001-init.sql

echo -e "${GREEN}✓ Database migrations completed${NC}"

echo ""

# Run TimescaleDB migrations
echo -e "${YELLOW}Running TimescaleDB migrations...${NC}"
docker-compose exec -T timescaledb psql -U iot_admin -d smamrasa_iot -f /docker-entrypoint-initdb.d/001-init-timescale.sql

echo -e "${GREEN}✓ TimescaleDB migrations completed${NC}"

echo ""

# Create Kafka topics
echo -e "${YELLOW}Creating Kafka topics...${NC}"
docker-compose exec -T kafka kafka-topics --create --topic appointments.created --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092 2>/dev/null || echo "Topic already exists"
docker-compose exec -T kafka kafka-topics --create --topic appointments.cancelled --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092 2>/dev/null || echo "Topic already exists"
docker-compose exec -T kafka kafka-topics --create --topic notifications.send --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092 2>/dev/null || echo "Topic already exists"
docker-compose exec -T kafka kafka-topics --create --topic vitals.alert --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092 2>/dev/null || echo "Topic already exists"
docker-compose exec -T kafka kafka-topics --create --topic triage.emergency --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092 2>/dev/null || echo "Topic already exists"
docker-compose exec -T kafka kafka-topics --create --topic prescriptions.created --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092 2>/dev/null || echo "Topic already exists"

echo -e "${GREEN}✓ Kafka topics created${NC}"

echo ""

# Install dependencies for services (if Node.js is available)
if command -v node &> /dev/null; then
    echo -e "${YELLOW}Installing Node.js dependencies...${NC}"

    for service in auth-service user-service notification-service video-service prescription-service billing-service; do
        if [ -d "services/$service" ]; then
            echo "  Installing dependencies for $service..."
            (cd "services/$service" && npm ci --silent 2>&1 | grep -v "npm WARN" || true)
        fi
    done

    echo -e "${GREEN}✓ Node.js dependencies installed${NC}"
fi

echo ""

# Install dependencies for web portals (if Node.js is available)
if command -v node &> /dev/null; then
    echo -e "${YELLOW}Installing web portal dependencies...${NC}"

    for portal in patient-portal doctor-portal admin-portal; do
        if [ -d "web/$portal" ]; then
            echo "  Installing dependencies for $portal..."
            (cd "web/$portal" && npm ci --silent 2>&1 | grep -v "npm WARN" || true)
        fi
    done

    echo -e "${GREEN}✓ Web portal dependencies installed${NC}"
fi

echo ""

# Start all services
echo -e "${YELLOW}Starting all SMAMRASA services...${NC}"
docker-compose up -d

echo ""
echo -e "${GREEN}✓ All services started${NC}"

echo ""
echo "=========================================="
echo -e "${GREEN}  SMAMRASA Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "Services running at:"
echo "  - Auth Service:        http://localhost:4001"
echo "  - User Service:        http://localhost:4002"
echo "  - Appointment Service: http://localhost:5001"
echo "  - Notification Service: http://localhost:4003"
echo "  - Video Service:       http://localhost:4004"
echo "  - IoT Service:         http://localhost:5002 (MQTT: 1883)"
echo "  - Prescription Service: http://localhost:4005"
echo "  - Triage Service:      http://localhost:5003"
echo ""
echo "  - Patient Portal:      http://localhost:3001"
echo "  - Doctor Portal:       http://localhost:3002"
echo "  - Admin Portal:        http://localhost:3003"
echo ""
echo "  - API Gateway:         http://localhost:8000"
echo "  - Kong Admin:          http://localhost:8001"
echo ""
echo "  - PostgreSQL:          localhost:5432"
echo "  - TimescaleDB:         localhost:5433"
echo "  - Redis:               localhost:6379"
echo "  - Kafka:               localhost:9092"
echo "  - Elasticsearch:       http://localhost:9200"
echo "  - Kibana:              http://localhost:5601"
echo "  - Prometheus:          http://localhost:9090"
echo "  - Grafana:             http://localhost:3000 (admin/admin123)"
echo ""
echo "Sample credentials:"
echo "  - admin@smamrasa.com / Admin123!"
echo "  - doctor@smamrasa.com / Admin123!"
echo "  - patient@smamrasa.com / Admin123!"
echo ""
echo "Useful commands:"
echo "  - View logs:           docker-compose logs -f <service>"
echo "  - Stop services:       docker-compose down"
echo "  - Restart services:    docker-compose restart"
echo "  - Run tests:           cd services/<service> && npm test"
echo "  - View database:       docker-compose exec postgres psql -U smamrasa_admin -d smamrasa"
echo ""
echo "Next steps:"
echo "  1. Edit .env file with your actual credentials"
echo "  2. Access Grafana at http://localhost:3000 and set up dashboards"
echo "  3. Test API endpoints using the API Gateway"
echo "  4. Start developing your features!"
echo ""
