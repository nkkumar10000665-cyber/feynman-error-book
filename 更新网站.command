#!/bin/bash
# 费曼错题本Pro · 一键更新网页
# 双击运行：把 data.js 等所有改动提交并推送到 GitHub Pages

cd "$(dirname "$0")" || exit 1

DATE=$(date "+%Y-%m-%d %H:%M")

# 自动刷新数据文件里的更新时间
if [ -f data.js ]; then
  sed -i '' "s/\"updatedAt\": \"[^\"]*\"/\"updatedAt\": \"$DATE\"/" data.js
fi

git add -A

if git diff --cached --quiet; then
  echo ""
  echo "没有改动，网页已经是最新的。"
  echo ""
  read -n 1 -s -r -p "按任意键关闭…"
  exit 0
fi

git commit -m "更新：$DATE"

# 推送：强制 HTTP/1.1（规避 HTTP/2 断流），先直连，失败自动走本地代理（端口 7890）重试
if git -c http.version=HTTP/1.1 push; then
  echo ""
  echo "✅ 已推送（$DATE）。约 1 分钟后刷新网页即可看到新数据。"
  echo ""
  read -n 1 -s -r -p "按任意键关闭…"
  exit 0
fi

echo "直连失败，尝试走本地代理…"
if git -c http.version=HTTP/1.1 -c http.proxy=http://127.0.0.1:7890 push; then
  echo ""
  echo "✅ 已通过代理推送（$DATE）。约 1 分钟后刷新网页即可看到新数据。"
  echo ""
  read -n 1 -s -r -p "按任意键关闭…"
  exit 0
fi

echo ""
echo "❌ 推送失败。检查网络/代理是否开启，或在终端跑一次 git push 看报错。"
echo ""
read -n 1 -s -r -p "按任意键关闭…"
exit 1
