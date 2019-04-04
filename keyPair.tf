variable "public_key_name" {
    type="string"
    default="autoscalingKey"
}

variable "public_key_path" {
    type="string"
    default="autoscalingKey.pub"
}
variable "private_key_path" {
  type="string"
  default="autoscalingKey"
}

resource "alicloud_key_pair" "publickey" {
    key_name = "${var.public_key_name}"
    public_key = "${file(var.public_key_path)}"
}