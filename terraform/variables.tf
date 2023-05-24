variable "environment" {
  default = "dev"
}

variable "primary_location" {
  default = "uksouth"
}

variable "locations" {
  default = ["uksouth", "ukwest"]
}

variable "subscription_id" {}

variable "tags" {
  default = {}
}
