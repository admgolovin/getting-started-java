FROM  maven:3.6-jdk-8-slim
COPY helloworld-springboot/ ~/
WORKDIR ~/target/
RUN java -jar helloworld-springboot-0.0.1-SNAPSHOT.jar
