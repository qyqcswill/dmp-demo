FROM maven:3.5.0-jdk-8-alpine

LABEL maintainer "misha.yang@daocloud.io"

WORKDIR /project
ADD . /project

RUN mvn package -Dmaven.test.skip=true


ENTRYPOINT java $JAVA_OPTS -jar target/eureka-server-0.0.1-SNAPSHOT.jar
