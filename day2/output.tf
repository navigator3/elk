output "Resalt" {
  value = <<EOF
!!!! Atantion: you must wait some minutes before click the link!!!
Kibana here: http://${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}:5601
interntal serv ip: ${google_compute_instance.default.network_interface.0.network_ip}

Tomcat VM was created to: http://${google_compute_instance.elk_cli[0].network_interface[0].access_config[0].nat_ip}:8080
interntal tomcat ip: ${google_compute_instance.elk_cli[0].network_interface.0.network_ip}

EOF

}
