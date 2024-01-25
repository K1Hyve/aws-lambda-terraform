resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  assign_generated_ipv6_cidr_block     = true
  enable_network_address_usage_metrics = true

}

# Public subnet

resource "aws_subnet" "subnet_public" {
  count = length(var.subnet_public_cidr_block)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.subnet_public_cidr_block, count.index)
  availability_zone = element(local.azs, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.project}-public"
  }
}

resource "aws_route_table_association" "route_table_association_public" {
  count = length(var.subnet_public_cidr_block)

  subnet_id      = element(aws_subnet.subnet_public[*].id, count.index)
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_subnet" "nat_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.nat_subnet
  availability_zone = local.azs[0]
}

resource "aws_eip" "eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.nat_subnet.id

  depends_on = [aws_eip.eip]
}

# Private subnet

resource "aws_subnet" "subnet_private" {
  count = length(var.subnet_private_cidr_block)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.subnet_private_cidr_block, count.index)
  availability_zone = element(local.azs, count.index)

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project}-private"
  }
}

resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.project}-private"
  }
}

resource "aws_route_table_association" "route_table_association_private" {
  count = length(var.subnet_public_cidr_block)

  subnet_id      = element(aws_subnet.subnet_private[*].id, count.index)
  route_table_id = aws_route_table.route_table_private.id
}


# Security

resource "aws_default_network_acl" "default_network_acl" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id
  subnet_ids = concat(
    [for i, subnet in var.subnet_private_cidr_block : aws_subnet.subnet_private[i].id],
    [for i, subnet in var.subnet_public_cidr_block : aws_subnet.subnet_public[i].id],
  )

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.project}-default-network-acl"
  }
}

resource "aws_default_security_group" "default_security_group" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = ["127.0.0.1/32"]
  }

  tags = {
    Name = "${var.project}-default-security-group"
  }
}
