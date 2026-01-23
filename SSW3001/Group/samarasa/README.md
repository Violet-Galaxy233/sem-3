# SMAMRASA - Smart Medical Appointment Management and Remote Assistance System

> A comprehensive HIPAA-compliant telemedicine platform for remote healthcare delivery

## 🏥 About SMAMRASA

**SMAMRASA** is a next-generation telemedicine platform designed to bridge the gap between patients and healthcare providers through intelligent appointment management, remote consultations, IoT device integration, and AI-powered emergency triage.

### Key Features
- ✅ **Intelligent Appointment Scheduling** - AI-optimized slot allocation
- ✅ **Secure Video Consultations** - WebRTC-based, HIPAA-compliant
- ✅ **IoT Vital Signs Monitoring** - Real-time health data from connected devices
- ✅ **Emergency Triage System** - AI-powered symptom analysis and prioritization
- ✅ **Digital Prescriptions** - Electronic prescriptions with pharmacy integration
- ✅ **Multi-Channel Notifications** - SMS, Email, and Push notifications
- ✅ **Role-Based Access Control** - Secure access for patients, doctors, and admins
- ✅ **Mobile Applications** - Native iOS and Android apps

## 🏗️ Architecture

SMAMRASA uses a **microservices architecture** with event-driven design:

```
┌─────────────────────────────────────────────────────────┐
│                    API Gateway Layer                    │
│  (Kong/AWS API Gateway - Auth, Rate Limiting, TLS)     │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                  Service Mesh (Istio)                   │
│  (mTLS, Circuit Breaking, Load Balancing)              │
└─────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼────┐        ┌─────▼────┐       ┌─────▼─────┐
   │  Sync   │        │   Async   │      │   Event   │
   │ Services│        │  Services │      │   Bus     │
   │         │        │           │      │  (Kafka)  │
   └─────────┘        └───────────┘      └───────────┘
```

## 📂 Project Structure

```
smamrasa/
├── services/          # Microservices (11 services)
├── web/              # Web portals (Patient, Doctor, Admin)
├── mobile/           # Mobile apps (iOS/Android)
├── infrastructure/   # Terraform, Kubernetes configs
├── database/         # Migrations and seeds
├── ci-cd/           # GitHub Actions, ArgoCD
├── gateway/         # API Gateway (Kong/Nginx)
└── docs/            # Documentation
```

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 18+
- Python 3.10+
- Go 1.21+
- Kubernetes cluster (for production)

### Local Development

1. **Clone and setup**
```bash
git clone <repository>
cd smamrasa
./scripts/setup.sh
```

2. **Start infrastructure**
```bash
docker-compose up -d postgres redis kafka
```

3. **Run services**
```bash
# Option 1: Run all services
docker-compose up -d

# Option 2: Run individual services
cd services/auth-service && npm run dev
```

4. **Setup database**
```bash
./scripts/seed-db.sh
```

5. **Access applications**
- Patient Portal: http://localhost:3001
- Doctor Portal: http://localhost:3002
- Admin Portal: http://localhost:3003
- API Gateway: http://localhost:8000

## 🛠️ Technology Stack

### Backend Services
- **Auth Service**: Node.js + Express + Redis
- **User Service**: Node.js + Express
- **Appointment Service**: Python + FastAPI
- **Video Service**: Node.js + Socket.io + WebRTC
- **Notification Service**: Node.js + BullMQ
- **IoT Service**: Go + MQTT
- **Prescription Service**: Node.js + Express
- **Triage Service**: Python + FastAPI + ML
- **Analytics Service**: Python + Spark
- **Billing Service**: Node.js + Express

### Frontend
- **Web Portals**: React 18 + TypeScript + Material-UI
- **Mobile Apps**: React Native + Expo

### Infrastructure
- **Orchestration**: Kubernetes (EKS/AKS)
- **Database**: PostgreSQL + TimescaleDB
- **Cache**: Redis Cluster
- **Message Queue**: Apache Kafka
- **Search**: Elasticsearch
- **Storage**: AWS S3
- **CDN**: Cloudflare

### Security & Monitoring
- **Authentication**: JWT + MFA
- **Encryption**: AES-256, TLS 1.3
- **Monitoring**: Prometheus + Grafana
- **Logging**: ELK Stack
- **Tracing**: OpenTelemetry

## 🔐 Security & Compliance

### HIPAA Compliance
- ✅ Access Controls (RBAC, MFA)
- ✅ Audit Controls (comprehensive logging)
- ✅ Integrity Controls (encryption at rest)
- ✅ Transmission Security (TLS 1.3)
- ✅ Physical Safeguards (cloud provider)
- ✅ Administrative Safeguards

### Security Features
- Multi-factor authentication
- Role-based access control
- End-to-end encryption
- Comprehensive audit logging
- Regular security audits
- Automated compliance reporting

## 📊 API Documentation

API documentation is available via Swagger/OpenAPI:
- **Auth Service**: http://localhost:8000/auth/docs
- **User Service**: http://localhost:8000/users/docs
- **Appointment Service**: http://localhost:8000/appointments/docs
- **Video Service**: http://localhost:8000/video/docs
- **IoT Service**: http://localhost:8000/iot/docs

## 🧪 Testing

### Run Tests
```bash
# All services
npm run test:all

# Individual service
cd services/auth-service && npm test

# E2E tests
npm run test:e2e

# Load tests
npm run test:load
```

### Coverage
- Unit tests: > 90%
- Integration tests: All critical paths
- E2E tests: User workflows
- Load tests: 10,000 concurrent users

## 🚢 Deployment

### Development
```bash
./scripts/deploy.sh dev
```

### Staging
```bash
./scripts/deploy.sh staging
```

### Production
```bash
./scripts/deploy.sh prod
```

### CI/CD Pipeline
1. **GitHub Actions**: Build, test, security scan
2. **Container Registry**: Push to ECR/ACR
3. **ArgoCD**: GitOps deployment to Kubernetes
4. **Automated Rollback**: On failure detection

## 📈 Monitoring & Observability

### Metrics Dashboard
- **System Health**: CPU, memory, disk, network
- **Application Metrics**: Response time, error rate, throughput
- **Business Metrics**: Appointments, consultations, revenue
- **Security Metrics**: Failed logins, unauthorized access

### Alerting
- **Critical**: Page on-call engineer
- **Warning**: Slack/Email notifications
- **Info**: Dashboard updates

## 📚 Documentation

- [Architecture Design](./SMAMRASA_Architecture_Design.md)
- [Implementation Plan](./SMAMRASA_Implementation_Plan.md)
- [Project Summary](./SMAMRASA_Project_Summary.md)
- [API Documentation](./docs/api/)
- [User Guides](./docs/user-guides/)
- [Security Policy](./docs/security/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification
- Write tests for new features
- Update documentation
- Code review required for all changes

## 📅 Project Timeline

| Phase | Duration | Features |
|-------|----------|----------|
| **Phase 1** | Months 1-3 | Foundation, Auth, User Mgmt, Appointments |
| **Phase 2** | Months 4-6 | Video, IoT, Prescriptions, Triage |
| **Phase 3** | Months 7-9 | Mobile Apps, Analytics, Billing |
| **Phase 4** | Months 10-12 | Optimization, Security, Production |

## 💰 Cost Estimation

**Monthly Infrastructure**: $4,500 - $9,000
**Team (10-11 members)**: $50,000 - $80,000
**Tools & Licenses**: $1,500 - $2,000
**Total Monthly**: $57,000 - $93,000
**12-Month Total**: $684K - $1.1M

## 🆘 Support

For issues and questions:
- **Documentation**: Check the docs folder
- **GitHub Issues**: Report bugs and feature requests
- **Email**: support@smamrasa.com

## 📄 License

This project is proprietary software. All rights reserved.

---

**Status**: 🚧 In Development
**Version**: 0.1.0
**Last Updated**: 2026-01-15
