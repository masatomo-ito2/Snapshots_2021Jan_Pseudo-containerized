variable "owner" {
  default = "masa"
}

variable "key_name" {
  default = "masa"
}

variable "prefix" {
  default = "snapshots"
}

variable "allowed_inbound_cidrs" {
  default = "0.0.0.0/0"
}

variable "servers" {
  default = 1
}

variable "clients" {
  default = 2
}
