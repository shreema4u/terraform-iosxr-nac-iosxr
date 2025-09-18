locals {
  device_segment_routing_v6_configs = flatten([
    for device in local.devices : [
      {
        device_name = device.name
        key         = "${device.name}-segment_routing_v6"

        delete_mode                  = try(local.device_config[device.name].segment_routing_v6.delete_mode, local.defaults.iosxr.configuration.segment_routing_v6.delete_mode, null)
        enable                       = try(local.device_config[device.name].segment_routing_v6.enable, local.defaults.iosxr.configuration.segment_routing_v6.enable, null)
        encapsulation_source_address = try(local.device_config[device.name].segment_routing_v6.encapsulation_source_address, local.defaults.iosxr.configuration.segment_routing_v6.encapsulation_source_address, null)

        locators = [
          for locator in try(local.device_config[device.name].segment_routing_v6.locators, local.defaults.iosxr.configuration.segment_routing_v6.locators, []) : {
            name                   = try(locator.name, null)
            locator_enable         = try(locator.locator_enable, null)
            micro_segment_behavior = try(locator.micro_segment_behavior, null)
            prefix                 = try(locator.prefix, null)
            prefix_length          = try(locator.prefix_length, null)
          }
        ]
      }
    ] if try(local.device_config[device.name].segment_routing_v6, null) != null || try(local.defaults.iosxr.configuration.segment_routing_v6, null) != null
  ])
}

resource "iosxr_segment_routing_v6" "segment_routing_v6" {
  for_each = { for config in local.device_segment_routing_v6_configs : config.key => config }
  device   = each.value.device_name

  delete_mode                  = each.value.delete_mode
  enable                       = each.value.enable
  encapsulation_source_address = each.value.encapsulation_source_address
  locators                     = each.value.locators
}