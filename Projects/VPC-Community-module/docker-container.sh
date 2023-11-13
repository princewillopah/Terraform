#!/bin/bash
sudo apt update -y && sudo apt install -y docker.io  #update all packages and then install the docker . the -y means yes to all questions during installation for confirming the input
sudo systemctl start docker  # start the docker 
sudo usermod -aG docker ubuntu # we need to execute docker command without using "sudo" command. by this we need to add the user(ubuntu) to the docker group(docker)
docker run -p 8080:80 nginx # run nginx containerbased on the nginx image(nginx) add map the port 8080(on host system) to port 80(on docker nginx container) so that when requests/trafic comes to port 8080 on the host maching browser, they are forward to the docker container on port 80. port 80 is the default port nginx listen to