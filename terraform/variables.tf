variable "instance_name" {
  description = "Name of cluster"
  type        = string
}

variable "region" {
  description = "Region to create the cluster"
  type        = string
}

variable "instance_type" {
  description = "The instance type, g4 or g5, need RTX Nvidia GPU"
  type        = string
  default     = "g5.2xlarge"
}

variable "nvidia_ami" {
  description = "AMI for the Nvidia instance, headless"
  type        = string
}

variable "subnet" {
  default = "10.0.0.0/24"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "env" {}