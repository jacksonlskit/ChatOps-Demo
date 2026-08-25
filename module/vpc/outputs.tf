output "vpc_id" {
  value = aws_vpc.Chatdemo_vpc.id

}

output "public_subnet_id" {
  value = aws_subnet.Chatdemo_public_subnet.id
}

output "public_route_table_id" {
  value = aws_route_table.Chatdemo_public_rt.id
}

