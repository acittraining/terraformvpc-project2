#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd.service
systemctl enable httpd.service
echo "<h1> Welcome to AC-IT Training Solutions Terraform VPC Project1" > /var/www/html/index.html
