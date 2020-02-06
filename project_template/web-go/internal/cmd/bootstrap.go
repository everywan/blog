package cmd

import (
	"log"
)

type Bootstrap struct{}

func bootstrap(opts *Options) *Bootstrap {
	return &Bootstrap{}
}

func handleInitError(module string, err error) {
	if err == nil {
		return
	}
	log.Fatalf("init %s failed, err: %s", module, err)
}
