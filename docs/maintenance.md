# Maintenance

## App Updates

See mulesoft-rtf-gitops project

## OS Updates

Mulesoft RTF is not built well and therefore you cannot trust AWS's builtin "Update now" button. It will not wait for the pods to fully launch on the new servers before deleting the old ones. This is because Mulesoft RTF does not let you configure PodDisruptionBudgets.

1. Create a new Node Group
    1. Name it `ng-eks-rtf-{env}-{a or b}`. `a` or `b` should just be the opposite of the current existing node group.
    1. Node IAM Role -> `EKS-RTF-Role`
    1. Instance types -> `r8a.xlarge` (or find an equivalent if this is unavailable in the future)
    1. Desired, Min, Max size -> 2 (or however big the current one is)
    1. Add tag "Name" = "eks-rtf-{env}-node"
    1. Disk size = 150Gb
    1. Subnets -> Default should work, just make sure they match the current node group
1. Wait for the node group to be fully ready (~5 mins)
1. Repeat this process until the old node group has 1 node left (capacity = 1)
    1. Decrease the old Node Group desired, min, max capacity by 1
    1. Wait about 10 minutes
        1. If you want to be active, you can constantly run `kubectl get pods -A` against the cluster and see that the pods have officially been moved to a new node and are ready. After that you can repeat the steps
1. Delete the old node group entirely

## EKS Addon Update

to-do

## Kubernetes Update

**Crucial:** Before updating Kubernetes version, make sure runtime fabric actually supports it. They seem to be behind. <https://docs.mulesoft.com/release-notes/runtime-fabric/runtime-fabric>

Kubernetes version should only be at most 1 version ahead of the node group, so in order to upgrade it they have to match first. For example, if node group is currently using 1.32 and the cluster Kubernetes version is 1.33, you should not upgrade the Kubernetes version until the node group is updated first.

1. Navigate to the cluster in EKS and click "Upgrade version"
1. After update is complete, consider following the steps of "OS Updates"
