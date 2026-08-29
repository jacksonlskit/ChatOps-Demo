#!/bin/bash
yum update -y
yum install -y python3 python3-pip
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
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f7fb;
            margin: 0;
            padding: 0;
        }
        .container {
            width: 420px;
            margin: 80px auto;
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            color: #333;
        }
        label {
            font-weight: bold;
            color: #444;
        }
        input[type="text"],
        input[type="number"] {
            width: 100%;
            padding: 10px;
            margin-top: 6px;
            margin-bottom: 18px;
            border: 1px solid #ccc;
            border-radius: 8px;
            box-sizing: border-box;
        }
        button {
            width: 100%;
            background-color: #0073bb;
            color: white;
            border: none;
            padding: 12px;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
        }
        button:hover {
            background-color: #005f99;
        }
        .footer {
            margin-top: 20px;
            text-align: center;
            color: #777;
            font-size: 13px;
        }
        .message-box {
            width: 420px;
            margin: 80px auto;
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            text-align: center;
        }
        .success {
            color: green;
        }
        .error {
            color: red;
        }
        a.button-link {
            display: inline-block;
            margin-top: 20px;
            text-decoration: none;
            background-color: #0073bb;
            color: white;
            padding: 10px 18px;
            border-radius: 8px;
        }
        a.button-link:hover {
            background-color: #005f99;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>ChatOps Demo Form</h2>
        <form action="/submit" method="post">
            <label>Name:</label>
            <input type="text" name="name" required>

            <label>Guess today's 4D number:</label>
            <input type="number" name="message" min="0" max="9999" required>

            <button type="submit">Submit</button>
        </form>
        <div class="footer">
            Your submission will be saved to S3
        </div>
    </div>
</body>
</html>
"""

@app.route("/", methods=["GET"])
def home():
    return render_template_string(HTML_FORM)

@app.route("/submit", methods=["POST"])
def submit():
    name = request.form["name"].strip()
    message = request.form["message"].strip()

    if not name:
        return render_template_string("""
        <div class="message-box">
            <h3 class="error">Error</h3>
            <p>Name cannot be empty.</p>
            <a class="button-link" href="/">Back to Main Page</a>
        </div>
        """)

    if not message.isdigit() or len(message) > 4:
        return render_template_string("""
        <div class="message-box">
            <h3 class="error">Invalid Input</h3>
            <p>Please enter a valid 4D number.</p>
            <a class="button-link" href="/">Back to Main Page</a>
        </div>
        """)

    data = {
        "name": name,
        "message": message.zfill(4),
        "timestamp": datetime.utcnow().isoformat()
    }

    key = f"submissions/{datetime.utcnow().strftime('%Y%m%d-%H%M%S')}-{uuid.uuid4()}.json"

    try:
        s3.put_object(
            Bucket=BUCKET_NAME,
            Key=key,
            Body=json.dumps(data),
            ContentType="application/json"
        )

        return render_template_string(f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Submission Successful</title>
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    background-color: #f4f7fb;
                    margin: 0;
                    padding: 0;
                }}
                .message-box {{
                    width: 420px;
                    margin: 80px auto;
                    background: white;
                    padding: 30px;
                    border-radius: 12px;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
                    text-align: center;
                }}
                .success {{
                    color: green;
                }}
                a.button-link {{
                    display: inline-block;
                    margin-top: 20px;
                    text-decoration: none;
                    background-color: #0073bb;
                    color: white;
                    padding: 10px 18px;
                    border-radius: 8px;
                }}
                a.button-link:hover {{
                    background-color: #005f99;
                }}
            </style>
        </head>
        <body>
            <div class="message-box">
                <h3 class="success">Thank you, {name}!</h3>
                <p>Your 4D number <strong>{message.zfill(4)}</strong> was saved successfully.</p>
                <a class="button-link" href="/">Back to Main Page</a>
            </div>
        </body>
        </html>
        """)
    except Exception as e:
        return render_template_string(f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Submission Failed</title>
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    background-color: #f4f7fb;
                    margin: 0;
                    padding: 0;
                }}
                .message-box {{
                    width: 420px;
                    margin: 80px auto;
                    background: white;
                    padding: 30px;
                    border-radius: 12px;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
                    text-align: center;
                }}
                .error {{
                    color: red;
                }}
                a.button-link {{
                    display: inline-block;
                    margin-top: 20px;
                    text-decoration: none;
                    background-color: #0073bb;
                    color: white;
                    padding: 10px 18px;
                    border-radius: 8px;
                }}
                a.button-link:hover {{
                    background-color: #005f99;
                }}
            </style>
        </head>
        <body>
            <div class="message-box">
                <h3 class="error">Submission Failed</h3>
                <p>Error: {str(e)}</p>
                <a class="button-link" href="/">Back to Main Page</a>
            </div>
        </body>
        </html>
        """)

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
