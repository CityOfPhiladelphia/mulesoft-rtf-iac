# mulesoft-rtf-iac

This project is the AWS infrastructure counterpart to [mulesoft-rtf-gitops](https://github.com/CityOfPhiladelphia/mulesoft-rtf-gitops).

Because Mulesoft RTF was deployed using `eksctl`, this project is initially not handling creation or management
of the EKS cluster itself, instead just focusing on surrounding IAM policies and roles necessary for
apps on the cluster.

In the future, the EKS cluster should be deleted and recreated through this Terraform project for consistency reasons.
