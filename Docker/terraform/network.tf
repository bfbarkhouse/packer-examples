data "aws_availability_zones" "available_zones" {
  state = "available"
}
resource "aws_vpc" "bbarkhouse-ecs-vpc" {
  cidr_block = "10.32.0.0/16"
}
resource "aws_subnet" "public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.bbarkhouse-ecs-vpc.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.bbarkhouse-ecs-vpc.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.bbarkhouse-ecs-vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.bbarkhouse-ecs-vpc.id
}
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.bbarkhouse-ecs-vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.bbarkhouse-ecs-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_eip" "gateway" {
  count      = 2
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gateway]
}

resource "aws_nat_gateway" "gateway" {
  count         = 2
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gateway.*.id, count.index)
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.bbarkhouse-ecs-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway.*.id, count.index)
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
resource "aws_security_group" "lb_sg" {
  name   = "bbarkhouse-ecs-alb-security-group"
  vpc_id = aws_vpc.bbarkhouse-ecs-vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}