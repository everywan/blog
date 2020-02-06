NAME = xxx
PACKAGE = github.com/xxx/xxx-go
MAIN = $(PACKAGE)/main

DEFAULT_TAG = xxx-go:latest
DEFAULT_BUILD_TAG = 1.10-alpine
REMOTE_IMAGE = ccr.ccs.tencentyun.com/xxx/xxx-go

BUILD_FLAGS= -ldflags "-s -w" -mod vendor -v -o  $(NAME) entry/main.go

REMOTE_TAG = "$(shell git tag -l --sort=-v:refname|head -1)"
ifeq "$(MODE)" "dev"
	REMOTE_TAG = staging
endif

ifeq "$(REMOTE_TAG)" ""
	REMOTE_TAG = latest
endif
REMOTE_IMAGE_TAG = "$(REMOTE_IMAGE):$(REMOTE_TAG)"

ifeq "$(BUILD_TAG)" ""
	BUILD_TAG = $(DEFAULT_BUILD_TAG)
endif

CL_RED  = "\033[0;31m"
CL_BLUE = "\033[0;34m"
CL_GREEN = "\033[0;32m"
CL_ORANGE = "\033[0;33m"
CL_NONE = "\033[0m"

define color_out
	@echo $(1)$(2)$(CL_NONE)
endef

docker-build:
	@go mod vendor
	$(call color_out,$(CL_BLUE),"Building binary in docker ...")
	@docker run --rm -v "$(PWD)":/go/src/$(PACKAGE) \
		-w /go/src/$(PACKAGE) \
		golang:$(BUILD_TAG) \
		go build -v -o $(NAME) $(MAIN)
	$(call color_out,$(CL_GREEN),"Building binary ok")

docker: docker-build
	$(call color_out,$(CL_BLUE),"Building docker image ...")
	@docker build -t $(DEFAULT_TAG) .
	$(call color_out,$(CL_GREEN),"Building docker image ok")

push: docker
	@docker tag $(DEFAULT_TAG) $(REMOTE_IMAGE_TAG)
	$(call color_out,$(CL_BLUE),"Pushing image $(REMOTE_IMAGE_TAG) ...")
	@docker push $(REMOTE_IMAGE_TAG)
	$(call color_out,$(CL_ORANGE),"Done")

build:
	@go mod vendor
	@go build $(BUILD_FLAGS)

linux:
	@go mod vendor
	@GOOS=linux GOARCH=amd64 go build $(BUILD_FLAGS)

proto:
	# If build proto failed, make sure you have protoc installed and:
	# go get -u github.com/google/protobuf
	# go get -u github.com/golang/protobuf/protoc-gen-go
	# go install github.com/mwitkow/go-proto-validators/protoc-gen-govalidators
	# mkdir -p ${GOPATH}/src/github.com/googleapis && git clone git@github.com:googleapis/googleapis.git ${GOPATH}/src/github.com/googleapis/
	# Building proto for Golang
	@protoc \
		--proto_path=${GOPATH}/src \
		--proto_path=. \
		--go_out=plugins=grpc:$(PWD)/pb \
		--govalidators_out=$(PWD)/pb \
 		xxx.proto
	$(call color_out,$(CL_ORANGE),"Done")

.PHONY: all
all:
	build
