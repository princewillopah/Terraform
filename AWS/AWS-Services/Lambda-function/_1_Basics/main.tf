
# Create IAM role for Lambda
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Create IAM policy for Lambda
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Policy for Lambda function"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
EOF
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file= "lambda_function.py"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "example_lambda" {
  function_name = "example_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.outer_handler"  # Assuming your handler function is defined within lambda_function.py
  runtime       = "python3.11"
  filename      = "lambda_function.zip" # Use the output filename from the local_file resource
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256 


  
  environment {
    variables = {
      ENV = "PROD"  # Change this as needed
    }
  }
}
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
## Package the Lambda function code
# resource "local_file" "lambda_zip" {
#   content  = filebase64("${path.module}/lambda_function.py")
#   filename = "${path.module}/lambda_function.zip"
# }