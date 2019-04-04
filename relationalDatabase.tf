data "alicloud_db_instances" "db_instances_ds" {
  name_regex = "data-\\d+"
  status     = "Running"
  tags       = <<EOF
{
  "type": "database",
  "size": "small"
}
EOF
}

resource "alicloud_db_instance" "master" {
    engine = "MySQL"
    engine_version = "5.7"
    instance_type = "rds.mysql.t1.small"
    instance_storage = "30"
    vswitch_id = "${alicloud_vswitch.vsw.id}"
}
resource "alicloud_db_database" "default" {
    instance_id = "${alicloud_db_instance.master.id}"
    name = "tf_database"
    character_set = "utf8"
}
