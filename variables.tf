##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

# Establish this is a HUB or spoke configuration
variable "is_hub" {
  description = <<-EOD
  is_hub: false # (Optional) Whether this is a hub or spoke configuration. Default: false.
  EOD
  type        = bool
  default     = false
}

variable "spoke_def" {
  description = <<-EOD
  spoke_def: "001" # (Optional) Spoke definition. Default: "001".
  EOD
  type        = string
  default     = "001"
}

variable "org" {
  description = <<-EOD
  org:
    organization_name: "my-org" # (Required) Organization name.
    organization_unit: "my-unit" # (Required) Organization unit.
    environment_type: "prod" # (Required) Environment type.
    environment_name: "production" # (Required) Environment name.
  EOD
  type = object({
    organization_name = string
    organization_unit = string
    environment_type  = string
    environment_name  = string
  })
}

variable "extra_tags" {
  description = <<-EOD
  extra_tags: {} # (Optional) Extra tags to apply to all resources. Default: {}.
  EOD
  type        = map(string)
  default     = {}
}
