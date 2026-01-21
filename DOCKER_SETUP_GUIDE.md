# Docker Setup and Deployment Guide

This guide provides step-by-step instructions for setting up the Facility ERP application locally using Docker and uploading container images to Docker Hub.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) installed and running.
- [Docker Hub](https://hub.docker.com/) account (for uploading images).

---

## Part 1: Local Setup

### 1. Configuration

1.  Copy the example environment file:
    ```bash
    cp env.example .env
    ```
2.  Open `.env` and fill in the required values (or leave defaults for testing).

### 2. Start Services

To build and start all services (Backend, Frontend, Database) in detached mode:

```bash
docker-compose up -d --build
```

### 3. Verify Installation

- **Frontend**: Open [http://localhost:80](http://localhost:80)
- **Backend API**: Check [http://localhost:3000/api/v1/health](http://localhost:3000/api/v1/health)
- **Database**: Connecting on port `5432`

### 4. Database Initialization

Run migrations to set up the database schema:

```bash
# Enter the backend container
docker exec -it facility-erp-backend sh

# Run migrations (inside container)
npm run migration:run
```

### 5. Stop Services

```bash
docker-compose down
```

---

## Part 2: Uploading to Docker Hub

This section guides you through building and pushing images individually.

### 1. Login to Docker Hub

Open your terminal and log in:

```bash
docker login
```

### 2. Build and Tag Images

Replace `your-dockerhub-username` with your actual username.

**Backend:**

```bash
# Build
docker build -t your-dockerhub-username/facility-erp-backend:latest ./apps/backend

# Push
docker push your-dockerhub-username/facility-erp-backend:latest
```

**Frontend:**

```bash
# Build
docker build -t your-dockerhub-username/facility-erp-frontend:latest ./apps/frontend

# Push
docker push your-dockerhub-username/facility-erp-frontend:latest
```

### 3. Verify on Docker Hub

Go to your [Docker Hub repositories](https://hub.docker.com/repositories) to confirm the images have been pushed successfully.

---

## Troubleshooting

- **Port Conflicts**: Ensure ports `80`, `3000`, and `5432` are not being used by other applications.
- **Database Connection**: If the backend fails to connect, ensure the `postgres` service is healthy (`docker-compose ps`).
