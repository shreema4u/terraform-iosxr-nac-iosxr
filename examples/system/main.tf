module "iosxr" {
  source = "netascode/nac-iosxr/iosxr"

  yaml_files = ["system.nac.yaml"]
}