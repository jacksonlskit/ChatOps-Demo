resource "aws_sns_topic" "Chatdemo_sns" {
  name         = var.sns_topic_name
  display_name = "${var.project_name}-${var.environment}-sns-topic"

  tags = {
    Name        = "${var.project_name}-${var.environment}-sns"
    Project     = var.project_name
    Environment = var.environment
  }

}

