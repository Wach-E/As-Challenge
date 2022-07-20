# Task-1 Challenge: 
- Install a postgresql database with Helm Chart
- Take care of all the needed persistent disk. 
- Document your chart files and bash commands.

Cloud platform: **Amazon Web Services (AWS)**. <br>
Region: **ap-southeast-1**. <br>
Enviroment: **Cloud9 IDE (EC2-t2.medium, Ubuntu Server 18.04 LTS)**. <br>

## Procedures
### Setup development workspace
1. Create an IAM role for EC2 service with AdministratorAdmin priviledges for Cloud9 environment:
    - Navigate to IAM / Role / Create role.
    - Select Trust Etity as EC2, then choose **AdministratorAdmin** policy and give the role a name **asianscloud**.
    - Create role.
N/B: For teams and production use case, this is not recommended but since this is a solo project, it could be used.
2. Attach the IAM role to Cloud9 EC2 instance: 
    - In the Cloud9 environment, select the User icon with **R**
    - Select the instance, then choose Actions / Security / Modify IAM Role.
    - Choose asianscloud-role from the IAM Role drop down, and select Save.
3. Install [awscli2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) in the Cloud9 environment
4. Confirm the IAM role is functional in  Cloud9 enviroment by running:
    `aws sts get-caller-identity`

Output:

  ```
  {
      "UserId": "[A-Z0-9]:i-0a4e0c17587dc318d",
      "Account": "</account-id>",
      "Arn": "arn:aws:sts::</account-id>:assumed-role/asianscloud-role/i-0a4e0c17587dc318d"
  }
```

5. Expand workspace block volume using the **resize.sh**:

```
export AWS_REGION=ap-southeast-1
chmod +x resize.sh
./resize.sh 30
```

6. Update ubuntu system: <br>

`sudo apt update`


### Setup Kubernetes cluster using Minikube
1. Install Kubernetes using **k8s.sh**:

```
chmod 700 k8s.sh
./k8s.sh
```

2. Install Docker Engine using **docker.sh**:

```
chmod 700 docker.sh
./docker.sh
```

3. Create SSH Key for minikube (press Enter all through): `ssh-keygen -f .ssh/id_rsa`

4. Install conntrack for minikube: `sudo apt install conntrack -y`
   - Connection tracking (“conntrack”) is used to keep track of all logical network connections or flows. It is essential for performant complex networking of Kubernetes where nodes need to track connection information between thousands of pods and services

5. Install [cri-dockerd using this guide](https://www.mirantis.com/blog/how-to-install-cri-dockerd-and-migrate-nodes-from-dockershim)

6. Install [crictl (CLI and validation tools for kubelet container runtime interface (CRI) )](https://github.com/kubernetes-sigs/cri-tools#install-crictl)

7. Install minikube:

```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
```

8. Start minikube: `sudo minikube start --vm-driver=none` <br>
N/B: We’re using -— vm-driver=none because minikube is running on a virtual machine. This approach defaults minikube to use docker as its driver.

9. Confirm the minikube cluster is ready by running this command: `sudo minikube status` <br>

Your output should look like this, meaning that the cluster has been set up successfully.

```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

10. Make ubuntu user the owner of the cluster:

```
sudo chown -R $USER $HOME/.minikube
sudo chmod -R u+wrx $HOME/.minikube
```

11. Make ubuntu user the owner of kubernetes:

```
sudo chown $USER $HOME/.kube/
sudo chmod 600 $HOME/.kube/config
```

12. Update the kube config with the current loaction of minikube: `sudo sed -i "s|/root|$HOME|g" $HOME/.kube/config`

13. Confirm the changes worked: `kubectl get svc`

Output:
```
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   39m
```



### Create Helm Chart to deploy postgresql database

1. Install Helm 3 using script:
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version
```

2. Create helm chart postgresql-db: `helm create postgresql-db`

3. Navigate to `postgresql-db` and modify **Chart.yaml**.

4. 