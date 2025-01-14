#
# Dockerfile for DynamoDB Local
#
# http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Tools.DynamoDBLocal.html
#
FROM openjdk:8-slim
MAINTAINER Bryan Talbot <bryan.talbot@ijji.com>
EXPOSE 8000
WORKDIR /dynamodb

ENV DDB_LOCAL_VERSION=2018-04-11 \
    DDB_LOCAL_SHA256=4afae454157256e3525df91b5ae2c6b6683ce05f92284e79335b2ac8e2e53762

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.docker.dockerfile="Dockerfile" \
      org.label-schema.license="MIT" \
      org.label-schema.name="Docker DynamoDb-Local" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-type="git" \
      org.label-schema.vcs-url="https://github.com/iJJi/docker-dynamodb-local" \
      org.label-schema.vendor="Ijji, inc." \
      org.label-schema.version=$DDB_LOCAL_VERSION

# Download and install the binaries to WORKDIR
RUN apt-get update && \
    apt-get install --yes wget && \
    wget -q -O dynamodb_local.tar.gz https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_${DDB_LOCAL_VERSION}.tar.gz && \
    echo "${DDB_LOCAL_SHA256}  dynamodb_local.tar.gz" | sha256sum -c - && \
    tar xzf dynamodb_local.tar.gz && \
    rm dynamodb_local.tar.gz && \
    apt-get clean

RUN mkdir -p /dynamodb_data && chown nobody:nogroup /dynamodb_data && chmod 0750 /dynamodb_data
RUN chmod ugo+rwx DynamoDBLocal.jar
RUN chmod -R ugo+rwx DynamoDBLocal_lib

# VOLUME to allow persistence / access of raw database files
#VOLUME /dynamodb_data
RUN pwd
RUN ls -la

ENTRYPOINT ["/usr/local/openjdk-8/bin/java", "-Djava.library.path=/dynamodb/DynamoDBLocal_lib", "-jar", "/dynamodb/DynamoDBLocal.jar"]
