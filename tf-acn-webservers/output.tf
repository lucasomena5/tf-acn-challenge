output "alb_dns_name" {
  description = "The DNS Name of Load Balancer"
  value       = "http://${aws_lb.alb.dns_name}/index.html"
}