#README.md for Cloud Formation

Included in this repo are Cloud Formation Templates
I intend to have this repo continually grow as additional use cases present themselves

~~ OnboardAdmin.yaml ~~
This is a generic template that creates a few IAM groups, and a full Admin IAM user using parameters to customize as needed.

~~ VPC1Instance2xlarge.yaml ~~
This template creates a VPC, subnet, Internet Gateway, default Security group for the created subnet, Admin IAM user and group, route table with internet access, Keypaid, a t3.2xlarge instance with Win Server, and runs a few Powershell commands to create an administrator username and password, and rename the computer.
