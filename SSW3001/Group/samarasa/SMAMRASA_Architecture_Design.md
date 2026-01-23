# SMAMRASA - Software Architecture Design

## System Overview

**SMAMRASA** (Smart Medical Appointment Management and Remote Assistance System Architecture) is a comprehensive telemedicine platform designed for secure, scalable healthcare delivery.

---

## 1. High-Level Architecture

### Architecture Pattern: Microservices with Event-Driven Design

```
┌─────────────────────────────────────────────────────────────────┐
│                        API Gateway Layer                        │
│  (Authentication, Rate Limiting, Request Routing, TLS 1.3)     │
└─────────────────────────────────────────────────────────────────┘
                                   │
┌─────────────────────────────────────────────────────────────────┐
│                      Service Mesh Layer (Istio)                 │
│  (mTLS, Circuit Breaking, Load Balancing, Observability)       │
└─────────────────────────────────────────────────────────────────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        │                          │                          │
   ┌────▼─────┐              ┌─────▼─────┐            ┌──────▼──────┐
   │  Sync    │              │   Async   │            │   Event     │
   │ Services │              │  Services │            │   Bus       │
   │          │              │           │            │ (Kafka)     │
   └────┬─────┘              └─────┬─────┘            └──────┬──────┘
        │                          │                         │
        │                          │                         │
   ┌────▼──────────────────────────▼─────────────────────────▼─────┐
   │                    Data & Infrastructure Layer                │
   └───────────────────────────────────────────────────────────────┘
```

---

## 2. Microservices Breakdown

### 2.1 Core Services (Synchronous)

#### **Auth Service** (`auth-service`)
- **Purpose**: User authentication and authorization
- **Tech Stack**: Node.js + Express, Redis for session management
- **Endpoints**:
  - `POST /auth/login` - User login with MFA
  - `POST /auth/register` - User registration
  - `POST /auth/verify-mfa` - MFA verification
  - `GET /auth/validate` - Token validation
- **Database**: PostgreSQL (users table, roles table, sessions table)
- **Security**: JWT tokens, bcrypt for password hashing

#### **User Management Service** (`user-service`)
- **Purpose**: Patient and provider profile management
- **Tech Stack**: Node.js + Express
- **Endpoints**:
  - `GET /users/{id}` - Get user profile
  - `PUT /users/{id}` - Update profile
  - `POST /users/patient` - Create patient profile
  - `POST /users/provider` - Create provider profile
- **Database**: PostgreSQL (patients, providers, medical_history tables)

#### **Appointment Service** (`appointment-service`)
- **Purpose**: Intelligent appointment scheduling and management
- **Tech Stack**: Python + FastAPI
- **Endpoints**:
  - `POST /appointments` - Create appointment
  - `GET /appointments/doctor/{doctorId}` - Get doctor's schedule
  - `PUT /appointments/{id}/reschedule` - Reschedule appointment
  - `DELETE /appointments/{id}` - Cancel appointment
  - `POST /appointments/emergency` - Emergency appointment booking
- **Features**: AI-powered slot optimization, conflict detection
- **Database**: PostgreSQL (appointments, availability_slots tables)

#### **Video Consultation Service** (`video-service`)
- **Purpose**: Real-time video conferencing
- **Tech Stack**: Node.js + Socket.io, WebRTC
- **Endpoints**:
  - `POST /video/session` - Create consultation session
  - `GET /video/session/{id}` - Join session
  - `POST /video/session/{id}/end` - End session
- **Integration**: WebRTC for peer-to-peer video, TURN/STUN servers

### 2.2 Async Services (Background Processing)

#### **Notification Service** (`notification-service`)
- **Purpose**: Multi-channel notifications
- **Tech Stack**: Node.js + BullMQ (job queue)
- **Triggers**: Appointment reminders, emergency alerts, prescription notifications
- **Channels**: SMS (Twilio), Email (SendGrid), Push (Firebase)
- **Database**: PostgreSQL (notifications table)

#### **IoT Integration Service** (`iot-service`)
- **Purpose**: IoT device management and data ingestion
- **Tech Stack**: Go + MQTT broker (Eclipse Mosquitto)
- **Endpoints**:
  - `POST /iot/device/register` - Register device
  - `POST /iot/device/pair` - Pair device to patient
  - `GET /iot/data/{patientId}` - Get vital signs
- **Protocols**: MQTT, HTTP/HTTPS
- **Database**: TimescaleDB (time-series data for vitals)

#### **Emergency Triage Service** (`triage-service`)
- **Purpose**: AI-powered symptom analysis and prioritization
- **Tech Stack**: Python + FastAPI + TensorFlow/PyTorch
- **Endpoints**:
  - `POST /triage/assess` - Assess symptoms
  - `GET /triage/priority/{appointmentId}` - Get priority level
- **Features**: ML model for symptom severity classification

#### **Prescription Service** (`prescription-service`)
- **Purpose**: Digital prescription management
- **Tech Stack**: Node.js + Express
- **Endpoints**:
  - `POST /prescriptions` - Create prescription
  - `GET /prescriptions/patient/{id}` - Get patient prescriptions
  - `POST /prescriptions/{id}/fill` - Mark as filled
- **Database**: PostgreSQL (prescriptions, medications tables)

### 2.3 Administrative Services

#### **Analytics Service** (`analytics-service`)
- **Purpose**: Reporting and metrics
- **Tech Stack**: Python + FastAPI + Apache Spark
- **Endpoints**:
  - `GET /analytics/appointments` - Appointment statistics
  - `GET /analytics/revenue` - Revenue reports
  - `GET /analytics/performance` - System performance metrics
- **Data Source**: Read replicas, data warehouse

#### **Billing Service** (`billing-service`)
- **Purpose**: Payment processing and invoicing
- **Tech Stack**: Node.js + Express
- **Endpoints**:
  - `POST /billing/invoice` - Generate invoice
  - `POST /billing/payment` - Process payment
  - `GET /billing/history/{patientId}` - Payment history
- **Integration**: Stripe, PayPal

---

## 3. Infrastructure & Data Layer

### 3.1 Database Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PostgreSQL Cluster (Primary)             │
│  - Users, Appointments, Prescriptions, Medical Records     │
│  - ACID compliance, Encryption at rest (AES-256)           │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼────┐        ┌─────▼────┐       ┌─────▼─────┐
   │ Read    │        │ Read     │       │ Read      │
   │ Replica │        │ Replica  │       │ Replica   │
   │ 1       │        │ 2        │       │ 3         │
   └─────────┘        └──────────┘       └───────────┘

┌─────────────────────────────────────────────────────────────┐
│              TimescaleDB (IoT Time-Series Data)             │
│  - Vital signs monitoring (heart rate, BP, SpO2, temp)     │
│  - Continuous aggregates for analytics                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Redis Cluster (Caching)                  │
│  - Session management, rate limiting, hot data             │
│  - Pub/Sub for real-time notifications                     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              Elasticsearch (Search & Logs)                  │
│  - Medical record search, audit logs, system logs          │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Message Queue & Event Bus

**Apache Kafka** - Event-driven communication
- **Topics**:
  - `appointments.created` - New appointment events
  - `appointments.cancelled` - Cancellation events
  - `notifications.send` - Notification requests
  - `vitals.alert` - Abnormal vital signs alerts
  - `triage.emergency` - Emergency case detection
  - `prescriptions.created` - Prescription events

### 3.3 Storage

- **Object Storage**: AWS S3 / Azure Blob Storage
  - Medical documents (PDFs, images)
  - Video consultation recordings
  - Audit logs backup

- **CDN**: CloudFront / Cloudflare
  - Static assets (web app, mobile app bundles)
  - Video streaming optimization

---

## 4. Security Architecture

### 4.1 HIPAA Compliance Framework

```
┌─────────────────────────────────────────────────────────────┐
│                    Security Layers                          │
├─────────────────────────────────────────────────────────────┤
│ 1. Network Security                                         │
│    - VPC with private subnets                              │
│    - WAF (Web Application Firewall)                        │
│    - DDoS protection                                        │
│    - VPN for administrative access                         │
├─────────────────────────────────────────────────────────────┤
│ 2. Access Control (RBAC)                                   │
│    - Patient: Read own data, book appointments             │
│    - Doctor: Read patient data, create prescriptions       │
│    - Admin: Full system access                             │
│    - IoT Device: Limited write access to vitals            │
├─────────────────────────────────────────────────────────────┤
│ 3. Data Encryption                                         │
│    - At Rest: AES-256 (PostgreSQL, S3)                     │
│    - In Transit: TLS 1.3 (HTTPS, mTLS for services)        │
│    - Key Management: AWS KMS / Azure Key Vault             │
├─────────────────────────────────────────────────────────────┤
│ 4. Authentication & MFA                                    │
│    - Multi-factor authentication required for all users    │
│    - OAuth 2.0 + OpenID Connect                            │
│    - Short-lived JWT tokens (15 min)                       │
│    - Refresh token rotation                                │
├─────────────────────────────────────────────────────────────┤
│ 5. Audit & Compliance                                      │
│    - Comprehensive audit logging (all access attempts)     │
│    - Automated compliance reporting                        │
│    - Data retention policies (7 years for medical records) │
│    - Regular security audits                               │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Security Monitoring

- **SIEM**: Splunk / ELK Stack for security event monitoring
- **IDS/IPS**: Network intrusion detection
- **Vulnerability Scanning**: Regular automated scans
- **Penetration Testing**: Quarterly security assessments

---

## 5. Scalability & Performance

### 5.1 Horizontal Scaling Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                       │
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                 │
│  │ Service  │  │ Service  │  │ Service  │                 │
│  │ Pod 1    │  │ Pod 2    │  │ Pod 3    │                 │
│  └──────────┘  └──────────┘  └──────────┘                 │
│        │             │             │                       │
│  ┌──────────────────────────────────────────┐              │
│  │         Horizontal Pod Autoscaler        │              │
│  │  CPU > 70% → Scale up to 10 replicas     │              │
│  │  CPU < 30% → Scale down to 2 replicas    │              │
│  └──────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 Load Balancing

- **Ingress Controller**: NGINX / Traefik
- **Load Balancer**: AWS ALB / Azure Load Balancer
- **CDN**: Static content caching
- **Database**: Read replicas for read-heavy operations

### 5.3 Caching Strategy

- **Redis**:
  - Session data (TTL: 15 min)
  - Doctor availability (TTL: 5 min)
  - Frequently accessed patient data (TTL: 10 min)
- **CDN**: Static assets, video chunks
- **Application-level**: In-memory cache for configuration

---

## 6. Disaster Recovery & Backup

### 6.1 Backup Strategy

```
Daily Backups:
├─ PostgreSQL: Full backup + WAL archiving
├─ TimescaleDB: Continuous backup
├─ S3: Versioning enabled
└─ Retention: 30 days

Weekly Backups:
├─ Encrypted snapshots
└─ Off-site replication (different region)

Monthly Backups:
├─ Compliance archive
└─ 7-year retention for medical records
```

### 6.2 Recovery Objectives

- **RTO (Recovery Time Objective)**: < 4 hours
- **RPO (Recovery Point Objective)**: < 1 hour
- **Failover**: Multi-AZ deployment with automatic failover

---

## 7. Monitoring & Observability

### 7.1 Monitoring Stack

```
┌─────────────────────────────────────────────────────────────┐
│                    Observability Platform                   │
├─────────────────────────────────────────────────────────────┤
│  Metrics: Prometheus + Grafana                             │
│  - Service health, response times, resource usage          │
│  - Business metrics (appointments, consultations)          │
├─────────────────────────────────────────────────────────────┤
│  Logging: ELK Stack (Elasticsearch, Logstash, Kibana)      │
│  - Centralized log aggregation                             │
│  - HIPAA-compliant log retention                           │
├─────────────────────────────────────────────────────────────┤
│  Tracing: Jaeger / OpenTelemetry                           │
│  - Distributed tracing across microservices                │
│  - Performance bottleneck identification                   │
├─────────────────────────────────────────────────────────────┤
│  Alerting: PagerDuty / Opsgenie                            │
│  - Critical: Page on-call engineer                         │
│  - Warning: Slack/Email notifications                      │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 Key Metrics to Monitor

- **System Metrics**: CPU, memory, disk, network
- **Application Metrics**: Response time, error rate, throughput
- **Business Metrics**:
  - Appointment booking rate
  - Consultation completion rate
  - Patient satisfaction scores
  - Emergency response time
- **Security Metrics**: Failed login attempts, unauthorized access attempts

---

## 8. Deployment Architecture

### 8.1 CI/CD Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                    Git Repository (GitHub)                  │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              CI Pipeline (GitHub Actions)                   │
│  1. Code linting & formatting                              │
│  2. Unit tests                                             │
│  3. Security scanning (SAST, dependency scan)              │
│  4. Build Docker images                                    │
│  5. Integration tests                                      │
│  6. Push to container registry (ECR/ACR)                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              CD Pipeline (ArgoCD / Flux)                    │
│  1. Deploy to staging environment                          │
│  2. Automated E2E tests                                    │
│  3. Manual approval for production                         │
│  4. Blue-green deployment to production                    │
│  5. Automated rollback on failure                          │
└─────────────────────────────────────────────────────────────┘
```

### 8.2 Environments

- **Development**: Local Docker Compose for developers
- **Staging**: Mirror of production, used for testing
- **Production**: Multi-AZ, auto-scaling, full monitoring

---

## 9. Technology Stack Summary

| Layer | Technology | Justification |
|-------|------------|---------------|
| **Frontend** | React + TypeScript | Type safety, component reusability |
| **Mobile** | React Native | Cross-platform, code sharing |
| **API Gateway** | Kong / AWS API Gateway | Rate limiting, authentication |
| **Services** | Node.js, Python, Go | Best tool for each job |
| **Service Mesh** | Istio | mTLS, traffic management |
| **Message Queue** | Apache Kafka | High throughput, durability |
| **Cache** | Redis Cluster | Low latency, pub/sub |
| **Primary DB** | PostgreSQL | ACID compliance, JSON support |
| **Time-Series DB** | TimescaleDB | IoT data optimization |
| **Search** | Elasticsearch | Full-text search, aggregations |
| **Storage** | AWS S3 / Azure Blob | Scalable object storage |
| **CDN** | Cloudflare / CloudFront | Global content delivery |
| **Container Orchestration** | Kubernetes | Auto-scaling, self-healing |
| **Monitoring** | Prometheus + Grafana | Metrics visualization |
| **Logging** | ELK Stack | Centralized log management |
| **Tracing** | OpenTelemetry | Distributed tracing |
| **CI/CD** | GitHub Actions + ArgoCD | Automated deployment |
| **Security** | Vault, KMS | Secrets management, encryption |

---

## 10. Implementation Roadmap

### Phase 1: Foundation (Months 1-3)
- [ ] Set up infrastructure (Kubernetes, databases, networking)
- [ ] Implement Auth Service with MFA
- [ ] Build User Management Service
- [ ] Create basic Appointment Service
- [ ] Set up CI/CD pipeline
- [ ] Configure monitoring and logging

### Phase 2: Core Features (Months 4-6)
- [ ] Develop Video Consultation Service (WebRTC)
- [ ] Implement Notification Service
- [ ] Build Prescription Service
- [ ] Create Patient Portal (Web)
- [ ] Set up security framework (HIPAA compliance)
- [ ] Implement backup and disaster recovery

### Phase 3: Advanced Features (Months 7-9)
- [ ] IoT Integration Service
- [ ] Emergency Triage Service (AI/ML)
- [ ] Doctor Portal (Web)
- [ ] Mobile Apps (iOS/Android)
- [ ] Analytics & Reporting Dashboard
- [ ] Billing & Payment Integration

### Phase 4: Optimization & Scale (Months 10-12)
- [ ] Performance optimization
- [ ] Load testing and scaling
- [ ] Security audit and penetration testing
- [ ] HIPAA compliance certification
- [ ] Production deployment
- [ ] User training and documentation

---

## 11. Cost Estimation (Monthly - AWS)

| Resource | Estimated Cost |
|----------|----------------|
| **Compute (EKS + EC2)** | $2,500 - $5,000 |
| **Database (RDS PostgreSQL)** | $800 - $1,500 |
| **Cache (ElastiCache Redis)** | $200 - $400 |
| **Storage (S3)** | $100 - $300 |
| **CDN (CloudFront)** | $150 - $350 |
| **Load Balancer** | $100 - $200 |
| **Monitoring & Logging** | $300 - $600 |
| **Security Tools** | $200 - $400 |
| **Data Transfer** | $200 - $500 |
| **Total** | **$4,550 - $9,250** |

*Cost scales with usage. Initial estimate for 10,000 active users.*

---

## 12. Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| **HIPAA Violation** | Critical | Regular audits, encryption, access controls |
| **Data Breach** | Critical | MFA, encryption, monitoring, incident response plan |
| **Service Downtime** | High | Multi-AZ, auto-scaling, DR plan, 99.9% SLA |
| **Scalability Issues** | High | Microservices, horizontal scaling, load testing |
| **Integration Failures** | Medium | API contracts, comprehensive testing, fallback mechanisms |
| **Regulatory Changes** | Medium | Compliance team, flexible architecture |

---

## Conclusion

This architecture provides a **secure, scalable, and compliant** foundation for the SMAMRASA telemedicine platform. It addresses all requirements from the SRS while maintaining flexibility for future enhancements.

**Key Strengths:**
- ✅ HIPAA-compliant security architecture
- ✅ Microservices for independent scaling
- ✅ Event-driven design for real-time features
- ✅ Comprehensive monitoring and observability
- ✅ Disaster recovery and business continuity
- ✅ Multi-platform support (web, mobile, desktop)

**Next Steps:**
1. Review and approve architecture
2. Begin Phase 1 implementation
3. Set up development environment
4. Create detailed technical specifications for each service

---

*Document Version: 1.0*
*Last Updated: 2026-01-15*
*Author: Architecture Design Team*
