

# // To Generate Private Key
# resource "tls_private_key" "my_ssh_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# # define a key name
# variable "key_name" {
#   description = "Name of the SSH key pair"
#   default = "disposible-sshkey"
# }

# // Define the home directory variable
# variable "home_directory" {
#   description = "The user's home directory"
#   default = "~/.ssh"
# }

# // generate public key from my_ssh_key for the vm
# resource "aws_key_pair" "key_pair" {
#   key_name   = var.key_name
#   public_key = tls_private_key.my_ssh_key.public_key_openssh
#    tags = {
#     Name = "public-key_pair"
#   }
# }
# // Save private key PEM file locally
# resource "local_file" "ssh_private_key_pem" {
#   content         = tls_private_key.my_ssh_key.private_key_pem
#    filename = "${pathexpand(var.home_directory)}/${var.key_name}"
#     provisioner "local-exec" { # The local-exec provisioner is also updated to use the same path when running the chmod command.
#     # command = "chmod 400 ${var.key_name}" 
#      command = "chmod 400 ${pathexpand(var.home_directory)}/${var.key_name}"
#   }
# #   file_permission = "0600"
# }

#Create a VPC network: When creating a new Google Cloud Project, a default VPC network is created. This network works fine, but since it’s recommended to create separate networks for isolation, let’s do that:


resource "google_compute_network" "vpc_network" {
  name = "my-network"
}

# Create a compute instance: Now let’s create our VM and associated resources

resource "google_compute_address" "static_ip" {
  name = "debian-vm"
}

resource "google_compute_firewall" "allow_ssh" {
  name          = "allow-ssh"
  network       = google_compute_network.vpc_network.name
  target_tags   = ["allow-ssh"] // this targets our tagged VM
  source_ranges = ["0.0.0.0/0"]

 allow {
    protocol = "tcp"
    ports    = ["22", "8081", "3000", "5000", "8080"]
  }

}

data "google_client_openid_userinfo" "me" {}


resource "google_compute_instance" "server1" {
  name         = "server-1"
  machine_type = "e2-standard-2"
  zone         = "europe-west1-b"
  tags         = ["allow-ssh"] // this receives the firewall rule

  # metadata = {
  #   ssh-keys = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.my_ssh_key.public_key_openssh}"
  # }

 metadata = {
    ssh-keys = "princewillopah:${file("~/.ssh/id_rsa.pub")}"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }
}

# Execute Ansible provisioning after creating the instance
resource "null_resource" "ansible_provisioner_to_configure_server1" {
  triggers = {
    instance_id = google_compute_instance.server1.id
  }

  provisioner "local-exec" {
    working_dir = "/home/princewillopah/DevOps-World/Ansible/PROJECTS/TF-and-Ansible"
    command = "ansible-playbook -i ${google_compute_instance.server1.network_interface.0.access_config.0.nat_ip}, --private-key ${var.ssh-private-key} --user princewillopah playbooks/example.yml"

  }
}

# ================================= ================================= =================================
# 
# ================================= ================================= =================================




# resource "google_compute_firewall" "allow-ssh-http-ports" {
#   name    = "allow-ssh-http-ports"
#   network = "default"  # Use the default VPC

#   allow {
#     protocol = "tcp"
#     ports    = ["22", "8081", "3000", "5000", "8080"]
#   }

#   source_ranges = ["0.0.0.0/0"]
# }

# resource "tls_private_key" "my_ssh_key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }

# resource "google_compute_instance" "my_instance" {
#   name         = "my-instance"
#   machine_type = "e2-micro"
#   zone         = "${avail_zone}-zone"

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#     }
#   }

#   network_interface {
#     network = "default"  # Use the default VPC
#   }

#   metadata = {
#     ssh-keys = "princewillopah:${tls_private_key.my_ssh_key.public_key}"
#   }

# #   service_account {
# #     scopes = ["userinfo-email", "compute-ro", "storage-ro"]
# #   }

#   tags = ["allow-ssh-http-ports"]

#   # # define a key name
# variable "key_name" {
#   description = "Name of the SSH key pair"
#   default = "disposible-sshkey"
# }

# // Define the home directory variable
# variable "home_directory" {
#   description = "The user's home directory"
#   default = "~/.ssh"
# }

# // generate public key from my_ssh_key for the vm
# resource "aws_key_pair" "key_pair" {
#   key_name   = var.key_name
#   public_key = tls_private_key.my_ssh_key.public_key_openssh
#    tags = {
#     Name = "public-key_pair"
#   }
# }
# // Save private key PEM file locally
# resource "local_file" "ssh_private_key_pem" {
#   content         = tls_private_key.my_ssh_key.private_key_pem
#    filename = "${pathexpand(var.home_directory)}/${var.key_name}"
#     provisioner "local-exec" { # The local-exec provisioner is also updated to use the same path when running the chmod command.
#     # command = "chmod 400 ${var.key_name}" 
#      command = "chmod 400 ${pathexpand(var.home_directory)}/${var.key_name}"
#   }
# #   file_permission = "0600"
# }

#   provisioner "file" {
#     source      = tls_private_key.ssh_key.private_key_pem
#     destination = "/tmp/id_rsa"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod 600 /tmp/id_rsa",
#       "sudo useradd -m -s /bin/bash your-username",
#       "sudo mkdir /home/your-username/.ssh",
#       "sudo mv /tmp/id_rsa /home/your-username/.ssh/id_rsa",
#       "sudo chown -R your-username:your-username /home/your-username/.ssh",
#       "sudo chmod 600 /home/your-username/.ssh/id_rsa",
#     ]
#   }
# }



# ================================= ================================= =================================
# 
# ================================= ================================= =================================


# resource "google_service_account" "default" {
#   account_id   = "my-custom-sa"
#   display_name = "Custom SA for VM Instance"
# }

# resource "google_compute_instance" "default" {
#   name         = "my-instance"
#   machine_type = "n2-standard-2"
#   zone         = "us-central1-a"

#   tags = ["foo", "bar"]

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#       labels = {
#         my_label = "value"
#       }
#     }
#   }

#   // Local SSD disk
#   scratch_disk {
#     interface = "NVME"
#   }

#   network_interface {
#     network = "default"

#     access_config {
#       // Ephemeral public IP
#     }
#   }

#   metadata = {
#     foo = "bar"
#   }

#   metadata_startup_script = "echo hi > /test.txt"

#   service_account {
#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     email  = google_service_account.default.email
#     scopes = ["cloud-platform"]
#   }
# }









# ================================= ================================= =================================
# 
# ================================= ================================= =================================










# resource "google_compute_firewall" "allow-ssh-http-ports" {
#   name    = "allow-ssh-http-ports"
#   network = "default"  # Use the default VPC

#   allow {
#     protocol = "tcp"
#     ports    = ["22", "8081", "3000", "5000", "8080"]
#   }

#   source_ranges = ["0.0.0.0/0"]
# }

# resource "tls_private_key" "my_ssh_key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }

# resource "google_compute_instance" "my_instance" {
#   name         = "my-instance"
#   machine_type = "e2-micro"
#   zone         = "us-central1-a"

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#     }
#   }

#   network_interface {
#     network = "default"  # Use the default VPC
#   }

#   metadata = {
#     ssh-keys = "princewillopah:${tls_private_key.my_ssh_key.public_key}"
#   }

#   tags = ["allow-ssh-http-ports"]
# }

# resource "local_file" "ssh_private_key_pem" {
#   content  = tls_private_key.my_ssh_key.private_key_pem
#   filename = "~/.ssh/disposable.pem"
# }

# output "public_ip" {
#   value = google_compute_instance.my_instance.network_interface.0.access_config.0.assigned_nat_ip
# }







# ================================= ================================= =================================
# working 80%
# ================================= ================================= =================================










# resource "google_compute_network" "vpc_network" {
#   name                    = "vpc-network"
#   auto_create_subnetworks = "true"
# }

# resource "google_compute_firewall" "allow_ssh" {
#   name    = "allow-ssh"
#   network = google_compute_network.vpc_network.self_link

#   allow {
#     protocol = "tcp"
#     ports    = ["22", "8081", "3000", "5000", "8080"]
#   }

#   source_ranges = ["0.0.0.0/0"]
# }

# resource "google_compute_instance" "vm_instance" {
#   name         = "vm-instance"
#   machine_type = "n1-standard-1"
#   zone         = "europe-west1-b"

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-10"
#     }
#   }

#   metadata_startup_script = "sudo apt-get update && sudo apt-get install -y apache2 && sudo service apache2 start"

#   metadata = {
#     ssh-keys = "princewillopah:${file("~/.ssh/id_rsa.pub")}"
#   }

#   network_interface {
#     network = google_compute_network.vpc_network.self_link
#   }
# }

# resource "google_compute_address" "ip_address" {
#   name = "ip-address"
# }

