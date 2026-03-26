# output "servers_ips" {
#     value = module.web_server[*].public_ip
# }

output "bastion-host-Public-IP" {
  value = module.webserver.Bastion-Public-IP
}
output "alb-dns" {
  value = module.webserver.alb-dns
}
