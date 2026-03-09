#!/bin/bash
set -e

GH_TOKEN=$(git credential-osxkeychain get <<< $'protocol=https\nhost=github.com\n' 2>/dev/null | grep password | cut -d= -f2)
REPO="TrendySloth1001/Acehack-questly"
RELEASE_ID="294579699"
APK_PATH="frontend/build/app/outputs/flutter-apk/app-release.apk"
UPLOAD_URL="https://uploads.github.com/repos/$REPO/releases/$RELEASE_ID/assets?name=questly-v1.0.0.apk"

echo "Uploading APK ($(du -h "$APK_PATH" | cut -f1))..."

curl --progress-bar -X POST \
  -H "Authorization: token $GH_TOKEN" \
  -H "Content-Type: application/vnd.android.package-archive" \
  --data-binary "@$APK_PATH" \
  "$UPLOAD_URL" -o /tmp/upload_response.json

echo ""
python3 -c "import json; r=json.load(open('/tmp/upload_response.json')); print('Asset:', r.get('name','')); print('Size:', r.get('size',0)//1024//1024, 'MB'); print('Download:', r.get('browser_download_url',''))"
