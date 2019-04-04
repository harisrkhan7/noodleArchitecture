variable "access_key" {
  type = "string"
}

variable "secret_key" {
  type = "string"
}
variable "instance_password" {
    type="string"
    default="newTestPassword123"
}

provider "alicloud" {
    access_key="${var.access_key}"
    secret_key="${var.secret_key}"
    region = "${var.region}"
}

#Create vpc
resource "alicloud_vpc" "vpc" {
  name       = "default"
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id            = "${alicloud_vpc.vpc.id}"
  cidr_block        = "172.16.0.0/21"
  availability_zone = "${var.switch_region}"
}

# Create security group
resource "alicloud_security_group" "default" {
  name        = "default"
  description = "default"
  vpc_id = "${alicloud_vpc.vpc.id}"
}
resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = "${alicloud_security_group.default.id}"
  cidr_ip           = "0.0.0.0/0"
}