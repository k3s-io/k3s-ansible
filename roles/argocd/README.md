# Argo CD role

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

This role deploys the Argo CD [helm](https://github.com/argoproj/argo-helm/tree/argo-cd-5.38.0/charts/argo-cd)
chart to a cluster.

## Prerequisites for this role

In order to install Argo CD, some configuration is needed. This is two-fold. The
first part is to make sure the needed secrets are in The Vault and the Argo CD Vault
[plugin](https://argocd-vault-plugin.readthedocs.io/en/stable/) can connect to
The Vault in order to insert them in the generated manifest that are deployed
to the different clusters by Argo CD.

So let's start with the connection to The Vault.

### Vault Connection

A [plugin](https://argocd-vault-plugin.readthedocs.io/en/stable/) for Argo CD
is used that the fetching of secrets from The Vault and insert them into the
generated manifests.

#### Setup

If not already done, create a new policy in The Vault for Argo CD that has read
and list access on the path k8s-provisioning. The hcl for this should look like:

See also: https://developer.hashicorp.com/vault/docs/auth/approle#approle-auth-method

### 1. Enable the AppRole auth method:
```bash
curl \
  --header "X-Vault-Token: ${VAULT_TOKEN}" \
  --request POST \
  --data '{"type": "approle"}' \
  ${VAULT_ADDR}/v1/sys/auth/approle | jq
```

### 2. Create an AppRole with desired set of policies:
```bash
curl \
  --header "X-Vault-Token: ${VAULT_TOKEN}" \
  --request POST \
  --data '{"policies": "argocd", "token_type": "batch"}' \
  ${VAULT_ADDR}/v1/auth/approle/role/argocd | jq
```

### 3. Fetch the identifier of the role:
```bash
curl \
  --header "X-Vault-Token: ${VAULT_TOKEN}" \
  ${VAULT_ADDR}/v1/auth/approle/role/argocd/role-id | jq
```

### 4. Create a new secret identifier under the role:
```bash
curl \
  --header "X-Vault-Token: ${VAULT_TOKEN}" \
  --request POST \
  ${VAULT_ADDR}/v1/auth/approle/role/argocd/secret-id | jq
```
### 5. Test approle based login:
```json
{
  "role_id": "887a8d00-99af-89c0-edb1-7aea8a7cd5a0",
  "secret_id": "360c9d9c-ea4c-1da9-4994-24e63c09ad88"
}
```
```bash
curl \
  --request POST \
  --data @payload.json \
  ${VAULT_ADDR}/v1/auth/approle/login | jq
````

```bash
curl \
  --header "X-Vault-Token: ${APPROLE_TOKEN}" \
  ${VAULT_ADDR}/v1/k8s-provisioning/pro/applications/mijn-kia
```

```json
# Read all secrets from k8s-provisioning
path "k8s-provisioning/*"
{
  capabilities = ["read","list"]
}
```

Check if this policy is already added to approles in The Vault (Replace `${VAULT_TOKEN}`
with the k3s_cluster.token used to connect to the Vault):

```bash
curl -H "X-Vault-Token: ${VAULT_TOKEN}" -X GET ${VAULT_ADDR}/v1/auth/approle/role/argocd/role-id | jq
```

If the policy in the role exists, then note down the returned id. If not, add
the pollicy to the approles in The Vault and get the id of the role again:

```bash
cat > /tmp/add_argocd_policy_to_approle.json << EOF
{
  "secret_id_ttl": 0,
  "k3s_cluster.token_ttl":3600,
  "k3s_cluster.token_max_ttl": 14400,
  "k3s_cluster.token_policies": [
    "argocd"
  ],
  "k3s_cluster.token_type": "default"
}
EOF
curl -H "X-Vault-Token: ${VAULT_TOKEN}" -X POST --data @/tmp/add_argocd_policy_to_approle.json ${VAULT_ADDR}/v1/auth/approle/role/argocd | jq
```

The plugin also needs the secret id in order to connect. Get it by executing the
following commands:

```bash
cat > /tmp/generate_secret_id_for_argocd.json << EOF
{
  "metadata":"{\"service\":\"argocd-frambozen\"}"
}
EOF
curl -H "X-Vault-Token: ${VAULT_TOKEN}" -X POST --data @/tmp/generate_secret_id_for_argocd.json ${VAULT_ADDR}/v1/auth/approle/role/argocd/secret-id | jq
```

Note down the secret id so it can be stored in The Vault as shown in the following
section.

#### Secret

Create secrets for Argo CD for the cluster (environment) on which Argo CD is to be
installed. These should be put under the `group_vars/helm/argocd` path of the
cluser on which Argo CD is going to be installed.

| secret                   | description                                                                           |
|--------------------------|---------------------------------------------------------------------------------------|
| `avp_role_id`            | The role id Argo CD should use to connect to the vault                                |
| `avp_secret_id`          | The secret id Argo CD should use to connect to the vault                              |
| `github_known_hosts`     | The known host entry that Argo CD can use to connect to the github server     |
| `github_private_key`     | The certificate that Argo cd can use to connect repositories on the github |
| `default_admin_password` | Default administrator password                                                        |

If Argo CD is setup in order to deploy to other clusters the following secrets are also needed:

| secret | description | 
|---|---|
| `caData` | The cluster CA certificate |
| `certData` | The cluster client certificate |
| `keyData` | The cluster key certificate |

These secrets should be put under `k8s_clusters/{environment}` in which
`{environment}` is replaced with the name of the targeted environment.

## Argo CD configuration

Create an `argocd.yml` file for the cluster (environment) on which Argo CD is to be
installed. This file has been created for dev4 and can be used as an example: `environments/dev4/helm/argocd.yml`.
Some of the values in this file come from The Vault and are setup in the previous
section.

### Repository credentials

Argo CD needs to know how it can connect to the different repositories in github. Luckily, it's not needed
to add every single repository to Argo CD. It is possible to use a template that contains part of the connection
url. Within the k8s-frambozen this (can) corresponds to the different projects in github.
These value's can be set in the `argocd.yml` as a list of elements under the variable `argocd.github.projects`, e.g.:

```yaml
argocd.github.projects:
  - name: k8s-deployements
    url: "{{ git_clone_ssh_url }}/kd"
```

### External kubernetes clusters

Argo CD can deploy to external clusters. These can be defined in the `argocd.yml` in the variable `argocd.cluster.credentials`. 
The format of this section corresponds to the format used by the [Argo CD helm chart](https://github.com/argoproj/argo-helm/blob/4f6f25198e9ebb8085c3c2a561d6750205dcb0bd/charts/argo-cd/values.yaml#L406).

#### Gather config

> This should be automated

Gather `bearerToken` and `caData` from the target cluster default `cd` namespace user:

1. Lookup the k3s_cluster.token used with the service account with. `kubectl describe serviceaccount default -n cd`.
1. Print the k3s_cluster.token with: `kubectl describe secret default-k3s_cluster.token-<TOKEN> -n cd`
and save it as `bearerToken` in Vault `k8s-provisioning/show/k8s_clusters/<TARGETCLUSTER>`.
1. Print the certificate with: `kubectl get -o yaml secret default-k3s_cluster.token-<TOKEN> -n cd`
and save it as `caData` in Vault `k8s-provisioning/show/k8s_clusters/<TARGETCLUSTER>`.

### Environments AppProject

There are several environments to which Argo CD should be able to deploy, e.g. ONT for development, ATO for acceptance
testing or PRO for production. These environments have a name, a namespace or a namespace prefix and a cluster
on which they run. This is defined using the variable `argocd.app_projects` in the `argocd.yml` file. E.g.:

```yaml
argocd.app_projects:
  - name: ont
    namespace: "dev-*" # This is a namespace prefix
    cluster: dev-cluster
  - name: pro
    namespace: "pro"
    cluster: pro-cluster
  - name: tools
    namespace: "*"
    cluster: tools-cluster
```

### Application sets

An Argo CD Application Set is a way of generating deployments (Applications) using a generator and a template.
There are several kind of generators and the git-file generator is used in this setup. With this type of
generator it is possible to provide specific values to the template, for example, for the version of the
container image to be used.
Each environment has one or more specific application sets. They have a name, a type -kustomize or helm-, a
project, a repository describing the deployments, a git_files entry to point to the files describing the
deployment and are targeted towards a cluster. E.g.:

```yaml
argocd_application_sets:
  - name: ont-kustomize
    type: kustomize
    project: ont
    repo_url: "{{ git_clone_ssh_url }}/cdtool/cdtools-argocd-environments.git"
    git_files: "ont/**/service.yaml"
    cluster: dev-cluster
  - name: tools-helm
    type: helm
    project: tools
    repo_url: "{{ git_clone_ssh_url }}/cdtool/cdtools-argocd-environments.git"
    git_files: "tools/**/application.yaml"
    cluster: tools-cluster
```
