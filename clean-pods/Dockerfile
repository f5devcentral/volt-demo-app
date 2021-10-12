FROM alpine:3.6

RUN apk update && apk add curl

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.1/bin/linux/amd64/kubectl
RUN chmod u+x kubectl && mv kubectl /bin/kubectl

CMD ["/bin/kubectl", "delete", "pods", "--field-selector=status.phase=Failed"]