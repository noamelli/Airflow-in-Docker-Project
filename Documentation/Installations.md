# Installations
This guide will take you through the process of installing Git and Docker, as well as running airflow using Docker Compose. 

## Prerequisites
Before you begin, ensure that you have the following:
1. A terminal or command prompt on your computer.
2. Administrative privileges on your computer.
3. A working internet connection.
4. Visual Studio Code.

## Instructions
### Step 1: Install Git
Git is a version control system that is used to manage source code. To install Git on your computer, follow the steps below:
1. Open your terminal or command prompt.  
2. On Windows, download the Git installer from https://git-scm.com/downloads and follow the prompts to install Git. On Mac and Linux, Git is typically pre-installed.
3. Once Git is installed, open your terminal or command prompt and run the following command to verify that Git is installed:
`git --version`  
4. If Git is installed correctly, you should see the version number displayed in your terminal or command prompt.


### Step 2: Install Docker
Docker is a platform that allows you to create, deploy, and run applications in containers. To install Docker on your computer, follow the steps below:
1. Open your terminal or command prompt.
2. Download the Docker Desktop installer from https://docs.docker.com/desktop/install/windows-install/ 
and follow the prompts to install Docker Desktop.
3. Once Docker is installed, open your terminal or command prompt and run the following command to verify that Docker is installed: docker --version
4. If Docker is installed correctly, you should see the version number displayed in your terminal or command prompt.

### Step 3: Clone Git Repository
1. Open your terminal or command prompt.
2. Navigate to the directory where you want to clone the Git repository.
3. Run the following command to clone the repository: 
    git clone https://github.com/noamelli/carasso.git

### Step 4: Run Airflow Using Docker Compose
1. Open your terminal or command prompt.
2. Navigate to the directory where you cloned the Git repository.
3. Make sure Docker compose was successfully installed by this command: docker-compose – version
4. Run these commands in order to create a project folder in visual studio code:
    1. mkdir airflow-docker
    2. cd airflow-docker
    3. code .
It will open the VS code - open a new terminal. 
5. Go to the part of fetching docker-compose.yaml in Airflow documentation and copy the path without this: -Lf0. At the end of the path add this: ‘docker-compose.yaml’. After pasting in the terminal, you will get the yaml file, which is used to define and configure Docker applications.
6. Run the following commands: 
    1. mkdir dags
    2. mkdir logs
    3. mkdir plugins
7. Run the following command to initialize airflow: docker compose up airflow-init
8. Run the following command to start the containers defined in your Docker Compose file: docker compose up
9. Make sure the docker desktop is open, unless you won't be able to enter the airflow web server. 
10. Open localhost:8080 and sign in with username and password (the default value is airflow)
11. If you need to close all the docker containers use this command: docker compose down.


### Step 5: Connect Airflow to Postgresql 
1. Open the yaml file in VS code and add these lines: 
    ports:
      - 5432:5432
    * paste them after these linse:
    services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_USER: airflow
      POSTGRES_PASSWORD: airflow
      POSTGRES_DB: airflow
    volumes:
      - postgres-db-volume:/var/lib/postgresql/data
      
2. Command this line in the terminal:  docker-compose up -d --no-deps --build postgres. 
3. Download DBeaver Community for windows.Its a free cross-platform database tool. Our tables will be stored in this DB. 
4. Open the tool, connect to a database and choose postgresql. 
5. fulfill the details:
    1. connect by: host.
    2. host: localhost. 
    3. database: postgres.
    4. port: 5432.
    5. username and password of the airflow web server. 
6. In the postgresql tab choose show all databases. 
7. Press test connection. It might ask us to install some drivers. We will make sure the connection ends successfully. 
8. Create a new database in dbeaver. 
9. Create a new connection to postgres : airflow web server → admin → connection → new connection.
    1. conn id: postgres_localhost.
    2. conn type: postgres.
    3. database : the name of the db we created.
    4. login and password of airflow web server.
    5. port :5432.
    6. host: host.docker.internal.
