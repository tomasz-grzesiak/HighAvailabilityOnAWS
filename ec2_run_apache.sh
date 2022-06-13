#! /bin/bash
sudo yum install -y httpd
sudo systemctl enable apache2
echo "<h1>Hello from $(hostname)</h1>" | sudo tee /var/www/html/index.html > /dev/null
sudo systemctl start httpd