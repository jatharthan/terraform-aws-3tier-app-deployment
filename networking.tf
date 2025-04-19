resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.project_prefix}-vpc"
  }
}

# Subnets in AZ1 (us-east-1a)
resource "aws_subnet" "public_web_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.project_prefix}-Public-Web-Subnet-AZ1"
  }
}

resource "aws_subnet" "private_app_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.project_prefix}-Private-App-Subnet-AZ1"
  }
}

resource "aws_subnet" "private_db_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.project_prefix}-Private-DB-Subnet-AZ1"
  }
}

# Subnets in AZ2 (us-east-1b)
resource "aws_subnet" "public_web_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.48.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.project_prefix}-Public-Web-Subnet-AZ2"
  }
}

resource "aws_subnet" "private_app_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.64.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.project_prefix}-Private-App-Subnet-AZ2"
  }
}

resource "aws_subnet" "private_db_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.80.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.project_prefix}-Private-DB-Subnet-AZ2"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_prefix}-internet-gateway"
  }
}

# Elastic IP for NAT Gateway in AZ1
resource "aws_eip" "nat_eip_az1" {
  domain = "vpc"

  tags = {
    Name = "${var.project_prefix}-nat-eip-az1"
  }
}

# Elastic IP for NAT Gateway in AZ2
resource "aws_eip" "nat_eip_az2" {
  domain = "vpc"

  tags = {
    Name = "${var.project_prefix}-nat-eip-az2"
  }
}

# NAT Gateway in AZ1 Public Web Subnet
resource "aws_nat_gateway" "nat_gw_az1" {
  allocation_id = aws_eip.nat_eip_az1.id
  subnet_id     = aws_subnet.public_web_az1.id

  tags = {
    Name = "${var.project_prefix}-nat-gateway-az1"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

# NAT Gateway in AZ2 Public Web Subnet
resource "aws_nat_gateway" "nat_gw_az2" {
  allocation_id = aws_eip.nat_eip_az2.id
  subnet_id     = aws_subnet.public_web_az2.id

  tags = {
    Name = "${var.project_prefix}-nat-gateway-az2"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

# Route Table for Public Web Layer
resource "aws_route_table" "public_web_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_prefix}-public-web-rt"
  }
}

# Route to Internet via IGW
resource "aws_route" "public_web_internet_route" {
  route_table_id         = aws_route_table.public_web_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Association with Public Web Subnet in AZ1
resource "aws_route_table_association" "public_web_az1_assoc" {
  subnet_id      = aws_subnet.public_web_az1.id
  route_table_id = aws_route_table.public_web_rt.id
}

# Association with Public Web Subnet in AZ2
resource "aws_route_table_association" "public_web_az2_assoc" {
  subnet_id      = aws_subnet.public_web_az2.id
  route_table_id = aws_route_table.public_web_rt.id
}

# Route Table for App Layer Private Subnet in AZ1
resource "aws_route_table" "private_app_rt_az1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_prefix}-private-app-rt-az1"
  }
}

# Route for AZ1 App Subnet via NAT Gateway AZ1
resource "aws_route" "private_app_route_az1" {
  route_table_id         = aws_route_table.private_app_rt_az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_az1.id
}

# Associate AZ1 App Layer Subnet
resource "aws_route_table_association" "private_app_az1_assoc" {
  subnet_id      = aws_subnet.private_app_az1.id
  route_table_id = aws_route_table.private_app_rt_az1.id
}

# Route Table for App Layer Private Subnet in AZ2
resource "aws_route_table" "private_app_rt_az2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_prefix}-private-app-rt-az2"
  }
}

# Route for AZ2 App Subnet via NAT Gateway AZ2
resource "aws_route" "private_app_route_az2" {
  route_table_id         = aws_route_table.private_app_rt_az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_az2.id
}

# Associate AZ2 App Layer Subnet
resource "aws_route_table_association" "private_app_az2_assoc" {
  subnet_id      = aws_subnet.private_app_az2.id
  route_table_id = aws_route_table.private_app_rt_az2.id
}

# Load Balancer Security Group
resource "aws_security_group" "public_lb_sg" {
  name        = "${var.project_prefix}-public-lb-sg"
  description = "Security group for public internet-facing Load Balancer"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP traffic from anywhere
  ingress {
    description      = "Allow HTTP from the internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }

  # Allow all outbound traffic
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "${var.project_prefix}-public-lb-sg"
  }
}


# Security Group for Public Instances in Web Tier
resource "aws_security_group" "public_web_sg" {
  name        = "${var.project_prefix}-public-web-sg"
  description = "Security group for public instances in the web tier"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from the Load Balancer Security Group
  ingress {
    description      = "Allow HTTP from Load Balancer"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.public_lb_sg.id]  # Reference the LB security group
  }

  # Allow HTTP from any IP address
  ingress {
    description      = "Allow HTTP from all IPs"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }

  # Allow all outbound traffic
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "${var.project_prefix}-public-web-sg"
  }
}

# Security Group for Internal Load Balancer
resource "aws_security_group" "internal_lb_sg" {
  name        = "${var.project_prefix}-internal-lb-sg"
  description = "Security group for internal load balancer"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from the Public Web Instance Security Group
  ingress {
    description      = "Allow HTTP from Web Instances"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.public_web_sg.id]  # Reference the web instances SG
  }

  # Allow all outbound traffic
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "${var.project_prefix}-internal-lb-sg"
  }
}

# Security Group for Private Instances in App Tier
resource "aws_security_group" "private_app_sg" {
  name        = "${var.project_prefix}-private-app-sg"
  description = "Security group for private instances in app tier"
  vpc_id      = aws_vpc.main.id

  # Allow TCP traffic on port 4000 from the Internal Load Balancer Security Group
  ingress {
    description      = "Allow TCP on port 4000 from Internal Load Balancer"
    from_port        = 4000
    to_port          = 4000
    protocol         = "tcp"
    security_groups  = [aws_security_group.internal_lb_sg.id]  # Reference the internal load balancer SG
  }

  # Allow TCP traffic on port 4000 from any IP address
  ingress {
    description      = "Allow TCP on port 4000 from any IP"
    from_port        = 4000
    to_port          = 4000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # Allow from anywhere
  }

  # Allow all outbound traffic
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "${var.project_prefix}-private-app-sg"
  }
}
# Security Group for Private Database Instances
resource "aws_security_group" "private_db_sg" {
  name        = "${var.project_prefix}-private-db-sg"
  description = "Security group for private database instances"
  vpc_id      = aws_vpc.main.id

  # Allow MySQL/Aurora traffic (port 3306) from the Private App Instance Security Group
  ingress {
    description      = "Allow MySQL traffic from App Instances"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.private_app_sg.id]  # Reference the private app instances SG
  }

  # Allow all outbound traffic (typical for databases)
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "${var.project_prefix}-private-db-sg"
  }
}

# RDS DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.project_prefix}-db-subnet-group"
  description = "DB subnet group for the private database layer"
  subnet_ids  = [
    aws_subnet.private_db_az1.id, 
    aws_subnet.private_db_az2.id
  ]

  tags = {
    Name = "${var.project_prefix}-db-subnet-group"
  }
}





