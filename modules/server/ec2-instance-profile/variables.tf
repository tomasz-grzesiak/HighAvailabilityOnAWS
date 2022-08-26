variable "name_prefix" {
  type        = string
  description = "Prefix for resource names within module"
}

variable "artifact_bucket_arns" {
  type        = list(string)
  description = "ARNs of the bucket for pipeline artifacts"
}
