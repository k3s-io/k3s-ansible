# Actions to delete Argocd in DEV

> For DEV purposes ONLY!!

```bash
kubectl patch appprojects -n argocd <FILL IN APPPROJECT NAMES> -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch application -n argocd <FILL IN APPLICATION NAMES> -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch applicationset -n argocd <FILL IN APPLICATIONSET NAMES> -p '{"metadata":{"finalizers":null}}' --type=merge

kubectl delete ns argocd 

kubectl delete clusterrolebinding argocd-application-controller argocd-manager-role-binding argocd-repo-server argocd-server argocd-server-cluster-apps
kubectl delete clusterrole argocd-application-controller argocd-manager-role argocd-repo-server argocd-server argocd-server-cluster-apps

kubectl delete crd applications.argoproj.io applicationsets.argoproj.io appprojects.argoproj.io
```
