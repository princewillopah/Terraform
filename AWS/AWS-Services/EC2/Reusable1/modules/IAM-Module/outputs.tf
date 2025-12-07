output "instance_profiles_output" {
  value = {
    for k, v in aws_iam_instance_profile.this :
    k => v.name
  }
}
