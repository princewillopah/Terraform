# eks_managed_node_groups = {

#   system = {
#     instance_types = ["t3.medium"]
#     min_size       = 2
#     max_size       = 4
#     desired_size   = 2

#     labels = {
#       role = "system"
#     }

#     taints = {
#       system = {
#         key    = "system"
#         value  = "true"
#         effect = "NO_SCHEDULE"
#       }
#     }
#   }

#   application = {
#     instance_types = ["t3.large"]
#     min_size       = 2
#     max_size       = 10
#     desired_size   = 3

#     labels = {
#       role = "application"
#     }
#   }
# }
