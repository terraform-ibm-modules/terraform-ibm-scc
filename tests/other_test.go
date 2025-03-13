package test

import (
	"math/rand"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const basicExampleDir = "examples/basic"
const advancedExampleDir = "examples/advanced"

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  basicExampleDir,
		Prefix:        "scc-bsc",
		ResourceGroup: resourceGroup,
		Region:        validRegions[rand.Intn(len(validRegions))],
		TerraformVars: map[string]interface{}{
			"access_tags": permanentResources["accessTags"],
		},
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunAdvancedExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: advancedExampleDir,
		Prefix:       "scc-adv",
		Region:       validRegions[rand.Intn(len(validRegions))],
		/*
		 To prevent clashes, comment out the 'ResourceGroup' input in the tests to create a unique resource group,
		 as only one instance of Event Notification (Lite) is allowed per resource group.
		*/
		//ResourceGroup: resourceGroup,
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
