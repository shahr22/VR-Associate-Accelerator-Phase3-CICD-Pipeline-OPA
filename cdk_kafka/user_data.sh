#!/bin/bash
yum update -y
amazon-linux-extras install java-openjdk11 -y
wget https://downloads.apache.org/kafka/3.2.3/kafka_2.13-3.2.3.tgz
tar -xzf kafka_2.13-3.2.3.tgz
kafka_2.13-3.2.3/bin/zookeeper-server-start.sh -daemon kafka_2.13-3.2.3/config/zookeeper.properties
sleep 5s
kafka_2.13-3.2.3/bin/kafka-server-start.sh -daemon kafka_2.13-3.2.3/config/server.properties