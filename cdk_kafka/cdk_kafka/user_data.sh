#!/bin/bash
yum update -y 
amazon-linux-extras install java-openjdk11 -y 
wget https://downloads.apache.org/kafka/3.2.3/kafka_2.13-3.2.3.tgz   # Kafka download
tar -xzf kafka_2.13-3.2.3.tgz
kafka_2.13-3.2.3/bin/zookeeper-server-start.sh -daemon kafka_2.13-3.2.3/config/zookeeper.properties #start zookeeper in background
sleep 5s  # wait for zookeeper to finish
kafka_2.13-3.2.3/bin/kafka-server-start.sh -daemon kafka_2.13-3.2.3/config/server.properties # launch kafka