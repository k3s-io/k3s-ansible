ansible-playbook site.yml -i inventory/sample/hosts.ini
ansible-playbook firewall.yml -i inventory/sample/hosts.ini 
scp root@<master-ip>:~/.kube/config ./config
export KUBECONFIG=./config
kubectl get ns
git clone https://github.com/myenergymanager/platform-ansible.git
cd platform-ansible
sh ./nginx-controller/deploy-nginx.sh
sh ./sealed-secret/deploy-sealed-secret.sh
cd ..
rm -rf platform-ansible