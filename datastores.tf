# Declare the data source
data "aws_availability_zones" "zones" {
  state = "available"
}

output "zone-names" {

    value = data.aws_availability_zones.zones
  
}