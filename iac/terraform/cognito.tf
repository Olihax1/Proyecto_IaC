resource "aws_cognito_user_pool" "usuarios" {
  name = "${local.nombre}-usuarios"
  tags = local.tags
}

resource "aws_cognito_user_pool_client" "cliente" {
  name                                 = "${local.nombre}-cliente"
  user_pool_id                         = aws_cognito_user_pool.usuarios.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid"]
  supported_identity_providers         = ["COGNITO"]
  callback_urls                        = ["https://example.com/callback"]
  logout_urls                          = ["https://example.com/logout"]
}

resource "aws_cognito_user_pool_domain" "dominio" {
  domain       = "${local.nombre}-auth"
  user_pool_id = aws_cognito_user_pool.usuarios.id
}
