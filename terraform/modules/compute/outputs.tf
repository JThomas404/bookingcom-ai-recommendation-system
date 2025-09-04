output "api_gateway_invoke_url" {
  description = "Invoke URL for the API Gateway"
  value       = aws_api_gateway_stage.bkr-api-stage.invoke_url
}
