import json
import os
import urllib3
import boto3
import urllib.parse
import urllib.request

http = urllib3.PoolManager()
s3 = boto3.client("s3")
sns = boto3.client("sns")

DISCORD_WEBHOOK_URL = os.environ.get("DISCORD_WEBHOOK_URL")
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")
TELEGRAM_BOT_TOKEN = os.environ.get("TELEGRAM_BOT_TOKEN")
TELEGRAM_CHAT_ID = os.environ.get("TELEGRAM_CHAT_ID")

def send_telegram_message(text):
    if not TELEGRAM_BOT_TOKEN or not TELEGRAM_CHAT_ID:
        print("Telegram env vars not set, skipping Telegram")
        return

    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"

    data = urllib.parse.urlencode({
        "chat_id": TELEGRAM_CHAT_ID,
        "text": text
    }).encode("utf-8")

    request = urllib.request.Request(url, data=data, method="POST")

    with urllib.request.urlopen(request, timeout=10) as response:
        return response.read().decode("utf-8")

def send_discord_message(data, bucket, key):
    if not DISCORD_WEBHOOK_URL:
        print("Discord webhook not set, skipping Discord")
        return

    payload = {
        "embeds": [
            {
                "title": "📥 New Submission Received",
                "color": 3447003,
                "fields": [
                    {
                        "name": "Name",
                        "value": data.get("name", "N/A"),
                        "inline": True
                    },
                    {
                        "name": "Message",
                        "value": data.get("message", "N/A"),
                        "inline": False
                    },
                    {
                        "name": "Bucket",
                        "value": bucket,
                        "inline": True
                    },
                    {
                        "name": "File",
                        "value": key,
                        "inline": False
                    }
                ]
            }
        ]
    }

    response = http.request(
        "POST",
        DISCORD_WEBHOOK_URL,
        body=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"}
    )

    print("Discord response:", response.status)

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))

    for record in event.get("Records", []):
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

        if SNS_TOPIC_ARN:
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject="New ChatOps Submission",
                Message=msg
            )

        send_discord_message(data, bucket, key)
        send_telegram_message(msg)

    return {
        "statusCode": 200,
        "body": "Done"
    }
