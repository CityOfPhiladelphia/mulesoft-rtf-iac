resource "aws_iam_policy" "kms" {
  name        = "${var.app_name}-${var.env_name}-kms"
  description = "Enables use of common KMS key"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyPair*",
        ]
        Effect   = "Allow"
        Resource = data.aws_kms_alias.ssm.arn
      }
    ]
  })
}

resource "aws_iam_policy" "ssm" {
  name        = "${var.app_name}-${var.env_name}-ssm"
  description = "Get SSM Parameters"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Role for ESO to retrieve parameters from ParameterStore
resource "aws_iam_role" "external_secrets" {
  name = "${var.app_name}-${var.env_name}-external-secrets-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowClusterToAssume"
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.main.arn
        }
        Condition = {
          StringEquals = {
            "${replace(data.aws_iam_openid_connect_provider.main.url, "https://", "")}:sub" = "system:serviceaccount:external-secrets:external-secrets-sa"
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachments_exclusive" "external_secrets" {
  role_name = aws_iam_role.external_secrets.name
  policy_arns = [
    aws_iam_policy.ssm.arn,
    aws_iam_policy.kms.arn
  ]
}

module "aws_load_balancer_controller_policy" {
  source      = "git::https://github.com/CityOfPhiladelphia/citygeo-terraform-eks-helpers.git//aws-load-balancer-controller-policy?ref=502744b80a1661607121a80c3561f879555d6c30"
  policy_name = "${var.app_name}-${var.env_name}-eks-alb-controller"
}

resource "aws_iam_role" "eks_alb_controller" {
  name = "${var.app_name}-${var.env_name}-eks-alb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowClusterToAssume"
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.main.arn
        }
        Condition = {
          StringEquals = {
            "${replace(data.aws_iam_openid_connect_provider.main.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachments_exclusive" "eks_alb_controller" {
  role_name = aws_iam_role.eks_alb_controller.name
  policy_arns = [
    aws_iam_policy.kms.arn,
    module.aws_load_balancer_controller_policy.arn
  ]
}

resource "aws_iam_policy" "cert_manager" {
  name        = "${var.app_name}-${var.env_name}-cert-manager-acme-dns01-route53"
  description = "For cert manager IRSA"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/*",
      "Condition": {
        "ForAllValues:StringEquals": {
          "route53:ChangeResourceRecordSetsRecordTypes": ["TXT"]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
  ]
}
EOT

}

resource "aws_iam_role" "cert_manager" {
  name = "${var.app_name}-${var.env_name}-cert-manager-acme-dns01-route53"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowClusterToAssume"
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.main.arn
        }
        Condition = {
          StringEquals = {
            "${replace(data.aws_iam_openid_connect_provider.main.url, "https://", "")}:sub" = "system:serviceaccount:cert-manager:cert-manager-acme-dns01-route53"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachments_exclusive" "cert_manager" {
  role_name = aws_iam_role.cert_manager.name
  policy_arns = [
    aws_iam_policy.cert_manager.arn
  ]
}
