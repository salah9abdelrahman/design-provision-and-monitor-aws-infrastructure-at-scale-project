provider "aws" {
  region     = var.region
  access_key = ""
  secret_key = ""
}
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "function_logging_policy" {
  name   = "function-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role = aws_iam_role.iam_for_lambda.id
  policy_arn = aws_iam_policy.function_logging_policy.arn
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${var.greet_lambda}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}



data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${var.greet_lambda}.py"
  output_path = "${var.greet_lambda}.zip"
}


resource "aws_lambda_function" "greet_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "${var.greet_lambda}.zip"
  function_name = var.greet_lambda
  handler       = "greet_lambda.lambda_handler"
  role          = aws_iam_role.iam_for_lambda.arn

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.8"
  timeout = 10

  environment {
    variables = {
      greeting = "yoooooo!"
    }
  }

}