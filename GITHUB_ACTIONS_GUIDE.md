# GitHub Actions 自动构建 APK 指南

## 📋 前置要求

1. 拥有 GitHub 账号
2. 代码推送到 GitHub 仓库

## 🚀 快速开始

### 步骤 1: 初始化 Git 仓库

在 `novel_reader` 目录下运行：

```bash
cd novel_reader
git init
git add .
git commit -m "Initial commit"
```

### 步骤 2: 创建 GitHub 仓库

1. 访问 https://github.com/new
2. 创建一个新仓库（例如：novel-reader）
3. **不要**初始化 README、.gitignore 或 LICENSE
4. 点击创建后，GitHub 会显示推送命令

### 步骤 3: 推送代码到 GitHub

```bash
# 添加远程仓库（替换为你的仓库地址）
git remote add origin https://github.com/你的用户名/novel-reader.git

# 推送代码
git branch -M main
git push -u origin main
```

## 🎯 自动构建

GitHub Actions 会在以下情况自动构建 APK：

### 1️⃣ 推送代码时自动触发
```bash
git push origin main
```
推送到 `main`、`master` 或 `develop` 分支时，自动构建 Release 版本的 APK。

### 2️⃣ 手动触发构建

1. 访问你的 GitHub 仓库
2. 点击 `Actions` 标签页
3. 选择 `Build Android APK` workflow
4. 点击 `Run workflow` 按钮
5. 选择 Release 或 Debug 版本
6. 点击 `Run workflow` 开始构建

## 📥 下载构建的 APK

### 方法 1: 从 Actions 页面下载

1. 访问仓库的 `Actions` 标签页
2. 点击最近的构建记录
3. 滚动到 `Artifacts` 部分
4. 下载以下文件之一：
   - **app-release** (发布版本，性能优化，体积小)
   - **app-debug** (调试版本，可以调试，体积大)

### 方法 2: 从构建摘要下载

1. 访问 Actions 标签页
2. 点击最近的构建记录
3. 点击构建任务（如 `Build`）
4. 在页面底部找到 `Artifacts` 部分
5. 点击下载文件

## 📱 安装 APK 到手机

### Android 方法
```bash
# 通过 ADB 安装
adb install build/app/outputs/flutter-apk/app-release.apk

# 或者直接通过手机文件管理器打开 APK 文件安装
```

## 🔧 自定义构建配置

### 修改应用签名（可选）

如果需要正式发布，需要配置签名密钥：

1. **在 GitHub 中添加 Secrets**：
   - 访问仓库设置 → Secrets and variables → Actions
   - 添加以下 Secrets：
     - `KEYSTORE_FILE`: Base64 编码的 keystore 文件
     - `KEYSTORE_PASSWORD`: keystore 密码
     - `KEY_ALIAS`: 密钥别名
     - `KEY_PASSWORD`: 密钥密码

2. **更新 build.gradle 配置**：
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.create("release")
    }
}

signingConfigs {
    create("release") {
        storeFile = file("keystore.jks")
        storePassword = System.getenv("KEYSTORE_PASSWORD")
        keyAlias = System.getenv("KEY_ALIAS")
        keyPassword = System.getenv("KEY_PASSWORD")
    }
}
```

3. **更新 workflow 文件**：
在构建步骤之前添加：
```yaml
- name: Decode Keystore
  run: echo ${{ secrets.KEYSTORE_FILE }} | base64 -d > android/app/keystore.jks
```

### 修改应用信息

编辑 `pubspec.yaml` 修改应用版本：
```yaml
version: 1.0.0+1  # 版本号+构建号
```

编辑 `android/app/build.gradle` 修改包名：
```kotlin
applicationId = "com.yourcompany.novel_reader"
```

## 📊 查看构建状态

构建状态会显示在：
- 仓库主页的 workflow 徽章
- Pull Request 的检查状态
- Commits 列表的状态图标

## 🐛 调试构建失败

如果构建失败：

1. 查看 Actions 页面的详细日志
2. 常见问题：
   - 依赖冲突 → 运行 `flutter pub upgrade`
   - 代码分析错误 → 运行 `flutter analyze` 查看详情
   - SDK 版本问题 → 修改 workflow 中的 flutter-version

## 🔄 定期构建

可以设置定时构建：

编辑 `.github/workflows/build-apk.yml`，添加：
```yaml
on:
  schedule:
    - cron: '0 0 * * 0'  # 每周日凌晨构建
```

## 💡 小贴士

- ✅ APK 文件会在 GitHub 上保存 30 天
- ✅ 每次推送都会自动构建
- ✅ 无需本地安装 Android SDK
- ✅ 完全免费使用
- 📦 构建时间通常 2-5 分钟

## 📞 获取帮助

遇到问题？
- 查看 GitHub Actions 文档：https://docs.github.com/en/actions
- 查看 Flutter 构建文档：https://flutter.dev/docs/deployment/android

---

## 🎉 完成！

现在你可以：
1. 推送代码到 GitHub
2. 等待自动构建完成
3. 下载生成的 APK 文件
4. 安装到手机测试

祝你构建顺利！🚀
