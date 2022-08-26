variable "name_prefix" {
  type        = string
  description = "Prefix for resource names within module"
}

variable "app_port" {
  type        = number
  description = "Application port, also for ALB to listen to and forward to"
}


variable "artifact_bucket_arns" {
  type        = list(string)
  description = "ARNs of the bucket for pipeline artifacts"
}

