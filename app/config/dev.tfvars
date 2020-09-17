#tags = "dev_app"
#cluster_endpoint_public_access = true
#cluster_endpoint_private_access = false
#cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
# EKS
cluster_name              = "flask_app"
cluster_version           = "1.16"
public_endpoint           = true
private_endpoint          = false
cluster_enabled_log_types = []

# EKS Workers
instance_type             = "t2.medium"
encrypted_volumes         = true
log_retention             = 3
asg_min                   = 3
asg_desired               = 3
asg_max                   = 6
