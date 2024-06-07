output "ecs_launch_template_id" {
  description = "The ID of the ECS launch template"
  value       = aws_launch_template.ecs_lt.id
}

output "ecs_autoscaling_group_arn" {
  description = "The ARN of the ECS Auto Scaling group"
  value       = aws_autoscaling_group.ecs_asg.arn
}

output "ecs_autoscaling_group_name" {
  description = "The name of the ECS Auto Scaling group"
  value       = aws_autoscaling_group.ecs_asg.name
}

output "ecs_alb_dns_name" {
  description = "The DNS name of the ECS Application Load Balancer"
  value       = aws_lb.ecs_alb.dns_name
}

output "ecs_alb_arn" {
  description = "The ARN of the ECS Application Load Balancer"
  value       = aws_lb.ecs_alb.arn
}

output "ecs_alb_listener_arn" {
  description = "The ARN of the ECS ALB listener"
  value       = aws_lb_listener.task.arn
}

output "ecs_alb_target_group_arn" {
  description = "The ARN of the ECS ALB target group"
  value       = aws_lb_target_group.ecs_tg.arn
}

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.ecs_cluster.id
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = aws_ecs_task_definition.ecs_task_definition.arn
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.ecs_service.name
}


