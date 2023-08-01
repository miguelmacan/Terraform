provider "aws" {
  region = "us-east-1" # Substitua pela região desejada da AWS
}

# Criação da VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Criação da sub-rede pública
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Substitua pela zona de disponibilidade desejada
}

# Criação da sub-rede privada
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b" # Substitua pela zona de disponibilidade desejada
}

# Criação do grupo de segurança
resource "aws_security_group" "web_sg" {
  name_prefix = "web_sg_"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Criação do endereço IP elástico para o NAT Gateway
resource "aws_eip" "nat_eip" {
}

# Criação do NAT Gateway na sub-rede pública
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

# Criação da rota para a sub-rede privada apontando para o NAT Gateway
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

# Associar a tabela de roteamento privada à sub-rede privada
resource "aws_route_table_association" "private_route_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# Criação da instância EC2 na sub-rede pública
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Substitua pela AMI desejada
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "Web Server"
  }
}
