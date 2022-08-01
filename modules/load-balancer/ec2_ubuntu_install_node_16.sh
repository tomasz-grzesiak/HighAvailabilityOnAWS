#! /bin/bash
sudo apt update
sudo apt install -yq nodejs
sudo apt install -yq npm
sudo npm install -g n
sudo n 16

sudo apt install -yq ruby-full ruby-webrick wget
cd /tmp
wget https://aws-codedeploy-eu-south-1.s3.eu-south-1.amazonaws.com/releases/codedeploy-agent_1.3.2-1902_all.deb
mkdir codedeploy-agent_1.3.2-1902_ubuntu22
dpkg-deb -R codedeploy-agent_1.3.2-1902_all.deb codedeploy-agent_1.3.2-1902_ubuntu22
sed 's/Depends:.*/Depends:ruby3.0/' -i ./codedeploy-agent_1.3.2-1902_ubuntu22/DEBIAN/control
dpkg-deb -b codedeploy-agent_1.3.2-1902_ubuntu22/
sudo dpkg -i codedeploy-agent_1.3.2-1902_ubuntu22.deb
sudo service codedeploy-agent enable





wget https://aws-codedeploy-eu-south-1.s3.eu-south-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto > /tmp/logfile
