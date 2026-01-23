# SMAMRASA Quick Start Guide

> Get your telemedicine platform running in 5 minutes! 🚀

## Prerequisites

Before you begin, ensure you have the following installed:

- ✅ **Docker Desktop** (or Docker Engine + Docker Compose)
- ✅ **Node.js 18+** (optional, for local development)
- ✅ **Git**

## Installation

### Step 1: Clone or Download

If you have git:
```bash
git clone <repository-url>
cd smamrasa
```

Or simply extract the project files to your desired location.

### Step 2: Run Setup Script

```bash
./scripts/setup.sh
```

This will:
- ✅ Check all prerequisites
- ✅ Create `.env` file from template
- ✅ Build all Docker images
- ✅ Start infrastructure (PostgreSQL, Redis, Kafka, etc.)
- ✅ Run database migrations
- ✅ Create sample users

### Step 3: Configure Environment

Edit the `.env` file with your actual credentials:

```bash
# Required
DB_PASSWORD=your_secure_db_password
REDIS_PASSWORD=your_secure_redis_password
JWT_SECRET=your_super_secret_jwt_key

# Optional (for full functionality)
TWILIO_SID=your_twilio_sid
TWILIO_TOKEN=your_twilio_token
SENDGRID_API_KEY=your_sendgrid_key
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
```

## Running the Platform

### Development Mode

```bash
./scripts/dev.sh
```

This starts all services in development mode with health checks.

### Manual Start

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

## Access Points

Once running, access the platform at:

| Service | URL | Credentials |
|---------|-----|-------------|
| **Patient Portal** | http://localhost:3001 | patient@smamrasa.com / Admin123! |
| **Doctor Portal** | http://localhost:3002 | doctor@smamrasa.com / Admin123! |
| **Admin Portal** | http://localhost:3003 | admin@smamrasa.com / Admin123! |
| **API Gateway** | http://localhost:8000 | - |
| **Grafana** | http://localhost:3000 | admin / admin123 |
| **Kibana** | http://localhost:5601 | - |
| **Prometheus** | http://localhost:9090 | - |
| **Kong Admin** | http://localhost:8001 | - |

## Testing the API

### Quick Test

```bash
# Test Auth Service
curl -X POST http://localhost:8000/auth/health

# Login
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"patient@smamrasa.com","password":"Admin123!"}'
```

### API Examples

See `docs/API_Examples.md` for comprehensive API testing examples.

## Sample Users

The setup creates these test accounts:

| Email | Password | Role | Use Case |
|-------|----------|------|----------|
| admin@smamrasa.com | Admin123! | Admin | System administration |
| doctor@smamrasa.com | Admin123! | Doctor | Healthcare provider |
| patient@smamrasa.com | Admin123! | Patient | Patient portal |

## Common Commands

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f auth-service
```

### Restart Services
```bash
# All services
docker-compose restart

# Specific service
docker-compose restart auth-service
```

### Access Database
```bash
# PostgreSQL
docker-compose exec postgres psql -U smamrasa_admin -d smamrasa

# TimescaleDB (IoT)
docker-compose exec timescaledb psql -U iot_admin -d smamrasa_iot

# Redis
docker-compose exec redis redis-cli
```

### Run Tests
```bash
# Auth service tests
cd services/auth-service && npm test

# All services
docker-compose exec auth-service npm test
```

## Troubleshooting

### Services won't start

1. **Check if ports are available:**
   ```bash
   lsof -i :3001,3002,3003,4001,4002,4003,4004,4005,5001,5002,5003,8000
   ```

2. **Check Docker resources:**
   ```bash
   docker system info
   ```

3. **Restart Docker Desktop** (if using Docker Desktop)

### Database connection errors

1. **Wait for database to be ready:**
   ```bash
   docker-compose logs postgres
   ```

2. **Check database health:**
   ```bash
   docker-compose exec postgres pg_isready -U smamrasa_admin
   ```

### MFA issues

If you need to reset MFA for a user:
```bash
docker-compose exec postgres psql -U smamrasa_admin -d smamrasa -c "UPDATE users SET mfa_enabled = false WHERE email = 'user@example.com';"
```

### Clear all data

```bash
# Stop and remove everything
docker-compose down -v

# Remove images (optional)
docker-compose down --rmi all

# Re-run setup
./scripts/setup.sh
```

## Next Steps

### 1. Configure External Services

For production features, set up:
- **Twilio** for SMS notifications
- **SendGrid** for email notifications
- **Firebase** for push notifications
- **Stripe** for payments
- **AWS S3** for file storage

### 2. Set Up Monitoring

Access Grafana at http://localhost:3000:
- Login with admin/admin123
- Import pre-built dashboards
- Set up alerting rules

### 3. Mobile Apps

For mobile development:
```bash
cd mobile/patient-app
npm install
npm run android  # or ios
```

### 4. Production Deployment

See `SMAMRASA_Implementation_Plan.md` for production deployment guide.

## Documentation

- **Architecture**: `SMAMRASA_Architecture_Design.md`
- **Implementation Plan**: `SMAMRASA_Implementation_Plan.md`
- **API Examples**: `docs/API_Examples.md`
- **Project Summary**: `SMAMRASA_Project_Summary.md`

## Support

For issues:
1. Check logs: `docker-compose logs -f <service>`
2. Review documentation
3. Check container status: `docker-compose ps`
4. Verify environment variables: `docker-compose exec auth-service env`

## Performance Tips

- **Increase Docker resources**: Docker Desktop → Settings → Resources
  - CPUs: 4+
  - Memory: 8GB+
  - Disk: 60GB+

- **Use Docker BuildKit**:
  ```bash
  export DOCKER_BUILDKIT=1
  docker-compose build
  ```

- **Enable Build Cache**:
  ```bash
  docker-compose build --parallel --build-arg BUILDKIT_INLINE_CACHE=1
  ```

## Security Checklist

Before going to production:

- [ ] Change all default passwords
- [ ] Use strong JWT secrets
- [ ] Enable HTTPS/TLS
- [ ] Configure firewall rules
- [ ] Set up proper SSL certificates
- [ ] Enable audit logging
- [ ] Configure backup strategy
- [ ] Run security audit
- [ ] Enable HIPAA compliance features

## Architecture Overview

```
┌─────────────────────────────────────────┐
│         User Interfaces                 │
│  (Patient, Doctor, Admin Portals)      │
└──────────────┬──────────────────────────┘
               │
         ┌─────▼──────┐
         │ API Gateway│ (Kong)
         └─────┬──────┘
               │
    ┌──────────┼──────────┬──────────┐
    │          │          │          │
┌───▼───┐  ┌──▼───┐  ┌──▼───┐  ┌──▼───┐
│Auth   │  │User  │  │Appt  │  │Video │
└───────┘  └──────┘  └──────┘  └──────┘

┌─────────────────────────────────────────┐
│         Data & Infrastructure           │
│  PostgreSQL  Redis  Kafka  TimescaleDB │
└─────────────────────────────────────────┘
```

## Performance Metrics

After setup, you should see:
- ✅ All containers running (`docker-compose ps`)
- ✅ Health checks passing
- ✅ Database migrations completed
- ✅ Sample data loaded
- ✅ API endpoints responding

Check with:
```bash
docker-compose ps
```

Expected output:
```
NAME                COMMAND                  SERVICE             STATUS
smamrasa-auth       "node src/app.js"        auth-service        Up
smamrasa-user       "node src/app.js"        user-service        Up
smamrasa-appointment "python app/main.py"    appointment-service Up
smamrasa-postgres   "docker-entrypoint.s..." postgres            Up
smamrasa-redis      "redis-server --appe..." redis               Up
...
```

---

**Ready to go!** 🎉

Your SMAMRASA platform is now running. Start by exploring the patient portal at http://localhost:3001!

For advanced configuration, check the full documentation in the `docs/` folder.
