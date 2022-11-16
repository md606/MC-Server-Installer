#!/bin/sh

# 这是MapleSky网课期间写的脚本，相较于1.0.0版本，添加（修改）了以下功能：
# 1：新增fabric端一键开服
# 2：
# 3：
# 4：



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
echo -e "\033[36m|---------------------------------|\033[0m"
echo -e "\033[36m|---------MapleSky--MCSI----------|\033[0m"
echo -e "\033[36m|-----------一键开服--------------|\033[0m"
echo -e "\033[36m|----------版本：1.1.0------------|\033[0m"
echo -e "\033[36m|---------version 1.1.0-----------|\033[0m"
echo -e "\033[36m|---------------------------------|\033[0m"
echo "请输入服务端版本："
echo "示例:1.19.2"
echo "注意 目前仅支持正式版"
echo "Please Enter a version:"
echo "For example:1.19.2"
echo "Tips: Only the stable version is currently supported"
read -p ">>>" version;

# 是否使用fabric端
echo -e "\033[36m|---------------------------------|\033[0m"
echo -e "\033[36m是否使用fabric端（y/n）\033[0m"
echo -e "\033[36mEnable Fabric?(y/n)\033[0m"
read -p ">>>" enable_fabric;
case $enable_fabric in
   'y')
      mcdir="fabricmc"
      jar_name="fabric.jar"
		jar_path="${user}mc_server/fabricmc${version}/${jar_name}"
		;;
	'n')
      mcdir="mc"
		jar_name="server.jar"
		jar_path="${user}mc_server/mc${version}/${jar_name}"
		;;
	*)
      mcdir="mc"
		jar_name="server.jar"
		jar_path="${user}mc_server/mc${version}/${jar_name}"
		;;
esac

mkdir ${user}mc_server
mkdir ${user}mc_server/${mcdir}${version}
echo "---------------mkdir done!------------------"
cd ${user}mc_server/${mcdir}${version}
jdk="${user}mc_server/jdk-19.0.1/bin/java"
properties="${user}mc_server/${mcdir}${version}/server.properties"


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

FabricServer(){
	wget -O server.jar https://meta.fabricmc.net/v2/versions/loader/${version}/0.14.10/0.11.1/server/jar
}

# 首次开服
First_Run(){
   ${user}mc_server/jdk-19.0.1/bin/java -jar server.jar nogui
   # Rewrite eula.txt 同意eula协议
   sed -i "s/false/true/g" ./eula.txt
   # Open Online-Mode  是否开启正版验证
   echo -e "\033[36m---------------------------------\033[0m"
   echo -e "\033[36mOpen Online-Mode(y/n)\033[0m"
   echo -e "\033[36m是否开启正版验证(y/n)\033[0m"
   read -p ">>>" online;
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
   echo -e "\033[36mDone!\033[0m"
}

# 开已有的服
Run(){
   screen -R mc ${user}mc_server/jdk-19.0.1/bin/java -jar -Xms512M server.jar nogui
   echo -e "\033[36mDone!\033[0m"
}


# Main branch 主流程

if [ -f $jdk ] # Check JDK 检查JDK是否安装
then
   if [ -f $jar_path ] # Check server.jar 检查server.jar是否下载
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
# 祝：所有小白腐竹都能用上一键开服 o(*￣▽￣*)ブ