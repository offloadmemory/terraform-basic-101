# The single set of values for the whole stack. One configuration, one file.
# When you later add a "staging" or "prod" environment, copy this folder and
# change the values here (see docs/ARCHITECTURE.md).

# ── Common ──
region  = "us-east-1"
profile = "dev"

# ── Network ──
vpc_name             = "basic-101-vpc"
vpc_cidr             = "10.0.0.0/16"
azs                  = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]

# ── Database ──
db_identifier        = "basic-101-db"
db_name              = "appdb"
db_username          = "appuser"
db_instance_class    = "db.t4g.micro"
db_allocated_storage = 20
db_subnet_group_name = "basic-101-db-subnet-group"

# ── ECS ──
cluster_name       = "basic-101-cluster"
service_name       = "basic-101-service"
alb_name           = "basic-101-alb"
container_image    = "kartikmanimuthu/hello-101:latest"
log_retention_days = 7
