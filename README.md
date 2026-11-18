# StreamFlix

Team members + student number <br>
Annemiek Veld 5658586 <br>
Jessica Fernandes Camacho 5678285<br>
Aynur Tozluyurt 5746507<br>
Caleb Gaïtou 5680891



StreamFlix is a streaming platform application developed as part of the **Data Processing module at NHL Stenden University of Applied Sciences**.

The project focuses on developing a backend application using Java, Spring Boot and PostgreSQL, with an emphasis on relational database design, SQL, database security and REST APIs.

## 1. Technologies

| Technology | Purpose |
|---|---|
| Java 17 | Backend programming language |
| Spring Boot 4.1.2 | Backend application framework |
| Maven | Dependency management and building |
| PostgreSQL 17 | Relational database |
| Spring JDBC | Database connectivity |
| Docker | Application containerization |
| Docker Compose | Managing application and database containers |
| IntelliJ IDEA | Development environment |

## 2. Project Structure

```text
StreamFlix/
├── .env.example
├── .gitignore
├── compose.yaml
├── README.md
└── demo/
    ├── .mvn/
    ├── src/
    │   ├── main/
    │   │   ├── java/com/example/demo/
    │   │   │   ├── DemoApplication.java
    │   │   │   └── DatabaseTestController.java
    │   │   └── resources/
    │   │       └── application.properties
    │   └── test/
    ├── .dockerignore
    ├── Dockerfile
    ├── mvnw
    ├── mvnw.cmd
    └── pom.xml
```

## 3. Prerequisites

Before running the application, make sure the following software is installed:

- Git
- Docker Desktop with Docker Compose
- Java JDK 17 (for local development)
- IntelliJ IDEA or another Java IDE

Maven does not need to be installed separately because the project includes the Maven Wrapper.

## 4. Getting Started

### Step 1: Clone the Repository

Open a terminal and run:

```bash
git clone https://github.com/Aynur17/StreamFlix.git
cd StreamFlix
```

### Step 2: Configure Environment Variables

In the root directory, create a file named `.env`.

Use `.env.example` as a template:

```dotenv
POSTGRES_USER=streamflix_admin
POSTGRES_PASSWORD=your_secure_password
```

Replace `your_secure_password` with a strong local password.

**Important:** Never commit the `.env` file to GitHub. It contains private credentials and is excluded using `.gitignore`.

Each developer should create their own `.env` file.

### Step 3: Start Docker Desktop

Open Docker Desktop and wait until the Docker Engine is running.

Verify Docker is available:

```bash
docker --version
docker compose version
```

### Step 4: Build and Start the Application

From the root StreamFlix directory, execute:

```bash
docker compose up --build -d
```

Docker Compose will:

1. Download the PostgreSQL image if necessary.
2. Create the PostgreSQL database.
3. Build the Spring Boot application.
4. Start the database container.
5. Start the API container once PostgreSQL is healthy.

### Step 5: Verify the Containers

```bash
docker compose ps
```

Expected containers:

| Container | Description | Port |
|---|---|---|
| streamflix-api | Spring Boot backend | 8081 |
| streamflix-db | PostgreSQL database | 5432 |

The PostgreSQL container should show a healthy status.

## 5. Testing the Application

### Spring Boot API

The application is accessible at:

http://localhost:8081

A `404 Not Found` response at the root URL is normal until a root endpoint has been implemented.

### Database Connection Test

A temporary development endpoint is available at:

http://localhost:8081/api/test/database

Expected response:

```json
{
  "status": "connected",
  "database": "streamflix"
}
```

This confirms that Spring Boot can communicate with PostgreSQL using JDBC.

**Note:** This endpoint is intended for development and should be removed or replaced with an appropriate health check before production deployment.

### Test PostgreSQL Directly

```bash
docker compose exec database psql -U streamflix_admin -d streamflix
```

Inside PostgreSQL, execute:

```sql
SELECT current_database(), current_user;
```

Exit PostgreSQL using:

```text
\q
```

## 6. Running the Application Locally

The application can also be run directly through IntelliJ IDEA.

First, start the PostgreSQL container:

```bash
docker compose up -d database
```

Then configure the following environment variables in the IntelliJ Run Configuration:

```text
DB_URL=jdbc:postgresql://localhost:5432/streamflix
DB_USERNAME=streamflix_admin
DB_PASSWORD=<your local database password>
```

Run `DemoApplication.java`.

By default, Spring Boot uses port `8080` when running directly on your computer.

When running through Docker Compose, the API is accessible on port `8081`.

Avoid running both versions on the same host port.

## 7. Useful Docker Commands

| Command | Description |
|---|---|
| `docker compose up --build -d` | Build and start containers |
| `docker compose ps` | View container status |
| `docker compose logs -f api` | Follow Spring Boot logs |
| `docker compose logs -f database` | Follow database logs |
| `docker compose restart api` | Restart the API |
| `docker compose down` | Stop and remove containers |
| `docker compose up -d` | Start existing containers |

**Warning:** Running `docker compose down -v` also removes the database volume and deletes locally stored database data.

## 8. Building with Maven

Navigate to the `demo` directory:

```bash
cd demo
```

On Windows:

```powershell
.\mvnw.cmd clean package
```

On Linux or macOS:

```bash
./mvnw clean package
```

To execute the tests:

```bash
./mvnw test
```

On Windows, use `.\mvnw.cmd test`.

The compiled application is generated in the `target` directory.

## 9. Database Configuration

The PostgreSQL database is configured through Docker Compose.

Default database details:

| Setting | Value |
|---|---|
| Database | streamflix |
| Host inside Docker | database |
| Host from local machine | localhost |
| Port | 5432 |
| Initial database user | streamflix_admin |
| Password | Defined in `.env` |

Spring Boot reads the connection settings from environment variables configured in `application.properties`.

The initial administrative database user is intended for development and database setup. The assignment also requires a restricted API database account with appropriate permissions, which will be implemented separately.

## 10. Development Workflow

When working on the project:

1. Pull the latest changes from GitHub.
2. Make changes to the application.
3. Run Maven tests and verify the build.
4. Rebuild the Docker application if necessary.
5. Test the API and database functionality.
6. Commit and push the relevant source files.

Example:

```bash
git pull origin main
docker compose up --build -d
```

Before committing, verify that no passwords, `.env` files or generated build files are included.

Coordinate changes to the `main` branch with the rest of the team.

## 11. Planned Functionality

The StreamFlix application will be developed to support:

- User accounts and authentication
- User profiles and age restrictions
- Movie and series catalog management
- Subscription plans and payments
- Watchlists and viewing history
- Database views, triggers and stored procedures
- Database roles and access restrictions
- REST API endpoints
- Automated testing and API documentation

These features are part of the intended project scope and are not all implemented yet.

## 12. Troubleshooting

### Docker Engine Not Running

Start Docker Desktop and wait until the Docker Engine is available.

### Port 8080 Already in Use

The Docker Compose configuration maps the application to port `8081` on the host.

Use:

http://localhost:8081

### Database Connection Failed

Verify the containers:

```bash
docker compose ps
```

Inspect logs:

```bash
docker compose logs api
docker compose logs database
```

Check that the database credentials in `.env` match the initialized PostgreSQL database.

If the database volume was created with a different password, changing `.env` alone will not update the existing PostgreSQL user's password.

### Maven Wrapper Not Found

Make sure the terminal is inside the `demo` directory before running `.\mvnw.cmd`.

## 13. Academic Context

**Institution:** NHL Stenden University of Applied Sciences  
**Module:** Data Processing  
**Project:** StreamFlix  
**Academic year:** 2026–2027

Developed as a collaborative student project.