Steps to complete the work

# Run install-jenkins.tf to create jenkins server
   Required softwares:
    Terraform
    Ansible
    Docker
    AWS CLI

    Required AWS Resources
    Security Group:
        Ports:
            - 8080
            - 80
            - 22
    Role:
        - Give jenkins Server access to EC2 resources (ECR creation)   

# Pull source code to jenkins server             


# create a terraform file as  main.tf for provisioning worker nodes
   AWS Resources:
        Ec2(s):
            - Postgres Ec2 instance
            - React Ec2 instance
            - Node.js Ec2 instance
        Security Groups:
            - Postgres Sec Group (22, 5432 (Sadece node js den trafigi kabul et))
            - React Sec Group (80, 3000, )
            - Node.js Sec Group
        Roles: 
            - Give ec2 full access for ECR access

# create ansible playbooks:
    - install docker
    - pull image from ECR
    -  build container                


# create Jenkinsfile
    - create ECR
    - create infrastructure
    - create docker images
    - push docker images
    - handle failure
