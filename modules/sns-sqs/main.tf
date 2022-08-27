terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28.0"
    }
  }
}

resource "aws_sns_topic" "transactions_topic" {
  name                        = "transactions-topic.fifo"
  fifo_topic                  = true
  content_based_deduplication = true
}

resource "aws_sqs_queue" "transactions_accounts_queue" {
  name                        = "transactions-accounts-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  deduplication_scope         = "queue"
  fifo_throughput_limit       = "perQueue"

  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600
  max_message_size           = 262144
  delay_seconds              = 0
  receive_wait_time_seconds  = 0
}

resource "aws_sqs_queue_policy" "transactions_accounts_queue_policy" {
  queue_url = aws_sqs_queue.transactions_accounts_queue.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "sqspolicy",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "sqs:*"
        ],
        "Resource" : aws_sqs_queue.transactions_accounts_queue.arn
        "Condition" : {
          "ArnEquals" : {
            "aws:SourceArn" : aws_sns_topic.transactions_topic.arn
          }
        }
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          # "AWS": "arn:aws:iam::942169856926:role/EC2ForCodeDeployRole_transactions"
          "AWS" : "*"
        },
        "Action" : "sqs:*",
        "Resource" : aws_sqs_queue.transactions_accounts_queue.arn
      }
    ]
  })
}

resource "aws_sqs_queue" "transactions_discounts_queue" {
  name                        = "transactions_discounts_queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  deduplication_scope         = "queue"
  fifo_throughput_limit       = "perQueue"

  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600
  max_message_size           = 262144
  delay_seconds              = 0
  receive_wait_time_seconds  = 0
}

resource "aws_sqs_queue_policy" "transactions_discounts_queue_policy" {
  queue_url = aws_sqs_queue.transactions_discounts_queue.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "sqspolicy",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "sqs:*"
        ],
        "Resource" : aws_sqs_queue.transactions_discounts_queue.arn
        "Condition" : {
          "ArnEquals" : {
            "aws:SourceArn" : aws_sns_topic.transactions_topic.arn
          }
        }
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : "sqs:*",
        "Resource" : aws_sqs_queue.transactions_discounts_queue.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "transactions_accounts_queue_subscription" {
  topic_arn            = aws_sns_topic.transactions_topic.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.transactions_accounts_queue.arn
  raw_message_delivery = false
}

resource "aws_sns_topic_subscription" "transactions_discounts_queue_subscription" {
  topic_arn            = aws_sns_topic.transactions_topic.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.transactions_discounts_queue.arn
  raw_message_delivery = false
}