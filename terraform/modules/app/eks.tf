# Unfortunately, it is too hard
# to replicate the existing EKS
# cluster that was made with EKSCTL
#
# At some point in the future, we should
# delete the EKS clusters and make them
# with Terraform, but for now we will survive
data "aws_eks_cluster" "main" {
  name = "eks-${var.app_name}-${var.env_name}"
}

# Gives access to an arbitrary list of IAM roles,
# used mainly to allow viewing EKS resources in the AWS
# console
resource "aws_eks_access_entry" "admins" {
  for_each      = toset(var.eks_admins_iam_arns)
  cluster_name  = data.aws_eks_cluster.main.name
  principal_arn = each.value
}

resource "aws_eks_access_policy_association" "admins" {
  for_each      = toset(var.eks_admins_iam_arns)
  cluster_name  = data.aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }
}

# This is only necessary when you need to create an openid connect provider
#data "tls_certificate" "main" {
#  url = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
#}

# Data because its already created
data "aws_iam_openid_connect_provider" "main" {
  url = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# Tags the subnets that the AWS load balancer controller
# can use for the ingress ALB
resource "aws_ec2_tag" "eks_subnets_elb_internal" {
  for_each = toset(var.eks_subnet_ids)

  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

# Tells the AWS load balancer controller that
# these subnets are not solely used by it
resource "aws_ec2_tag" "eks_subnets_elb_cluster" {
  for_each = toset(var.eks_subnet_ids)

  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.app_name}-${var.env_name}"
  value       = "shared"
}
