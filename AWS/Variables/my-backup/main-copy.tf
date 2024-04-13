resource "local_file" "pet" {
    filename = "/home/princewillopah/DevOps-World/Terraform/Variables/my_work_folder/pets.txt"
    content = "We LOVE Pets!"
}

resource "random_pet" "my-pet" {
    prefix = "Mrs"
    separator = "."
    length = "1"
}