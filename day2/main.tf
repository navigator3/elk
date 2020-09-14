resource "google_compute_network" "elk_network" {
  name                    = "${var.network-name}"
  auto_create_subnetworks = false
  description             = "create VPC"
}

resource "google_compute_subnetwork" "elk_sub_net" {
  name          = "${var.elk-sub-net-name}"
  ip_cidr_range = "${var.elk-sub-net-ip-range}"
  region        = "${var.region}"
  network       = google_compute_network.elk_network.id
  depends_on    = [google_compute_network.elk_network, ]
  description   = "create subnetwork"
}
resource "google_compute_firewall" "elk_firewall_web" {
  name        = "elk-firewall-web"
  network     = google_compute_network.elk_network.name
  target_tags = ["elk-web"]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = "${var.web-port}"
  }
  allow {
    protocol = "udp"
    ports    = "${var.web-port}"
  }
  source_ranges = ["0.0.0.0/0"]
  description   = "create firewall web rules for 80,22 ports"
}

resource "google_compute_address" "external_ip" {
  name = "my-external-address"
  #subnetwork   = google_compute_subnetwork.elk_sub_net.id
  address_type = "EXTERNAL"
  #  address      = "10.0.42.42"
  region = "${var.region}"
}
resource "google_compute_address" "internal_ip" {
  name         = "my-internal-address"
  subnetwork   = google_compute_subnetwork.elk_sub_net.id
  address_type = "INTERNAL"
  #address      = "10.0.42.42"
  region = "${var.region}"
}

resource "google_compute_instance" "default" {
  name         = "elk-${var.createway}"
  machine_type = "${var.machinetype}"
  zone         = "${var.zone}"
  description  = "create elk"
  tags         = ["elk-web"]
  metadata = {
    ssh-keys = "cmetaha17:${file("id_rsa.pub")}"
  }
  #    tags = var.tags
  #    labels = var.labels
  #metadata_startup_script = <<EFO
  #EFO
  metadata_startup_script = templatefile("startup.sh", {
    name    = "Sergei"
    surname = "Shevtsov"
    ext_ip  = google_compute_address.external_ip.address
    int_ip  = google_compute_address.internal_ip.address
  })

  boot_disk {
    initialize_params {
      image = "${var.image}"
      size  = "${var.hdd-size}"
      type  = "${var.hdd-type}"
    }

  }
  #provisioner "file" {
  #  source      = "scripts/"
  #  destination = "/home/"
  #}
  network_interface {
    #  count      = "${var.network-name}" == "default" ? 0 : 1
    network    = google_compute_network.elk_network.name    #"${var.network-name}"
    subnetwork = google_compute_subnetwork.elk_sub_net.name #"${var.sub-network-name}"
    network_ip = google_compute_address.internal_ip.address
    access_config {
      // Ephemeral IP
      nat_ip = google_compute_address.external_ip.address
    }
  }
}

resource "google_compute_instance" "elk_cli" {
  count        = 1
  name         = "elk-cli-${var.createway}"
  machine_type = "${var.machinetype}"
  zone         = "${var.zone}"
  description  = "create elk clients"
  tags         = ["elk-web"]
  metadata = {
    ssh-keys = "cmetaha17:${file("id_rsa.pub")}"
  }
  #    tags = var.tags
  #    labels = var.labels
  #metadata_startup_script = <<EFO
  #EFO
  metadata_startup_script = templatefile("startup-cli.sh", {
    name            = "Sergei"
    surname         = "Shevtsov"
    ip_elk_serv_int = google_compute_instance.default.network_interface.0.network_ip
  })

  boot_disk {
    initialize_params {
      image = "${var.image}"
      size  = "${var.hdd-size}"
      type  = "${var.hdd-type}"
    }

  }
  #provisioner "file" {
  #  source      = "scripts/"
  #  destination = "/home/"
  #}
  network_interface {
    #  count      = "${var.network-name}" == "default" ? 0 : 1
    network    = google_compute_network.elk_network.name    #"${var.network-name}"
    subnetwork = google_compute_subnetwork.elk_sub_net.name #"${var.sub-network-name}"
    access_config {
      // Ephemeral IP
    }
  }
}
