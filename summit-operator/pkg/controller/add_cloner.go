package controller

import (
	"github.com/example-inc/pkg/controller/cloner"
)

func init() {
	// AddToManagerFuncs is a list of functions to create controllers and add them to a manager.
	AddToManagerFuncs = append(AddToManagerFuncs, cloner.Add)
}
