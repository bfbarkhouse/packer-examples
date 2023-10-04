output "load_balancer_ip" {
  value = aws_lb.lb.dns_name
}