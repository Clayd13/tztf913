module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "web-apache"

  ami                    = var.ami_image
  instance_type          = var.instance_type
  key_name               = module.key_pair.key_pair_key_name
  monitoring             = false
  vpc_security_group_ids = [module.security-group_http-80.security_group_id, module.ssh_security_group.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  iam_instance_profile = var.aws_iam_instance_profile

  user_data = file("script/json-to-html.sh")


  tags = merge(
    var.default_tags,
    {
      Your_First_Name = var.your_first_name
      Your_Last_Name  = var.your_last_name
      AWS_Account_ID  = data.aws_caller_identity.current.account_id
      OS_type         = "Amazon Linux 2"
      Instance_type   = var.instance_type
      Region          = var.region_name
    }
  )
}
