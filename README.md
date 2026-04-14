# 📦 Monolith to Microservices: A Hands-on Journey with Docker & Jenkins

[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-blue?logo=jenkins)](https://www.jenkins.io/)
[![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker)](https://www.docker.com/)
[![AWS](https://img.shields.io/badge/AWS-EC2_Deployed-FF9900?logo=amazonaws)](https://aws.amazon.com/)
[![Java](https://img.shields.io/badge/Java-Tomcat_17-orange?logo=java)](https://adoptium.net/)

---

## 📑 Table of Contents
1. [🎯 Project Description: A Journey into Containerization](#-project-description)
2. [🐳 The Containerization Strategy (How & Why)](#️-problems-we-solved)
3. [🏗️ Architecture & Tech Stack](#️-architecture--tech-stack)
4. [🚀 How We Achieved This Project](#-how-we-achieved-this-project)
5. [⚡ Getting Started](#-getting-started)
6. [📊 Pipeline Metrics & Results](#-pipeline-metrics--results)

---

## 🎯 1. Project Description: A Journey into Containerization

This project isn't just about building a Netflix clone—it serves as my personal, hands-on laboratory for mastering **Docker, microservices, and CI/CD automation**. I utilized a basic full-stack Netflix mock application as a "guinea pig" to learn how to break down a monolithic application into isolated, deployable containers.

By containerizing this application, I shifted my focus from *writing* code to *shipping* code reliably across any environment.

---

## 🐳 2. The Containerization Strategy (How & Why)

To truly understand microservices, I split the application into distinct environments, requiring separate Docker configurations.

### **The Dockerfiles**
Instead of cramming everything into one server, I wrote two separate `Dockerfile` configurations to isolate the environments:
1.  **Frontend (Root Directory):** I created a Dockerfile using `tomcat:9-jre17-temurin-jammy` as the base image. **Why?** The frontend is a compiled Java `.war` artifact. It requires a specific Java Runtime Environment and an Apache Tomcat server to host the web pages. Using the `jammy` tag was a crucial learning moment to ensure modern memory management (`cgroup v2`) compatibility on cloud instances.
2.  **Backend (`/backend` Directory):** I created a separate Dockerfile using a lightweight `node:alpine` image. **Why?** The backend is a completely different tech stack (JavaScript/Node.js). By isolating it, the Node API runs independently of the Java frontend, meaning if the frontend crashes, the backend API stays alive.

### **Orchestration with `docker-compose.yml`**
Managing multiple standalone containers manually via the terminal is prone to errors. I wrote a `docker-compose.yml` file to act as the "conductor" for the containers. This taught me how to:
* **Map Ports:** Bridging the host machine to the containers (e.g., exposing the isolated Tomcat port `8080` to the public port `9090`).
* **Manage Dependencies:** Using `depends_on` to ensure the Node.js backend waits for the MySQL database to start before trying to connect.
* **Persist Data:** Utilizing volumes to map my local `init.sql` file directly into the MySQL container's entry point, automating the database setup on boot.

### **Container Architecture Diagram**

```mermaid
graph LR
    Command["Terminal Command: docker compose up -d"] --> Orchestrator
    
    subgraph "🐳 Docker Host Environment"
        Orchestrator{{"Docker Compose Network"}}
        
        Front["🎨 Frontend Container<br/>Port 9090:8080<br/>Java / Tomcat"]
        Back["⚙️ Backend Container<br/>Port 5000:5000<br/>Node.js API"]
        DB[("💾 Database Container<br/>Port 3306:3306<br/>MySQL 8.0")]
        
        Orchestrator --> Front
        Orchestrator --> Back
        Orchestrator --> DB
        
        Front -.->|"API Fetch Request"| Back
        Back -.->|"Read/Write User Data"| DB
    end

    classDef container fill:#e3f2fd,stroke:#1976d2,stroke-width:2px,color:#000
    class Front,Back,DB container
```
## 🏗️ 3. Architecture & Tech Stack

```mermaid
graph TB
    subgraph "🌐 Version Control"
        Git[🐙 GitHub Repository]
    end
    
    subgraph "⚡ CI/CD Pipeline (Jenkins)"
        Build[📦 Maven Build & Test]
        Image[🐳 Docker Build & Tag]
        Push[☁️ Push to Docker Hub]
    end
    
    subgraph "🗄️ Production Environment (AWS EC2)"
        Front[🎨 Tomcat Frontend<br/>Port 9090]
        Back[⚙️ Node.js Backend<br/>Port 5000]
        DB[(💾 MySQL Database<br/>Port 3306)]
    end

   %% Flow
    Git -->|Webhook Trigger| Build
    Build --> Image
    Image --> Push
    Push -->|docker compose up -d| Front 
    Push -->|docker compose up -d| Back
    Back --> DB
    

    classDef tools fill:#e3f2fd,stroke:#1976d2,stroke-width:2px,color:#000
    classDef prod fill:#e8f5e8,stroke:#388e3c,stroke-width:2px,color:#000
    class Git,Build,Image,Push tools
    class Front,Back,DB prod
```
## 🏗️ The Stack

* **Infrastructure:** AWS EC2, Docker, Docker Hub
* **Automation:** Jenkins, Groovy (Pipeline as Code), Maven
* **Application:** Java 17, Apache Tomcat 9, Node.js, MySQL 8.0

---

## 🚀 4. How We Achieved This Project

### Phase 1: Architecture & Containerization
* **Approach:** Transitioned from bare-metal execution to a microservices mindset.
* **Execution:** Authored optimized `Dockerfiles` for the frontend and backend, utilizing multi-stage builds where necessary. Linked services using a centralized `docker-compose.yml` with persistent volume mapping for the database injection (`init.sql`).

### Phase 2: Pipeline Automation
* **Approach:** Implemented "Configuration as Code" to eliminate manual server interactions.
* **Execution:** Developed a robust `Jenkinsfile` featuring parallel image building (`failFast true`) and secure credential injection via Jenkins environment variables to authenticate with Docker Hub.

### Phase 3: Cloud Deployment & Networking
* **Approach:** Ensure secure, dynamic accessibility over the public internet.
* **Execution:** Provisioned an AWS EC2 instance, configured Security Groups for selective port exposure, and refactored frontend JavaScript to dynamically resolve the host IP, ensuring the API connection remains stable across instance reboots.

---

## ⚡ 5. Getting Started

### Prerequisites
* Docker & Docker Compose installed
* Port `9090` and `5000` available on your host/EC2 instance

### Quick Spin-Up

```bash
# 1. Clone the repository
git clone [https://github.com/yourusername/your-repo.git](https://github.com/yourusername/your-repo.git)

# 2. Navigate to the directory
cd your-repo

# 3. Launch the environment in detached mode
docker compose up -d

# 4. Verify containers are running
docker ps
```
**Access the application live at http://localhost:9090 (or your EC2 Public IP).**

## 📸 6. Project Showcase & Visual Proof
### 🎥 Live CI/CD Pipeline Demonstration
*(Click the image below or watch the embedded video to see the pipeline in action)*

https://github.com/user-attachments/assets/d51dd255-d92b-4a5e-8254-1518c5208d1c

**What happens in this demo:**
1. **Trigger:** A developer modifies the frontend code in the repository (changing the header from "Trending Now" to "Top Picks for You").
2. **Automation:** The commit instantly triggers the Jenkins pipeline.
3. **Parallel Execution:** Jenkins compiles the Java artifact and utilizes multiple executors to build and push the Frontend and Backend Docker images to Docker Hub simultaneously.
4. **Zero-Downtime Deployment:** The EC2 instance pulls the latest `parte15/netflix-frontend:7` image and redeploys the containers.
5. **Live Result:** The live production site on AWS dynamically updates without manual server intervention.

---

### 🖥️ Application Interface

<img width="800" height="900" alt="Screenshot 2026-04-12 230719" src="https://github.com/user-attachments/assets/6e3b78a5-9511-46bb-85d5-9a608847a17f" />

* **Secure Authentication (Left):** The custom login gateway routing credentials to the containerized Node.js backend.
* **Dynamic Frontend (Right):** The fully rendered Tomcat application successfully fetching and displaying the media catalog over the public internet on port `9090`.

---

### ☁️ Cloud Infrastructure & Container Orchestration

<img width="800" height="900" alt="Screenshot 2026-04-12 232622" src="https://github.com/user-attachments/assets/d089c441-ba92-4862-8090-8d227a93aa1b" />


* **AWS EC2 Provisioning (Left):** The underlying infrastructure hosted on an AWS `t3.medium` instance, configured with custom Security Groups to expose the required application ports.
* **Containerized Database Management (Right):** Direct terminal access showing the orchestration of three interconnected containers (`frontend`, `backend`, `db`). The terminal also demonstrates a secure interactive session into the MySQL container, verifying that the `init.sql` script successfully seeded the database with user credentials.

---

### ⚙️ Automated Jenkins Pipeline & Parallel Execution

<img width="1919" height="1079" alt="Screenshot 2026-04-13 023607" src="https://github.com/user-attachments/assets/259f6123-9122-4d5a-aa22-c65446d30a91" />

* **Declarative Pipeline as Code:** The entire build, test, and deployment lifecycle is managed by a highly structured `Jenkinsfile` stored directly in the version control system.
* **Build Optimization (Parallelization):** As seen in the *Build & Push Docker Images* stage, the pipeline splits into concurrent execution threads. The Frontend and Backend Docker images are built and pushed to Docker Hub simultaneously, significantly reducing the total pipeline run time and optimizing EC2 compute resources.
* **Continuous Delivery:** The final *Deploy Containers* stage automatically pulls the newly tagged images and dynamically injects them into the running Docker Compose environment with zero manual intervention.

### 🗄️ Peeking Inside the Container Matrix

<img width="1919" height="1079" alt="Screenshot 2026-04-12 232757" src="https://github.com/user-attachments/assets/0c37e99c-bc31-48bc-8766-31f787ed78cc" />

A critical part of my containerization journey was learning that containers are fully isolated environments. I couldn't just open a local database GUI to see my users; I had to learn how to "step inside" the running container on the AWS server to verify my data. 

This screenshot demonstrates my live debugging and verification flow:

1. **Network Verification (`docker ps -a`):** First, I verified that all three microservices (Frontend, Backend, DB) were actively running and that my `docker-compose.yml` had successfully bridged the internal container ports to the external EC2 host ports.
2. **Breaching the Container (`docker exec`):** I used the `exec` command to open an interactive bash shell directly inside the isolated MySQL container (`81bde3db36ab`).
3. **Data Validation:** Once inside the container, I logged into the MySQL monitor to manually run a query. This proved that my `init.sql` volume mapping worked perfectly, seeding the database with the `admin@netflix.com` credentials right on boot!

**The exact command flow used in the terminal:**
```bash
# 1. Identify the running containers and ports
root@ip-172-31-37-40:~# docker ps -a

# 2. Drop into the database container's interactive shell
root@ip-172-31-37-40:~# docker exec -it 81bde3db36ab bash

# 3. Log into MySQL and query the seeded user data
bash-5.1# mysql -u root -pnetflix_pass
mysql> USE netflix_db;
mysql> SELECT * FROM users;
```
