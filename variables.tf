variable "aws_region" {
  type = string
  default = "ap-northeast-1"
}

//variable "default_subnet" {
//  description = "default_subnet"
//  default = "subnet"
//}

variable "db_read_capacity" {
  type = number
  default = 5
}

variable "db_write_capacity" {
  type = number
  default = 5
}