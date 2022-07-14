############################################# TERRAFORM #############################################
// ACCOUNT PROVIDER
region  = "us-east-1"
profile = "tf-acn-treinamento"

// NETWORKING
vpc_cidr_block = "10.10.0.0/16"

// NAMING
prefix             = "tf"
environment        = "dev"
number_of_sequence = 1

// TAGGING
cost_tags = {
  "bussiness-unit" = "ACN"
  "department"     = "IC"
  "company"        = "Accenture"
  "purpose"        = "Terraform Workshop"
}

// EC2
root_volume_type = "gp2"
root_volume_size = 8
operating_system = "amazon-linux"
amis = {
  "amazon-linux" = "ami-0022f774911c1d690"
  "centos"       = "ami-02358d9f5245918a3"
  "ubuntu"       = "ami-005de95e8ff495156"
  "redhat"       = "ami-0f095f89ae15be883"
}
instance_type = {
  "us-east-1" = "t3.medium"
  "us-east-2" = "m5.large"
  "sa-east-1" = "m5.large"
}

// SECURITY GROUP
allowed_ports = [{
  description = "Allow SSH"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ] }
]

lb_allowed_ports = [{
  description = "Allow HTTPS"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  },
  {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
  ] }
]
