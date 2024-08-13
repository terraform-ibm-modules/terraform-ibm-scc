package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()

	options := setupCompleteExampleOptions(t, "scc-cmp", completeExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
