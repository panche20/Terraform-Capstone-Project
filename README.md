# Terraform AWS Infrastructure for URL Shortener

This repository contains Terraform configurations to deploy a scalable URL shortener application on AWS using ECS, ALB, and Auto Scaling Groups.

## Architecture

- **VPC**: Custom VPC with public and private subnets
- **Security Groups**: ALB and app security groups
- **Load Balancer**: Application Load Balancer with health checks
- **Compute**: Auto Scaling Group with EC2 instances running Docker containers
- **Monitoring**: CloudWatch metrics and alarms for auto-scaling

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform v1.5.0+
- GitHub CLI (optional, for authentication)
- Docker (for local testing)

## Quick Start

### 1. Clone and Setup

```bash
git clone https://github.com/panche20/Terraform-Capstone-Project.git
cd Terraform-Capstone-Project
```

### 2. Configure Variables

Edit `terraform.tfvars` to customize:
- AWS region
- Project name
- Environment
- Instance types
- Docker image
- Scaling parameters

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Validate Configuration

```bash
terraform validate
```

### 5. Format Code

```bash
terraform fmt -recursive
```

### 6. Plan Deployment

Review the plan carefully:

```bash
terraform plan -out=tfplan
```

Read the plan details:

```bash
terraform show tfplan | head -100
```

Count resources being created:

```bash
terraform show tfplan | grep "# aws_" | wc -l
```

### 7. Apply Infrastructure

```bash
terraform apply tfplan
```

### 8. Get Outputs

```bash
terraform output
```

Get the app URL:

```bash
APP_URL=$(terraform output -raw app_url)
echo "App URL: $APP_URL"
```

## Testing and Validation

### Wait for Bootstrap

```bash
echo "Waiting for instances to boot..."
sleep 120
```

### Test Health Endpoint

```bash
curl $APP_URL/health
```

### Check Auto Scaling Group

```bash
ASG_NAME=$(terraform output -raw asg_name)
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --query 'AutoScalingGroups[0].Instances[*].{ID:InstanceId,State:LifecycleState,Health:HealthStatus}' \
  --output table
```

### Check Target Group Health

```bash
TG_ARN=$(terraform state show module.loadbalancer.aws_lb_target_group.app \
  | grep "arn:" | head -1 | awk '{print $3}' | tr -d '"')
aws elbv2 describe-target-health \
  --target-group-arn $TG_ARN \
  --query 'TargetHealthDescriptions[*].{ID:Target.Id,Port:Target.Port,Health:TargetHealth.State}' \
  --output table
```

## Scaling Operations

### Check Current Capacity

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --query 'AutoScalingGroups[0].DesiredCapacity'
```

### Manual Scale Up

```bash
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name $ASG_NAME \
  --desired-capacity 2
```

### Monitor Registration

```bash
watch aws elbv2 describe-target-health \
  --target-group-arn $TG_ARN \
  --query 'TargetHealthDescriptions[*].{ID:Target.Id,Health:TargetHealth.State}' \
  --output table
```

### Test Load Balancing

```bash
for i in $(seq 1 6); do
  curl -s $APP_URL/health
  echo ""
done
```

### Scale Back Down

```bash
sed -i 's/desired_instances = 1/desired_instances = 1/' terraform.tfvars
terraform apply -auto-approve
```

## Instance Management

### Connect via SSM

```bash
INSTANCE_ID=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --query 'AutoScalingGroups[0].Instances[0].InstanceId' \
  --output text)

aws ssm start-session --target $INSTANCE_ID
```

Inside the instance:
```bash
docker ps
docker logs url-shortener
curl localhost:8000/health
exit
```

## Instance Updates

### Update Instance Type

```bash
sed -i 's/instance_type.*=.*/instance_type = "t3.micro"/' terraform.tfvars
terraform apply -auto-approve
```

### Monitor Rolling Update

```bash
aws autoscaling describe-instance-refreshes \
  --auto-scaling-group-name $ASG_NAME \
  --query 'InstanceRefreshes[0].{Status:Status,Progress:PercentageComplete}' \
  --output table
```

### Test Availability During Update

```bash
while true; do
  curl -s -o /dev/null -w "HTTP %{http_code}\n" $APP_URL/health
  sleep 2
done
```

## Cost Estimation

Running resources cost approximately:
- EC2 instances: ~$0.0104/hour each (t3.micro)
- ALB: ~$0.008/hour + $0.008/LCU
- Data transfer: varies

**Estimated hourly cost: ~$0.03/hour**  
**Estimated daily cost: ~$0.72/day**

⚠️ **REMEMBER: Run `terraform destroy` when done to avoid costs!**

## Cleanup

### List Resources

```bash
terraform state list
```

### Destroy Infrastructure

```bash
terraform destroy -auto-approve
```

### Verify Cleanup

```bash
terraform state list
# Should be empty

# Double-check in AWS
aws ec2 describe-vpcs \
  --filters "Name=tag:Project,Values=url-shortener" \
  --query 'Vpcs[*].VpcId' \
  --output text
# Should return nothing
```

## Troubleshooting

- If `terraform init` fails with module path errors, ensure you're running from the `modules/` directory
- For authentication issues, use `gh auth login` and `gh auth setup-git`
- Large files in `.terraform/` are ignored; run `terraform init` to re-download providers

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test
4. Submit a pull request