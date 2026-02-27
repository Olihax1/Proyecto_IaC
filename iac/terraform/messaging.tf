# --- Mensajería & Resiliencia: SNS FIFO + SQS FIFO + DLQ + Lambda ---
resource "aws_sns_topic" "reservas" {
  name                        = "${local.nombre}-reservas.fifo"
  fifo_topic                  = true
  content_based_deduplication = true
  tags                        = local.tags
}

resource "aws_sqs_queue" "dlq" {
  name                        = "${local.nombre}-dlq.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  tags                        = local.tags
}

resource "aws_sqs_queue" "fifo" {
  name                        = "${local.nombre}-reservas.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
  tags = local.tags
}

resource "aws_sns_topic_subscription" "a_sqs" {
  topic_arn = aws_sns_topic.reservas.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.fifo.arn
}

resource "aws_lambda_function" "compensacion" {
  function_name = "${local.nombre}-compensacion"
  role          = aws_iam_role.lambda.arn
  handler       = "handler.handler"
  runtime       = "python3.11"

  filename         = "${path.module}/paquetes/compensacion.zip"
  source_code_hash = filebase64sha256("${path.module}/paquetes/compensacion.zip")

  environment {
    variables = {
      NIVEL_LOG = "INFO"
    }
  }

  tracing_config {
    mode = "Active"
  }

  tags = local.tags
}

resource "aws_lambda_event_source_mapping" "sqs_a_lambda" {
  event_source_arn = aws_sqs_queue.fifo.arn
  function_name    = aws_lambda_function.compensacion.arn
  batch_size       = 10

  depends_on = [
    aws_iam_role_policy_attachment.lambda_sqs
  ]
}

resource "aws_sqs_queue_policy" "sqs" {
  queue_url = aws_sqs_queue.fifo.id
  policy    = data.aws_iam_policy_document.sqs_politica.json
}