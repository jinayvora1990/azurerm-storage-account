variable "management_group_name" {
  description = "Name of associated management group that subscription will be associated with"
  type        = string
}

variable "team_name" {
  type        = string
  description = "The name of the existing management group associated with the new subscription"
}

variable "env" {
  type = string
  description = "Subscription for the environments: non-prod and prod"
  validation {
    condition = var.env == "non-prod" || var.env == "prod"
    error_message = "The env has to be 'prod' or 'non-prod'"
  }
}

