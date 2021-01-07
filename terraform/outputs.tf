output "public_ips_servers" {
  value = data.aws_instances.servers.*.public_ips
}

output "public_ips_clients" {
  value = data.aws_instances.clients.*.public_ips
}

output "private_ips_servers" {
  value = data.aws_instances.servers.*.private_ips
}

output "private_ips_clients" {
  value = data.aws_instances.clients.*.private_ips
}

output "consul_master_token" {
	value = module.nomad-starter.consul_master_token
}
