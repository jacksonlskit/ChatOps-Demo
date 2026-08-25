import json
import os
import urllib3
import boto3
import urllib.parse

http = urllib3.PoolManager()
s3 = boto3.client("s3")
sns = boto3.client("sns")

WEBHOOK_URL = os.environ["DISCORD_WEBHOOK_URL"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

def lambda_handler(event, context):
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

        obj = s3.get_object(Bucket=bucket, Key=key)
        content = obj["Body"].read().decode("utf-8")
        data = json.loads(content)

        msg = (
            f"New submission received\n"
            f"Name: {data.get('name', 'N/A')}\n"
            f"Message: {data.get('message', 'N/A')}\n"
            f"Bucket: {bucket}\n"
            f"File: {key}"
        )

        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="New ChatOps Submission",
            Message=msg
        )

        payload = {
            "embeds": [
                {
                    "title": "📥 New Submission Received",
                    "color": 3447003,
                    "fields": [
                        {"name": "Name", "value": data.get("name", "N/A"), "inline": True},
                        {"name": "Message", "value": data.get("message", "N/A"), "inline": False},
                        {"name": "Bucket", "value": bucket, "inline": True},
                        {"name": "File", "value": key, "inline": False}
                    ]
                }
            ]
        }

        http.request(
            "POST",
            WEBHOOK_URL,
            body=json.dumps(payload).encode("utf-8"),
            headers={"Content-Type": "application/json"}
        )

    return {"statusCode": 200, "body": "Done"}
