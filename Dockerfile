FROM golang:1.10-alpine as build

RUN mkdir -p /go/src \
    && mkdir -p /go/bin \
    && mkdir -p /go/pkg

ENV GOPATH=/go
ENV PATH=$PATH:$GOPATH/bin

WORKDIR $GOPATH/src/resume-server
RUN apk update && apk add git
RUN go get -u github.com/golang/dep/cmd/dep
COPY Gopkg.* ./
RUN dep ensure -vendor-only
COPY . .
RUN CGO_ENABLED=0 go install -a std
RUN CGO_ENABLED=0 GOOS='linux' go build -a -ldflags '-extldflags "-static"' -installsuffix cgo -o server .


FROM alpine:latest
WORKDIR /app
RUN apk update \
    && apk add ca-certificates \
    && rm -rf /var/cache/apk/*
COPY --from=build /go/src/resume-server/server .
ENTRYPOINT [ "./server" ]
