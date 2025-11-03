# Don't create EKS cluster yet
data "aws_eks_cluster" "main" {
  name = "eks-${var.app_name}-${var.env_name}"
}

resource "aws_eks_access_entry" "terraform" {
  cluster_name  = data.aws_eks_cluster.main.name
  principal_arn = data.aws_caller_identity.current.arn
}

resource "aws_eks_access_policy_association" "terraform" {
  cluster_name  = data.aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_caller_identity.current.arn

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
