output "address" {
  value = "${aws_lb.logstash_nlb.dns_name}"
}

output "nlb_target" {
  value = "${aws_lb_target_group.logstash.arn}"
}

output "elastic_endpoint" {
  value = "${aws_elasticsearch_domain.es.endpoint}"
}
