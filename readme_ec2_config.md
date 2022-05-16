#! /bin/bash

cd /usr/bin

# install java
sudo yum install java-1.8.0 -y

# download Apache Kafka.
sudo wget https://archive.apache.org/dist/kafka/2.2.1/kafka_2.12-2.2.1.tgz

# untar
sudo tar -xzf kafka_2.12-2.2.1.tgz

# tmp
sudo  mkdir /tmp

# get jvm path
# cd /usr/lib/jvm && ls

# auth
cd /usr/bin/kafka_2.12-2.2.1/bin


export jdk="java-1.8.0-openjdk-1.8.0.312.b07-1.amzn2.0.2.x86_64"

sudo cp /usr/lib/jvm/$jdk/jre/lib/security/cacerts /tmp/kafka.client.truststore.jks

# write client properties
sudo nano client.properties

```json
security.protocol=SSL
ssl.truststore.location=/tmp/kafka.client.truststore.jks

```