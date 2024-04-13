# resource "local_file" "pet" {
#     filename = var.filename
#     content = var.content
# }

# resource "random_pet" "my-pet" {
#     prefix = var.prefix
#     separator = var.separator
#     length = var.length
# }

# //////////List/////////////


resource "local_file" "pet" {
    filename = each.value
    for_each = var.filename
    # content = var.content
    content  = ""
}