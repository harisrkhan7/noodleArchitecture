resource "alicloud_slb" "master" {
  name                 = "master-slb"
  internet             = true
  internet_charge_type = "paybytraffic"
  bandwidth            = 5
  specification = "slb.s1.small"
  vswitch_id = "${alicloud_vswitch.vsw.id}"
}

resource "alicloud_slb_acl" "acl" {
  name = "master-acl"
  ip_version = "ipv4"
  entry_list = [
    {
      entry="10.10.10.0/24"
      comment="first"
    },
    {
      entry="168.10.10.0/24"
      comment="second"
    },
    {
      entry="172.10.10.0/24"
      comment="third"
    },
  ]
}

resource "alicloud_slb_listener" "tcp" {
  load_balancer_id = "${alicloud_slb.master.id}"
  backend_port = "22"
  frontend_port = "22"
  protocol = "tcp"
  bandwidth = "10"
  health_check_type = "tcp"
  acl_status                = "on"
  acl_type                  = "white"
  acl_id                    = "${alicloud_slb_acl.acl.id}"
  established_timeout       = 600
}
