############################################# TERRAFORM #############################################
variable "region" {
  type    = string
  default = "us-east-1"
  validation {
    condition     = contains(["us-east-1"], var.region)
    error_message = "The current support value is us-east-1."
  }
}

variable "profile" {
  type    = string
  default = "tf-acn-treinamento"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.100.0.0/16"
}

variable "counter" {
  type    = number
  default = 2
}

variable "environment" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["network", "sec", "shared", "dev", "pre", "pro"], var.environment)
    error_message = "The current support values are network, sec, shared, dev, pre or pro."
  }
}

variable "prefix" {
  type    = string
  default = "tf"

  validation {
    condition     = contains(["tf"], var.prefix)
    error_message = "The current support values is tf."
  }
}

variable "number_of_sequence" {
  type    = number
  default = 1
}

variable "cost_tags" {
  type = map(any)
  default = {
    "bussiness-unit" = "ACN"
    "department"     = "IC"
    "company"        = "Accenture"
    "purpose"        = "Terraform Workshop"
  }
}

variable "amis" {
  type    = map(string)
  default = null
}

variable "instance_type" {
  type = map(string)
  default = {
    "us-east-1" = "t3.medium"
    "us-east-2" = "m5.large"
    "sa-east-1" = "m5.large"
  }
}

variable "operating_system" {
  type    = string
  default = "amazon-linux"
}

variable "allowed_ports" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = null
}

variable "lb_allowed_ports" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = null
}

variable "root_volume_type" {
  type    = string
  default = null
}

variable "root_volume_size" {
  type    = number
  default = 8
}

variable "root_iops" {
  type    = number
  default = null
}
