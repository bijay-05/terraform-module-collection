variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "subnets" {
  type = map(object({
    cidr_block = string
    az = string
    public = string
  }))
  default = {
    "public_subnet_1" = {
      cidr_block = "10.1.1.0/24"
      az = "us-east-1a"
      public = true
    },
    # "public_subnet_2" = {
    #     cidr_block = "10.1.2.0/24"
    #     az = "ap-south-1a"
    #     public = true
    # }
  }
}