# SMAMRASA Project Structure

```
smamrasa/
├── README.md
├── docker-compose.yml
├── .env.example
├── .gitignore
├── package.json (workspace root)
├── infrastructure/
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── modules/
│   │   │   ├── eks/
│   │   │   ├── rds/
│   │   │   ├── vpc/
│   │   │   └── s3/
│   ├── kubernetes/
│   │   ├── base/
│   │   │   ├── namespace.yaml
│   │   │   ├── ingress.yaml
│   │   │   └── cert-manager.yaml
│   │   ├── overlays/
│   │   │   ├── dev/
│   │   │   ├── staging/
│   │   │   └── prod/
│   ├── docker/
│   │   ├── nginx/
│   │   │   └── nginx.conf
│   │   └── keycloak/
│   └── monitoring/
│       ├── prometheus/
│       ├── grafana/
│       └── alertmanager/
├── services/
│   ├── auth-service/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   ├── src/
│   │   │   ├── app.js
│   │   │   ├── routes/
│   │   │   ├── controllers/
│   │   │   ├── models/
│   │   │   ├── middleware/
│   │   │   ├── services/
│   │   │   ├── utils/
│   │   │   └── config/
│   │   ├── tests/
│   │   └── .env
│   ├── user-service/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   ├── src/
│   │   └── tests/
│   ├── appointment-service/
│   │   ├── Dockerfile
│   │   ├── pyproject.toml
│   │   ├── app/
│   │   │   ├── __init__.py
│   │   │   ├── main.py
│   │   │   ├── models/
│   │   │   ├── routes/
│   │   │   ├── services/
│   │   │   └── utils/
│   │   ├── tests/
│   │   └── requirements.txt
│   ├── notification-service/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   ├── src/
│   │   └── tests/
│   ├── video-service/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   ├── src/
│   │   └── tests/
│   ├── iot-service/
│   │   ├── Dockerfile
│   │   ├── go.mod
│   │   ├── cmd/
│   │   ├── internal/
│   │   └── pkg/
│   ├── prescription-service/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   ├── src/
│   │   └── tests/
│   ├── triage-service/
│   │   ├── Dockerfile
│   │   ├── pyproject.toml
│   │   ├── app/
│   │   └── ml-models/
│   ├── analytics-service/
│   │   ├── Dockerfile
│   │   ├── pyproject.toml
│   │   ├── app/
│   │   └── notebooks/
│   └── billing-service/
│       ├── Dockerfile
│       ├── package.json
│       ├── src/
│       └── tests/
├── web/
│   ├── patient-portal/
│   │   ├── package.json
│   │   ├── public/
│   │   ├── src/
│   │   │   ├── components/
│   │   │   ├── pages/
│   │   │   ├── hooks/
│   │   │   ├── utils/
│   │   │   └── styles/
│   │   ├── Dockerfile
│   │   └── .env
│   ├── doctor-portal/
│   │   ├── package.json
│   │   ├── public/
│   │   ├── src/
│   │   │   ├── components/
│   │   │   ├── pages/
│   │   │   ├── hooks/
│   │   │   ├── utils/
│   │   │   └── styles/
│   │   ├── Dockerfile
│   │   └── .env
│   └── admin-portal/
│       ├── package.json
│       ├── public/
│       ├── src/
│       └── Dockerfile
├── mobile/
│   ├── patient-app/
│   │   ├── package.json
│   │   ├── app/
│   │   │   ├── (tabs)/
│   │   │   ├── components/
│   │   │   ├── hooks/
│   │   │   ├── services/
│   │   │   └── utils/
│   │   ├── android/
│   │   ├── ios/
│   │   └── app.json
│   └── doctor-app/
│       ├── package.json
│       ├── app/
│       ├── android/
│       ├── ios/
│       └── app.json
├── shared/
│   ├── common-types/
│   │   ├── package.json
│   │   └── src/
│   ├── api-client/
│   │   ├── package.json
│   │   └── src/
│   └── ui-components/
│       ├── package.json
│       └── src/
├── gateway/
│   ├── Dockerfile
│   ├── kong/
│   │   ├── kong.yml
│   │   └── Dockerfile
│   └── nginx/
│       └── nginx.conf
├── message-queue/
│   ├── kafka-topics.yml
│   └── consumers/
│       ├── notification-consumer/
│       └── alert-consumer/
├── database/
│   ├── migrations/
│   │   ├── 001-init.sql
│   │   ├── 002-users.sql
│   │   ├── 003-appointments.sql
│   │   ├── 004-iot.sql
│   │   └── 005-prescriptions.sql
│   ├── seeds/
│   │   └── sample-data.sql
│   └── migrations-timescale/
│       └── 001-init-timescale.sql
├── ci-cd/
│   ├── github-actions/
│   │   ├── workflows/
│   │   │   ├── test.yml
│   │   │   ├── build.yml
│   │   │   ├── deploy-dev.yml
│   │   │   └── deploy-prod.yml
│   ├── argocd/
│   │   ├── app-of-apps.yaml
│   │   └── smamrasa-app.yaml
│   └── scripts/
│       ├── deploy.sh
│       ├── migrate.sh
│       └── backup.sh
├── docs/
│   ├── architecture/
│   ├── api/
│   ├── user-guides/
│   └── security/
├── tests/
│   ├── e2e/
│   ├── integration/
│   └── load/
├── scripts/
│   ├── setup.sh
│   ├── dev.sh
│   ├── seed-db.sh
│   └── cleanup.sh
└── .github/
    └── ISSUE_TEMPLATE/
```
