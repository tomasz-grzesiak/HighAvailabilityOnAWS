#! /bin/bash
echo "<h1>Hello from $(hostname)</h1>" | sudo tee /var/www/html/index.html > /dev/null