#!/bin/sh

# 这是MapleSky网课期间闲得发慌写的脚本，相较于0.1版本，添加（修改）了以下功能：
# 1：添加任意版本开服的功能，不再是单独的几个版本，也就是能长久使用了
# 2：server.jar的下载地址从原先的Mojang源，更换成了bmclapi2.bangbang93.com，特别鸣谢bangbang93的镜像源！
# 3：自动识别应下载aarch64的JDK还是x64的JDK，更新JDK版本为19
# 4：新增对x64架构cpu的支持，对不支持的架构直接退出
# 5：增加、修改了一些注释
# 6：执行开服命令后提示"Done!"
# 7：自动识别包管理器，并对不支持的包管理器直接退出
# 8：自动识别当前用户，并默认在用户目录下开服


# Check System & Downloads Packs  检查系统 & 下载必要的包
if `apt`
then
   apt-get -y install screen
   apt-get -y install wget
   apt-get -y install tar
else
   yum -y install screen
   yum -y install wget
   yum -y install tar
fi


# Check Processor Architecture 检查处理器架构
PA=`uname -m`
if PA='x86_64'
then
   PA='x64'
elif PA='aarch64'
then 
   PA='aarch64'
elif PA='armv8l'
then
   PA='aarch64'
else
   echo "This structure is not supported, exiting..."
   echo "暂不支持此架构，即将退出..."
   exit 1
fi


# 获取当前用户的主目录
user=`whoami`
if user="root"
then
   user="/root/"
else
   user="/home/${user}/"
fi


# Select Version选择版本
echo "---------------------------------"
echo "------MapleSky--一键开服---------"
echo "---------------------------------"
echo "请输入服务端版本："
echo "示例:1.19.2"
echo "注意 目前仅保证1.16及以上版本可用"
echo "Please Enter a version:"
echo "For example:1.19.2"
echo "Tips: Only the stable version is currently supported"
read -p "> " version;

properties="/root/mc_server/mc${version}/server.properties"
mkdir ${user}mc_server && mkdir ${user}mc_server/mc${version}
cd ${user}mc_server/mc${version}
jdk="${user}mc_server/jdk-19.0.1/bin/java"
properties="${user}mc_server/mc${version}/server.properties"
jar="${user}mc_server/mc${version}/server.jar"


# Functions函数

# Download JDK 下载JDK
JDK(){
   wget https://download.java.net/java/GA/jdk19.0.1/afdd2e245b014143b62ccb916125e3ce/10/GPL/openjdk-19.0.1_linux-${PA}_bin.tar.gz
   tar -zxvf openjdk-19.0.1_linux-${PA}_bin.tar.gz -C ${user}mc_server/ && rm -rf openjdk-19.0.1_linux-${PA}_bin.tar.gz
}

# Download server.jar 下载server.jar
Server(){
wget -O server.jar https://bmclapi2.bangbang93.com/version/${version}/server
}

# 首次开服
First_Run(){
   ${user}mc_server/jdk-19.0.1/bin/java -jar server.jar nogui
   # Rewrite eula.txt 同意eula协议
   sed -i "s/false/true/g" ./eula.txt
   # Open Online-Mode  是否开启正版验证
   echo "Open Online-Mode(y/n)"
   echo "是否开启正版验证(y/n)"
   read -p ">" online;
   case $online in
      'y')
         sed -i "s/online-mode=true/online-mode=true/g" ./server.properties
         online='true'
         ;;
      'n')
         sed -i "s/online-mode=true/online-mode=false/g" ./server.properties
         online='false'
         ;;
      *)
         sed -i "s/online-mode=true/online-mode=false/g" ./server.properties
         online='false'
         ;;
   esac
   # Rewrite difficulty&spawn-protection  修改难度和出生点保护距离
   sed -i "s/spawn-protection=16/spawn-protection=0/g" ./server.properties
   sed -i "s/difficulty=easy/difficulty=hard/g" ./server.properties
   screen -R mc ${user}mc_server/jdk-19.0.1/bin/java -jar -Xms512M server.jar nogui
   echo "Now, online-mode is ${online}"
   echo "正版验证为：${online}"
   echo "Done!"
}

# 开已有的服
Run(){
   screen -R mc ${user}mc_server/jdk-19.0.1/bin/java -jar -Xms512M server.jar nogui
   echo "Done!"
}


# Main branch 主流程

if [ -f $jdk ] # Check JDK 检查JDK是否安装
then
   if [ -f $jar ] # Check server.jar 检查server.jar是否下载
   then
      if [ -f $properties ] # Check if it has already been run once 检查是否运行过此程序
      then
         Run # Run Server 运行服务器
      else
         First_Run
      fi
   else
      Server
      First_Run
   fi
else
   JDK
   Server
   First_Run
fi

# Powered By MapleSky
# 此脚本由 MapleSKy 匠心打造(bushi