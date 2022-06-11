#!/bin/sh

# A Shell script of Raspberry

file="/root/mc_server/mc1.18.2/server.properties"
if [ -e $file ]
then
   cd /root/mc_server/mc1.18.2
   
   # Run Server
   screen -R mc /root/mc_server/mc1.18.2/jdk-18.0.1.1/bin/java -jar -Xms512M server.jar nogui

else
   apt-get -y install screen
   apt-get -y install wget
   apt-get -y install tar
   mkdir /root/mc_server && mkdir /root/mc_server/mc1.18.2 && cd /root/mc_server/mc1.18.2
   
   # Download server.jar and JDK18
   wget -O server.jar https://launcher.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar
   wget https://download.java.net/java/GA/jdk18.0.1.1/65ae32619e2f40f3a9af3af1851d6e19/2/GPL/openjdk-18.0.1.1_linux-aarch64_bin.tar.gz
   tar -zxvf openjdk-18.0.1.1_linux-aarch64_bin.tar.gz && rm -rf openjdk-18.0.1.1_linux-aarch64_bin.tar.gz
   
   # Run Server
   /root/mc_server/mc1.18.2/jdk-18.0.1.1/bin/java -jar server.jar nogui
   sed -i "s/false/true/g" ./eula.txt
   sed -i "s/online-mode=true/online-mode=false/g" ./server.properties
   sed -i "s/spawn-protection=16/spawn-protection=0/g" ./server.properties
   sed -i "s/difficulty=easy/difficulty=hard/g" ./server.properties
   screen -R mc /root/mc_server/mc1.18.2/jdk-18.0.1.1/bin/java -jar -Xms512M server.jar nogui
fi