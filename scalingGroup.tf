
data "alicloud_instance_types" "2c4g" {
  cpu_core_count = 2
  memory_size = 4
}

data "alicloud_images" "default" {
  name_regex  = "^ubuntu"
  most_recent = true
  owners      = "system"
}

resource "alicloud_ess_scaling_group" "scaling" {
  min_size           = 1
  max_size           = 2
  removal_policies   = ["OldestInstance", "NewestInstance"]
  vswitch_ids = ["${alicloud_vswitch.vsw.id}"]
  loadbalancer_ids = ["${alicloud_slb.master.id}"]
  db_instance_ids = ["${alicloud_db_instance.master.id}"]

  depends_on = ["alicloud_slb_listener.tcp"]

}

resource "alicloud_ess_scaling_configuration" "config" {
  scaling_group_id  = "${alicloud_ess_scaling_group.scaling.id}"

  image_id          = "${data.alicloud_images.default.images.0.id}"
  internet_charge_type  = "PayByTraffic"
  active = true
  enable = true
  force_delete = true
  

  instance_type        = "${data.alicloud_instance_types.2c4g.instance_types.0.id}"
  system_disk_category = "cloud_efficiency"
  security_group_id     = "${alicloud_security_group.default.id}"
  instance_name        = "web"
  
  
  user_data = "config_service.sh --portrange=${alicloud_security_group_rule.allow_all_tcp.port_range}"
  internet_max_bandwidth_out = 1
  key_name = "${var.public_key_name}" 
}

resource "alicloud_ess_scaling_rule" "addOneInstance" {
  scaling_group_id = "${alicloud_ess_scaling_group.scaling.id}"
  adjustment_type  = "QuantityChangeInCapacity"
  adjustment_value = 1
  cooldown         = 60
}
resource "alicloud_ess_alarm" "eightyPercentCpuUtilization" {
    name = "alarm-eightyPercentCpuUtilisation"
    alarm_actions = ["${alicloud_ess_scaling_rule.addOneInstance.ari}"]
    scaling_group_id = "${alicloud_ess_scaling_group.scaling.id}"
    metric_type = "system"
    metric_name = "CpuUtilization"
    period = 300
    statistics = "Average"
    threshold = 80
    comparison_operator = ">="
    evaluation_count = 2 
}
