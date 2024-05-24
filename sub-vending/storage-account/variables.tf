variable "subscription_name" {
  type        = string
  description = "The name of the subscription"
}

variable "env" {
  type = string
  description = "Subscription for the environments: non-prod and prod"
  validation {
    condition = var.env == "non-prod" || var.env == "prod"
    error_message = "The env has to be 'prod' or 'non-prod'"
  }
}

