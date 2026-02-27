resource "aws_lb" "alb" {
  name               = "${local.nombre}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for s in aws_subnet.publicas : s.id]
  tags               = local.tags
}

resource "aws_lb_target_group" "tg_catalogo" {
  name        = "${local.nombre}-tg-cat"
  port        = 8001
  protocol    = "HTTP"
  vpc_id      = aws_vpc.principal.id
  target_type = "ip"
  health_check {
    path = "/salud"
  }
  tags = local.tags
}

resource "aws_lb_target_group" "tg_reservas" {
  name        = "${local.nombre}-tg-res"
  port        = 8002
  protocol    = "HTTP"
  vpc_id      = aws_vpc.principal.id
  target_type = "ip"
  health_check {
    path = "/salud"
  }
  tags = local.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "SeaBook ALB"
      status_code  = "200"
    }
  }

  tags = local.tags
}

resource "aws_lb_listener" "https" {
  count             = local.usa_https ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificado_acm_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "SeaBook ALB HTTPS"
      status_code  = "200"
    }
  }

  tags = local.tags
}

resource "aws_lb_listener_rule" "catalogo_http" {
  count        = local.usa_https ? 0 : 1
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_catalogo.arn
  }

  condition {
    path_pattern {
      values = ["/api/catalogo/*"]
    }
  }
}

resource "aws_lb_listener_rule" "reservas_http" {
  count        = local.usa_https ? 0 : 1
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_reservas.arn
  }

  condition {
    path_pattern {
      values = ["/api/reservas/*"]
    }
  }
}

resource "aws_lb_listener_rule" "catalogo_https" {
  count        = local.usa_https ? 1 : 0
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 10

  action {
    type = "authenticate-cognito"
    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.usuarios.arn
      user_pool_client_id = aws_cognito_user_pool_client.cliente.id
      user_pool_domain    = aws_cognito_user_pool_domain.dominio.domain
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_catalogo.arn
  }

  condition {
    path_pattern {
      values = ["/api/catalogo/*"]
    }
  }
}

resource "aws_lb_listener_rule" "reservas_https" {
  count        = local.usa_https ? 1 : 0
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 20

  action {
    type = "authenticate-cognito"
    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.usuarios.arn
      user_pool_client_id = aws_cognito_user_pool_client.cliente.id
      user_pool_domain    = aws_cognito_user_pool_domain.dominio.domain
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_reservas.arn
  }

  condition {
    path_pattern {
      values = ["/api/reservas/*"]
    }
  }
}