#!/bin/bash

# 初始化
echo "正在初始化容器..."
docker container prune -f
echo "容器初始化完成！"

echo "正在初始化镜像..."
docker image prune -a -f
echo "镜像初始化完成！"

# 遍历输入参数
for container_name in "$@"
do
    # 检查是否已经存在该容器
    if docker ps -a | grep -q $container_name; then
        echo "容器 $container_name 已存在，正在销毁..."
        docker stop $container_name
        docker rm $container_name
    fi

    # 创建容器
    if [ $container_name == "mysql" ]; then
        echo "正在创建容器 $container_name ..."
        if [ -z "$MYSQL_PASSWORD" ]; then
            if [[ "$@" == *"-eMYSQL_PASSWORD="* ]]; then
                MYSQL_PASSWORD=$(echo "$@" | sed -n 's/.*-eMYSQL_PASSWORD=\([^ ]*\).*/\1/p')
            else
                echo "未配置mysql密码，将使用默认密码：123456"
                MYSQL_PASSWORD=123456
            fi
        fi
        docker run -d --name $container_name -p 3306:3306 -e MYSQL_ROOT_PASSWORD=$MYSQL_PASSWORD mysql:8 --default-authentication-plugin=mysql_native_password
        echo "容器 $container_name 创建成功！"
    elif [ $container_name == "redis" ]; then
        echo "正在创建容器 $container_name ..."
        docker run -d --name $container_name redis
        echo "容器 $container_name 创建成功！"
    else
        echo "不支持的容器类型：$container_name"
    fi
done
