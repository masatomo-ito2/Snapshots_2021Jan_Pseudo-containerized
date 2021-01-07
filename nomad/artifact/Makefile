# GOOS: linux | darwin
GOOS      := linux
GOARCH    := amd64
ARTIFACT  := frontback.tgz
S3_BUCKET := hashicorpjp
S3_OBJECT := masa/${ARTIFACT}

all: deploy

frontend: frontend.go
	GOOS=${GOOS} GOARCH=${GOARCH} go build -o $@ $^

backend: backend.go
	GOOS=${GOOS} GOARCH=${GOARCH} go build -o $@ $^

${ARTIFACT}: frontend backend
	tar cfz ${ARTIFACT} $^

deploy: ${ARTIFACT}
	aws s3 cp $^ s3://${S3_BUCKET}/${S3_OBJECT}
	aws s3api put-object-acl --bucket ${S3_BUCKET} --key ${S3_OBJECT} --acl public-read

clean:
	rm -f frontend backend ${ARTIFACT}
