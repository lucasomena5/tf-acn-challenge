############################################# TERRAFORM #############################################
resource "aws_instance" "ec2_linux" {
  count = var.counter

  ami                  = lookup(var.amis, var.operating_system, "amazon-linux")
  instance_type        = lookup(var.instance_type, var.region, "t3.micro")
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  key_name             = aws_key_pair.key_pair.key_name

  subnet_id              = aws_subnet.private_subnet_a.id
  vpc_security_group_ids = [aws_security_group.sg_app.id]
  private_ip             = cidrhost(aws_subnet.private_subnet_a.cidr_block, sum([count.index, 11]))

  associate_public_ip_address = false
  monitoring                  = false
  disable_api_termination     = var.environment == "dev" ? false : true

  root_block_device {
    volume_type           = var.root_volume_type
    iops                  = var.root_volume_type == "io1" ? var.root_iops : 0
    volume_size           = var.root_volume_size == "" ? 8 : var.root_volume_size
    delete_on_termination = true
    encrypted             = true
  }

  // Check user_data logs: /var/log/cloud-init-output.log
  user_data = count.index == 0 ? "${file("./startup-scripts/script-blue.sh")}" : "${file("./startup-scripts/script-green.sh")}"

  tags = {
    "Name"             = join("-", [lower(var.prefix), "ec2", lower(var.environment), format("%02d", sum([count.index, 1]))])
    "Environment"      = var.environment
    "Operating System" = var.operating_system
  }
  volume_tags = {
    "Name"             = join("-", [lower(var.prefix), "ec2", lower(var.environment), "root-volume"])
    "Operating System" = var.operating_system
  }

  depends_on = [
    aws_vpc.vpc,
    aws_subnet.public_subnet_a,
    aws_subnet.public_subnet_b,
    aws_subnet.private_subnet_a,
    aws_subnet.private_subnet_b,
    aws_nat_gateway.ngw,
    aws_internet_gateway.igw,
    aws_security_group.sg_app,
    aws_security_group.sg_lb
  ]
}
