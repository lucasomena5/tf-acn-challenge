#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
instance_id=$(curl http://169.254.169.254/latest/meta-data/instance-id)
cat <<EOF >> /var/www/html/index.html
<!DOCTYPE html>
<html>
<body style="background-color:lightblue;">
<h1>$instance_id</h1>
</body>
</html>
EOF