variable "main_region" {
  type        = string
  description = "Main region for the resources deployment"
}

variable "main_region_vpc_id" {
  type        = string
  description = "Default VPC ID in the main region"
}

variable "main_region_subnet_ids" {
  type        = list(any)
  description = "Default subnet IDs in the default VPC in the main region"
}

variable "httpd_AMI" {
  type        = string
  description = "Amazon Linux 2 with httpd server"
}
