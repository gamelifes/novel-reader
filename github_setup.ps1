# GitHub 快速启动脚本
# 使用方法：在 PowerShell 中运行 .\github_setup.ps1

Write-Host "========================================" -ForegroundColor Green
Write-Host "  GitHub Actions APK 构建快速启动" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# 检查是否在项目根目录
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ 错误：请在 novel_reader 目录下运行此脚本" -ForegroundColor Red
    exit 1
}

# 步骤 1: 初始化 Git 仓库
Write-Host "📦 步骤 1/3: 初始化 Git 仓库..." -ForegroundColor Cyan
if (Test-Path ".git") {
    Write-Host "✅ Git 仓库已存在" -ForegroundColor Green
} else {
    git init
    Write-Host "✅ Git 仓库初始化完成" -ForegroundColor Green
}
Write-Host ""

# 步骤 2: 添加所有文件并提交
Write-Host "💾 步骤 2/3: 提交代码..." -ForegroundColor Cyan
git add .
git commit -m "Initial commit - Setup GitHub Actions for APK build"
Write-Host "✅ 代码提交完成" -ForegroundColor Green
Write-Host ""

# 步骤 3: 提示用户添加远程仓库
Write-Host "🚀 步骤 3/3: 推送到 GitHub..." -ForegroundColor Cyan
Write-Host ""
Write-Host "请按照以下步骤操作：" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 访问 https://github.com/new 创建新仓库" -ForegroundColor White
Write-Host "2. 仓库名建议：novel-reader" -ForegroundColor White
Write-Host "3. 不要勾选任何初始化选项" -ForegroundColor White
Write-Host "4. 创建后，将下面的命令复制到终端执行：" -ForegroundColor White
Write-Host ""
Write-Host "────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "git remote add origin https://github.com/你的用户名/你的仓库名.git" -ForegroundColor Cyan
Write-Host "git branch -M main" -ForegroundColor Cyan
Write-Host "git push -u origin main" -ForegroundColor Cyan
Write-Host "────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""
Write-Host "⚠️ 注意：将 '你的用户名' 和 '你的仓库名' 替换为实际值" -ForegroundColor Yellow
Write-Host ""

# 显示下一步操作
Write-Host "✅ 完成后，GitHub Actions 将自动开始构建 APK！" -ForegroundColor Green
Write-Host ""
Write-Host "📥 下载 APK 的步骤：" -ForegroundColor Cyan
Write-Host "   1. 访问你的 GitHub 仓库" -ForegroundColor White
Write-Host "   2. 点击 'Actions' 标签页" -ForegroundColor White
Write-Host "   3. 等待构建完成（约 3-5 分钟）" -ForegroundColor White
Write-Host "   4. 下载生成的 APK 文件" -ForegroundColor White
Write-Host ""
Write-Host "📖 详细说明请查看: GITHUB_ACTIONS_GUIDE.md" -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  准备就绪！祝你构建顺利 🎉" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
