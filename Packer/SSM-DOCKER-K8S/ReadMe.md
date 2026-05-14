

This AMI comes with the following installations:
  - docker.io 
  - postgresql-client 
  - unzip 
  - curl 
  - git 
  - ca-certificates

#### Build the AMI
```
cd SSM-DOCKER-K8S

packer init .
packer validate ubuntu-golden.pkr.hcl
packer build ubuntu-golden.pkr.hcl
```



















