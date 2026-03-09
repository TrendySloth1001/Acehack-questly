#!/bin/bash
set -e

GH_TOKEN=$(git credential-osxkeychain get <<< $'protocol=https\nhost=github.com\n' 2>/dev/null | grep password | cut -d= -f2)
REPO="TrendySloth1001/Acehack-questly"
TAG="v1.0.0"
APK_PATH="frontend/build/app/outputs/flutter-apk/app-release.apk"

echo "Creating release $TAG..."

RELEASE_RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $GH_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO/releases" \
  -d @- <<'EOF'
{
  "tag_name": "v1.0.0",
  "target_commitish": "main",
  "name": "Questly v1.0.0",
  "body": "## Questly v1.0.0 — Initial Release\n\nThe first public release of Questly, a Web3 bounty platform built on the Algorand blockchain.\n\n### Features\n- Location-based bounty discovery with interactive map\n- Algorand escrow-powered ALGO rewards\n- Google OAuth authentication\n- Custodial wallet management with testnet faucet\n- Proof-of-completion submission with photo uploads\n- Gamification with XP, levels, and Minecraft-themed ranks\n- Star rating and review system\n- Dispute resolution workflow\n\n### Downloads\n- **Android APK** — Download questly-v1.0.0.apk below\n\n### Live\n- Landing: https://questly.anskservices.com\n- API: https://apk.anskservices.com",
  "draft": false,
  "prerelease": false
}
EOF
)

echo "$RELEASE_RESPONSE" | python3 -c "import sys,json; r=json.load(sys.stdin); print('Release ID:', r.get('id','')); print('URL:', r.get('html_url','')); print('Upload URL:', r.get('upload_url',''))"

RELEASE_ID=$(echo "$RELEASE_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
UPLOAD_URL="https://uploads.github.com/repos/$REPO/releases/$RELEASE_ID/assets?name=questly-v1.0.0.apk"

echo ""
echo "Uploading APK ($APK_PATH)..."

curl -s -X POST \
  -H "Authorization: token $GH_TOKEN" \
  -H "Content-Type: application/vnd.android.package-archive" \
  --data-binary "@$APK_PATH" \
  "$UPLOAD_URL" | python3 -c "import sys,json; r=json.load(sys.stdin); print('Asset:', r.get('name','')); print('Size:', r.get('size',0)//1024//1024, 'MB'); print('Download URL:', r.get('browser_download_url',''))"

echo ""
echo "Done!"
