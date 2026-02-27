output "alb_dns" { value = aws_lb.alb.dns_name }
output "cloudfront_dominio" { value = aws_cloudfront_distribution.cdn.domain_name }
output "sns_reservas_arn" { value = aws_sns_topic.reservas.arn }
output "sqs_fifo_url" { value = aws_sqs_queue.fifo.id }