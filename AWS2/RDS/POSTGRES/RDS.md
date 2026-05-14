
<h1 style="color:teal; font-weight: bold; font-size:40px">RDS PRACTICES</h1>




### Enable deletion protection to prevent accidental deletion



Enable deletion protection to prevent accidental deletion:

For dev/staging:
```bash
      deletion_protection = false
      skip_final_snapshot = true
```
<br>
  
For production:

  ```bash
    deletion_protection = true
    skip_final_snapshot = false
    final_snapshot_identifier = "${var.project_name}-${var.environment}-${random_id.snapshot.hex}"

# were there is a random string generator block below
    resource "random_id" "snapshot" {
        byte_length = 4
    }

  ```   
  What this settings do:
| Setting                                    | Effect                                            |
| ------------------------------------------ | ------------------------------------------------- |
| `deletion_protection = true`               | Prevents Terraform or humans from deleting the DB |
| `skip_final_snapshot = false`              | AWS MUST create backup snapshot before deletion   |
| `final_snapshot_identifier = ...random...` | Snapshot name is unique every time                |





<!-- 
<p style="font-size:16px; color:#586069;">
  A short description of your project. <strong>Bold text</strong> and <em>italics</em> work too.
</p>

<div style="background:#f6f8fa; padding:16px; border-radius:6px; border:1px solid #e1e4e8;">
  <h3 style="margin-top:0;">Key Features</h3>
  <ul style="margin:0;">
    <li>Fast</li>
    <li>Secure</li>
    <li>Easy to use</li>
  </ul>
</div> -->