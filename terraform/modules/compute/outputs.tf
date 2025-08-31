output "api_gateway_invoke_url" {
  description = "Invoke URL for the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.bkr-rest-api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.bkr-api-stage.stage_name}"

}
