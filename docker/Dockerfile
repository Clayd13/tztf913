FROM amazonlinux:2 as installer

COPY awscli-exe-linux-x86_64.zip .
RUN yum update -y \
  && yum install -y unzip \
  && unzip awscli-exe-linux-x86_64.zip \
  && ./aws/install --bin-dir /aws-cli-bin/


FROM amazonlinux:2
RUN yum update -y \
  && yum install -y httpd jq sudo \
  && yum clean all \
  && rm -rf /var/cache/yum
COPY --from=installer /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=installer /aws-cli-bin/ /usr/local/bin/

RUN sed -i -e 's/Listen 80/Listen 80\nServerName localhost/' /etc/httpd/conf/httpd.conf

WORKDIR script
COPY ecs-json-to-html.sh .


EXPOSE 80

CMD ./ecs-json-to-html.sh
