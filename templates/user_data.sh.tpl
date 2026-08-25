#!/bin/bash
dnf update -y
dnf install -y python3 python3-pip
pip3 install flask boto3

mkdir -p /opt/chatops
cat > /opt/chatops/app.py <<'EOF'
from flask import Flask, request, render_template_string
import boto3
import json
from datetime import datetime
import uuid

app = Flask(__name__)
s3 = boto3.client("s3")
BUCKET_NAME = "${bucket_name}"

HTML_FORM = """
<!DOCTYPE html>
<html>
<head>
    <title>ChatOps Demo Form</title>
</head>
<body>
    <h2>Submit Your Input</h2>
    <form action="/submit" method="post">
        <label>Name:</label><br>
        <input type="text" name="name" required><br><br>
        <label>guess today 4d number:</label><br>
        <input type="number" name="message" required><br><br>
        <button type="submit">Submit</button>
    </form>
</body>
</html>
"""

@app.route("/", methods=["GET"])
def home():
    return render_template_string(HTML_FORM)

@app.route("/submit", methods=["POST"])
def submit():
    name = request.form["name"]
    message = request.form["message"]

    data = {
        "name": name,
        "message": message,
        "timestamp": datetime.utcnow().isoformat()
    }

    key = f"submissions/{datetime.utcnow().strftime('%Y%m%d-%H%M%S')}-{uuid.uuid4()}.json"

    s3.put_object(
        Bucket=BUCKET_NAME,
        Key=key,
        Body=json.dumps(data),
        ContentType="application/json"
    )

    return f"<h3>Thank you {name}! Your submission was saved.</h3>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

cat > /etc/systemd/system/chatops.service <<'EOF'
[Unit]
Description=ChatOps Flask App
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/chatops/app.py
WorkingDirectory=/opt/chatops
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable chatops
systemctl start chatops
