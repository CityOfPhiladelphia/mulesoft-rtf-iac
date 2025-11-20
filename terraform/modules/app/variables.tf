variable "env_name" {
  type = string
}

variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "eks_subnet_ids" {
  type = list(string)
}

variable "eks_admins_iam_arns" {
  type = list(string)
}


