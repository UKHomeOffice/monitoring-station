resource "aws_ami_copy" "encryptedami" {
  name              = "ubuntu1604enc"
  description       = "A copy of ami-xxxxxxxx"
  source_ami_id = "${lookup(var.aws_amis, var.aws_region)}"
  source_ami_region = "${var.aws_region}"
  tags {
    Name = "Ubuntu 1604 LTS Encrypted"
  }
}

resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/22"
  enable_dns_hostnames = true
  tags {
    Name = "search"
  }
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = "${aws_vpc.default.default_network_acl_id}"
  # no rules defined, deny all traffic in this ACL
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-west-2a"
  tags {
    Name = "search_subnet_a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2b"
  tags {
    Name = "search_subnet_b"
  }
}

resource "aws_subnet" "subnet_a_private" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-2a"
  tags {
    Name = "search_subnet_a_private"
  }
}

resource "aws_subnet" "subnet_b_private" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-2b"
  tags {
    Name = "search_subnet_b_private"
  }
}

resource "aws_network_acl" "public_net_acl" {
  vpc_id = "${aws_vpc.default.id}"
  subnet_ids = ["${aws_subnet.subnet_a.id}","${aws_subnet.subnet_b.id}"]
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  egress {
    protocol   = "tcp"
    rule_no    = 201
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  egress {
    protocol   = "udp"
    rule_no    = 202
    action     = "allow"
    cidr_block = "169.254.169.253/32"
    from_port  = 53
    to_port    = 53
  }
  egress {
    protocol   = "udp"
    rule_no    = 203
    action     = "allow"
    cidr_block = "10.0.0.0/22"
    from_port  = 53
    to_port    = 53
  }
  egress {
    protocol   = "udp"
    rule_no    = 204
    action     = "allow"
    cidr_block = "169.254.169.123/32"
    from_port  = 123
    to_port    = 123
  }
  egress {
    protocol   = "tcp"
    rule_no    = 205
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 5044
    to_port    = 5044
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  tags {
    Name = "PublicACL"
  }
}

resource "aws_network_acl" "private_net_acl" {
  vpc_id = "${aws_vpc.default.id}"
  subnet_ids = ["${aws_subnet.subnet_a_private.id}","${aws_subnet.subnet_b_private.id}"]
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 1024
    to_port    = 65535
  }
  egress {
    protocol   = "tcp"
    rule_no    = 201
    action     = "allow"
    cidr_block = "10.0.0.0/24"
    from_port  = 1024
    to_port    = 65535
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 80
    to_port    = 80
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 201
    action     = "allow"
    cidr_block = "10.0.0.0/24"
    from_port  = 80
    to_port    = 80
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 202
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 203
    action     = "allow"
    cidr_block = "10.0.0.0/24"
    from_port  = 443
    to_port    = 443
  }
  tags {
    Name = "PrivateACL"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"
  tags {
    Name = "internet_gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags {
    Name = "aws_route_table"
  }
}

resource "aws_route_table_association" "route_table_association_a" {
  subnet_id      = "${aws_subnet.subnet_a.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_route_table_association" "route_table_association_b" {
  subnet_id      = "${aws_subnet.subnet_b.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

# Our default security group to access
# the instances over SSH and TCP Filebeat
resource "aws_security_group" "default" {
  name        = "logstash_sg"
  description = "Logstash Security Group"
  vpc_id      = "${aws_vpc.default.id}"
  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Filebeat access from anywhere
  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "logstash_nlb" {
  name            = "logstash-nlb"
  internal        = false
  load_balancer_type = "network"
  subnets         = ["${aws_subnet.subnet_a.id}","${aws_subnet.subnet_b.id}"]
  enable_deletion_protection = false
  tags {
    Name = "Logstash FileBeat NLB"
  }
}

resource "aws_lb_listener" "filebeat" {
   load_balancer_arn = "${aws_lb.logstash_nlb.arn}"
   port = "5044"
   protocol = "TCP"
default_action {
     target_group_arn = "${aws_lb_target_group.logstash.arn}"
     type = "forward"
   }
}

resource "aws_lb_target_group" "logstash" {
  name = "logstash-lb-tg"
  port = 5044
  protocol = "TCP"
  vpc_id = "${aws_vpc.default.id}"
  deregistration_delay = 0
health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 3
      port = 5044
      protocol = "TCP"
  }
}

#data "aws_elb_service_account" "main" {}
#
#resource "aws_s3_bucket_policy" "search_logs_policy" {
#  bucket = "${aws_s3_bucket.search_logs.id}"
#  policy =<<POLICY
#{
#  "Id": "Policy",
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": [
#        "s3:PutObject"
#      ],
#      "Effect": "Allow",
#      "Resource": "arn:aws:s3:::keao-search-logs-1/logstash-lb/AWSLogs/*",
#      "Principal": {
#        "AWS": [
#          "${data.aws_elb_service_account.main.arn}"
#        ]
#      }
#    }
#  ]
#}
#POLICY
#}
#
#resource "aws_s3_bucket" "search_logs" {
#  bucket = "keao-search-logs-1"
#  tags {
#    Name        = "Search Bucket"
#  }
#}

resource "aws_instance" "logstash_a" {
  instance_type = "t2.micro"
  ami = "${aws_ami_copy.encryptedami.id}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id              = "${aws_subnet.subnet_a.id}"
  user_data              = "${file("userdata.sh")}"
  associate_public_ip_address = true
  tags {
    Name = "logstash_a"
  }
}

resource "aws_lb_target_group_attachment" "logstash_a" {
  target_group_arn = "${aws_lb_target_group.logstash.arn}"
  target_id        = "${aws_instance.logstash_a.id}"
  port             = 5044
}

resource "aws_instance" "logstash_b" {
  instance_type = "t2.micro"
  ami = "${aws_ami_copy.encryptedami.id}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id              = "${aws_subnet.subnet_b.id}"
  user_data              = "${file("userdata.sh")}"
  associate_public_ip_address = true
  tags {
    Name = "logstash_b"
  }
}

resource "aws_lb_target_group_attachment" "logstash_b" {
  target_group_arn = "${aws_lb_target_group.logstash.arn}"
  target_id        = "${aws_instance.logstash_b.id}"
  port             = 5044
}

resource "aws_security_group" "elastic" {
  name        = "elastic_sg"
  description = "Elastic Security Group"
  vpc_id      = "${aws_vpc.default.id}"
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = "search"
  elasticsearch_version = "6.0"
  cluster_config {
    instance_type = "m4.large.elasticsearch"
    instance_count = 2
    dedicated_master_enabled = true
    dedicated_master_type = "m4.large.elasticsearch"
    dedicated_master_count = 3
    zone_awareness_enabled = true
  }
  ebs_options {
    ebs_enabled = true
    volume_type = "standard"
    volume_size = 10
  }
  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }
  vpc_options {
  security_group_ids = ["${aws_security_group.elastic.id}"]
  subnet_ids = ["${aws_subnet.subnet_a_private.id}","${aws_subnet.subnet_b_private.id}"]
  }
  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Action": [
        "es:*"
      ],
      "Resource": "arn:aws:es:eu-west-2:504007970043:domain/search/*"
    }
  ]
}
CONFIG
  snapshot_options {
    automated_snapshot_start_hour = 23
  }
  tags {
    Domain = "search"
  }
}
