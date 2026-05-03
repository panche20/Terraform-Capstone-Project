output "asg_name" {
  value = aws_autoscaling_group.app.name
}

output "asg_arn" {
  value = aws_autoscaling_group.app.arn
}

output "launch_template_id" {
  value = aws_launch_template.app.id
}

output "ami_id" {
  value = data.aws_ami.ubuntu.id
}

output "iam_role_arn" {
  value = aws_iam_role.app.arn
}
