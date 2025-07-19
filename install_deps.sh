#!/bin/bash

# --- 配置 ---
APK_DIRECTORY="./tool_apks"

# --- 脚本正文 ---
echo ">> 正在等待模拟器连接..."

# 等待至少一个设备被 adb 识别出来
until [[ ! -z "$(adb devices | grep -w 'device')" ]]; do
    echo -n "."
    sleep 1
done
echo "" # 换行

# 获取第一个可用设备的ID
# 这是解决“multiple devices/emulators”错误的关键！
DEVICE_ID=$(adb devices | grep -w "device" | awk '{print $1}' | head -n 1)

# 检查是否成功获取到设备ID
if [ -z "$DEVICE_ID" ]; then
    echo "错误: 未找到任何已连接的设备/模拟器。"
    exit 1
fi

echo "✅ 已锁定目标设备: $DEVICE_ID"

echo ">> 正在等待设备启动完成..."
# 在后续命令中明确指定设备ID
until adb -s "$DEVICE_ID" shell getprop sys.boot_completed | grep -m 1 "1"; do
    sleep 1
done

echo "✅ 设备已启动完成！"
echo ">> 开始安装依赖应用..."

# 检查 APK 目录是否存在
if [ ! -d "$APK_DIRECTORY" ]; then
    echo "错误: 目录 '$APK_DIRECTORY' 未找到。"
    exit 1
fi

# 遍历目录中所有的 .apk 文件并安装它们
for apk_file in "$APK_DIRECTORY"/*.apk; do
    if [ -f "$apk_file" ]; then
        echo "   -> 正在安装到 $DEVICE_ID: $apk_file"
        # 使用 -s <设备ID> 明确指定目标设备
        adb -s "$DEVICE_ID" install -r -g "$apk_file"
    fi
done

echo "✅ 所有依赖应用安装完成！"