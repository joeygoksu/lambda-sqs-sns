locals {
  prefix = "griffin"
}

# Create an SNS topic
resource "aws_sns_topic" "journal_entry_topic" {
  name = "${local.prefix}-journal-entry-topic"
}

# Create an SQS queue
resource "aws_sqs_queue" "journal_entry_queue" {
  name = "${local.prefix}-journal-entry-queue"
}

# Create a Lambda function
resource "aws_lambda_function" "journal_entry_function" {
  filename         = "dist.zip"
  function_name    = "${local.prefix}-journal_entry_function"
  role             = aws_iam_role.iam_for_lambda.arn
  source_code_hash = filebase64sha256("dist.zip")
  handler          = "index.handler"

  depends_on = [
    aws_iam_role.iam_for_lambda
  ]

  layers = [
    "arn:aws:lambda:eu-west-1:043964854906:layer:griffin-lambda-layer:3"
  ]

  runtime = "nodejs16.x"

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.journal_entry_queue.id
    }
  }
}

/******************************************
 * SNS and SQS subscriptions
 *****************************************/

# Subscribe the SQS queue to lambda
resource "aws_sns_topic_subscription" "journal_entry_queue_subscription" {
  topic_arn = aws_sns_topic.journal_entry_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.journal_entry_function.arn
}

/******************************************
 * IAM role and policy
 *****************************************/

resource "aws_iam_role" "iam_for_lambda" {
  name = "${local.prefix}-iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${local.prefix}-lambda-logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

// iam policy to sqs for lambda
resource "aws_iam_policy" "lambda_sqs" {
  name        = "${local.prefix}-lambda-sqs"
  path        = "/"
  description = "IAM policy for SQS from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility",
        "sqs:DeleteMessage"
      ],
      "Resource": "${aws_sqs_queue.journal_entry_queue.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_sqs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_sqs.arn
}

// iam policy to sns for lambda
resource "aws_iam_policy" "lambda_sns" {
  name        = "${local.prefix}-lambda-sns"
  path        = "/"
  description = "IAM policy for SNS from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:Publish",
        "lambda:InvokeFunction"
      ],
      "Resource": "${aws_sns_topic.journal_entry_topic.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_sns" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_sns.arn
}

/******************************************
 * Permissions
 *****************************************/

# Create a Lambda permission to allow SNS to invoke the function
resource "aws_lambda_permission" "sns_invocation_permission" {
  statement_id  = "AllowSNSInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.journal_entry_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.journal_entry_topic.arn
}

// Grant lambda permission to access SQS to read messages
resource "aws_lambda_permission" "sqs_invocation_permission" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.journal_entry_function.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.journal_entry_queue.arn
}

/*****************************************/
