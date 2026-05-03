output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "ALB DNS name — use this to access your app"
}

output "alb_arn" {
  value = aws_lb.main.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "alb_zone_id" {
  value = aws_lb.main.zone_id
}
