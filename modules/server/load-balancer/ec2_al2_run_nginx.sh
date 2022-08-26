#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo systemctl enable nginx
echo "<h1>Hello from $(hostname)</h1>" | sudo tee /var/www/html/index.html > /dev/null
sudo systemctl start nginx