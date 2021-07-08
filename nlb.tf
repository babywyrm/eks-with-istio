resource "aws_lb" "ingress" {
    name               = var.cluster_name
    internal           = false
    load_balancer_type = "network"

    subnets            = [
        aws_subnet.private_subnet_1a.id,
        aws_subnet.private_subnet_1b.id,
        aws_subnet.private_subnet_1c.id
    ]

    enable_deletion_protection = false

    tags = {
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
}

resource "aws_lb_target_group" "http" {
  name     = format("%s-http", var.cluster_name)
  port     = 30080
  protocol = "TCP"
  vpc_id   = aws_vpc.cluster_vpc.id
}

resource "aws_lb_target_group" "https" {
  name     = format("%s-https", var.cluster_name)
  port     = 30443
  protocol = "TCP"
  vpc_id   = aws_vpc.cluster_vpc.id
}

resource "aws_lb_listener" "ingress_443" {
    load_balancer_arn = aws_lb.ingress.arn
    port              = "443"
    protocol          = "TCP"
    # protocol          = "TLS"
    # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
    # alpn_policy       = "HTTP2Preferred"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.https.arn
    }
}

resource "aws_lb_listener" "ingress_80" {
    load_balancer_arn = aws_lb.ingress.arn
    port              = "80"
    protocol          = "TCP"
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.http.arn
    }
}