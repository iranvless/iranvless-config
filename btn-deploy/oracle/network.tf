# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_core_virtual_network" "iranvless_main_vcn" {
  cidr_block     = lookup(var.network_cidrs, "MAIN-VCN-CIDR")
  compartment_id = var.compartment_ocid
  display_name   = "iranvless-main"
  dns_label      = "iranvlessmain"
  freeform_tags  = local.common_tags
  count = local.vcn_existed?0:1
}

resource "oci_core_subnet" "iranvless_main_subnet" {
  cidr_block                 = lookup(var.network_cidrs, "MAIN-SUBNET-REGIONAL-CIDR")
  display_name               = "iranvless-main"
  dns_label                  = "iranvlessmain"
  security_list_ids          = [oci_core_security_list.iranvless_security_list[0].id]
  compartment_id             = var.compartment_ocid
  vcn_id = local.new_vcn_id
  route_table_id             = oci_core_default_route_table.iranvless_main_route_table[0].id
  dhcp_options_id            = oci_core_virtual_network.iranvless_main_vcn[0].default_dhcp_options_id
  prohibit_public_ip_on_vnic = false
  freeform_tags              = local.common_tags
  count = local.vcn_existed?0:1
}



resource "oci_core_default_route_table" "iranvless_main_route_table" {
	route_rules {
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		network_entity_id = "${oci_core_internet_gateway.iranvless_internet_gateway[0].id}"
	}
	manage_default_resource_id = "${oci_core_virtual_network.hiddify_main_vcn[0].default_route_table_id}"
  count = local.vcn_existed?0:1
}


resource "oci_core_internet_gateway" "iranvless_internet_gateway" {
	compartment_id = (var.lb_compartment_ocid != "") ? var.lb_compartment_ocid : var.compartment_ocid
	display_name   = "iranvless-internet-gateway-${random_string.deploy_id.result}"
	enabled = "true"
	vcn_id = local.new_vcn_id
  freeform_tags  = local.common_tags
  count = local.vcn_existed?0:1
}
