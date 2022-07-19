# Task-1 Challenge: 
- Install a postgresql database with Helm Chart
- Take care all needed the persistent disk. 
- write down your chart files and bash commands.

Cloud platform: **Amazon Web Services (AWS)**.
Region: **ap-southeast-1**.
Enviroment: **Cloud9 IDE (EC2-t2.medium, Ubuntu Server 18.04 LTS)**.

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
4. Confirm the IAM role is functional in  Cloud9 enviroment by running

`aws sts get-caller-identity`

Output:

```
{
    "UserId": "[A-Z0-9]:i-0a4e0c17587dc318d",
    "Account": "</account-id>",
    "Arn": "arn:aws:sts::</account-id>:assumed-role/asianscloud-role/i-0a4e0c17587dc318d"
}
```

5. Expand workspace block volume using the resize.sh:

```
export AWS_REGION=ap-southeast-1
chmod +x resize.sh
./resize.sh 30
```

### Setup Kubernetes cluster using Minikube
1. Install Kubernetes

```
chmod 700 k8s.sh
./k8s.sh
```

2. Install Docker Engine

```
chmod 700 docker.sh
./docker.sh
```

3. Create SSH Key for minikube (press Enter all through)

`ssh-keygen -f .ssh/id_rsa`

4. Install a dependency for minikube

`sudo apt install conntrack -y`

5. Install minikube

```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
```

<!--6. Start minikube-->

<!--`sudo minikube start --vm-driver=none`-->
<!--N/B: We’re using -— vm-driver=none because minikube is running on a virtual machine. This approach defaults minikube to use docker as its driver.-->

<!--7. Confirm the minikube cluster is ready by running this command:-->

<!--`sudo minikube status`-->
<!--Your output should look like this, meaning that the cluster has been set up successfully.-->

<!--```-->
<!--minikube-->
<!--type: Control Plane-->
<!--host: Running-->
<!--kubelet: Running-->
<!--apiserver: Running-->
<!--kubeconfig: Configured-->
<!--```-->