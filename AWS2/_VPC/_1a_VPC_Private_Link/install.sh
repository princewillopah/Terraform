#!/bin/bash

sleep 120 # wait for 2 mins for the EC2 instance to get from initializing state to running state



# Update package lists
sudo apt-get update

# Install Apache
sudo apt-get install apache2 -y

# Enable and start Apache service
sudo systemctl enable apache2
sudo systemctl start apache2
# sudo systemctl status apache2


# Get server details
ip_address=$(hostname -I | awk '{print $1}')
hostname=$(hostname)

# Create a beautiful HTML page with server details
sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Information</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            color: #333;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .container {
            text-align: center;
            background: #fff;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
        }
        h1 {
            margin: 0 0 20px;
        }
        p {
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Server Information</h1>
        <p><strong>Server IP Address:</strong> ${ip_address}</p>
        <p><strong>Server Hostname:</strong> ${hostname}</p>
    </div>
</body>
</html>
EOF
