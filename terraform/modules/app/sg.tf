resource "aws_security_group" "alb" {
  name        = "${var.app_name}-${var.env_name}-alb"
  description = "SG for ALB"
  vpc_id      = var.vpc_id

  tags = merge(local.default_tags, {
    Name                                                    = "${var.app_name}-${var.env_name}-alb"
    "kubernetes.io/cluster/${var.app_name}-${var.env_name}" = "owned"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_from_all" {
  security_group_id = aws_security_group.alb.id

  description = "HTTP access from city"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https_from_all" {
  security_group_id = aws_security_group.alb.id

  description = "HTTP access from city"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}
