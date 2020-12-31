/*
Copyright 2018 Google LLC
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    https://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

locals {
  region         = regex("^([[:alnum:]]+\\-[[:alnum:]]+)", var.cluster_location)[0]
  pod_range      = "10.1.0.0/16"
  pod_range_name = format("%s-pod-range", var.cluster_name)
  svc_range      = "10.2.0.0/20"
  svc_range_name = format("%s-svc-range", var.cluster_name)
  master_range   = "172.16.0.16/28"
}

resource "google_compute_network" "network" {
  count                   = var.network == null ? 1 : 0
  name                    = format("%s-network", var.cluster_name)
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = format("%s-subnet", var.cluster_name)
  network       = try(google_compute_network.network[0].self_link, var.network)
  region        = local.region
  ip_cidr_range = "10.0.0.0/24"

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = local.pod_range_name
    ip_cidr_range = local.pod_range
  }

  secondary_ip_range {
    range_name    = local.svc_range_name
    ip_cidr_range = local.svc_range
  }
}
