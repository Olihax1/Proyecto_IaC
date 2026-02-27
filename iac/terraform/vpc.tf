# --- VPC ---
resource "aws_vpc" "principal" {
  cidr_block           = var.cidr_vpc
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(local.tags, { Name = "${local.nombre}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.principal.id
  tags   = merge(local.tags, { Name = "${local.nombre}-igw" })
}

resource "aws_subnet" "publicas" {
  for_each                = { for i, cidr in var.subredes_publicas : i => cidr }
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.zonas.names[tonumber(each.key)]
  map_public_ip_on_launch = true
  tags                    = merge(local.tags, { Name = "${local.nombre}-publica-${each.key}" })
}

resource "aws_subnet" "privadas" {
  for_each          = { for i, cidr in var.subredes_privadas : i => cidr }
  vpc_id            = aws_vpc.principal.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.zonas.names[tonumber(each.key)]
  tags              = merge(local.tags, { Name = "${local.nombre}-privada-${each.key}" })
}

resource "aws_route_table" "rt_publica" {
  vpc_id = aws_vpc.principal.id
  tags   = merge(local.tags, { Name = "${local.nombre}-rt-publica" })
}

resource "aws_route" "salida_internet" {
  route_table_id         = aws_route_table.rt_publica.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "asoc_publicas" {
  for_each       = aws_subnet.publicas
  subnet_id      = each.value.id
  route_table_id = aws_route_table.rt_publica.id
}

# --- NAT Gateway para salida a Internet desde subredes privadas ---

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = merge(local.tags, { Name = "${local.nombre}-eip-nat" })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.publicas["0"].id

  depends_on = [aws_internet_gateway.igw]

  tags = merge(local.tags, { Name = "${local.nombre}-nat" })
}

resource "aws_route_table" "rt_privada" {
  vpc_id = aws_vpc.principal.id
  tags   = merge(local.tags, { Name = "${local.nombre}-rt-privada" })
}

resource "aws_route" "salida_internet_privada" {
  route_table_id         = aws_route_table.rt_privada.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "asoc_privadas" {
  for_each       = aws_subnet.privadas
  subnet_id      = each.value.id
  route_table_id = aws_route_table.rt_privada.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.principal.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.rt_publica.id]
  tags              = merge(local.tags, { Name = "${local.nombre}-vpce-s3" })
}
