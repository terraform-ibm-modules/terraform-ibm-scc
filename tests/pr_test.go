// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"log"
	"math/rand"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const resourceGroup = "geretain-test-resources" // Use existing resource group
const basicExampleDir = "examples/basic"
const completeExampleDir = "examples/complete"
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}

func TestMain(m *testing.M) {
	// Read the YAML file contents
	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func setupBasicExampleOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:            t,
		TerraformDir:       dir,
		Prefix:             prefix,
		ResourceGroup:      resourceGroup,
		BestRegionYAMLPath: "../common-dev-assets/common-go-assets/cloudinfo-region-scc-prefs.yaml",
		TerraformVars: map[string]interface{}{
			"access_tags": permanentResources["accessTags"],
		},
	})
	return options
}

func setupCompleteExampleOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	// Use a region that is supported for both Event Notifications and SCC
	validRegions := []string{
		"us-south",
		"eu-de",
		"eu-es",
	}
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
		Prefix:       prefix,
		Region:       validRegions[rand.Intn(len(validRegions))],
		/*
		 To prevent clashes, comment out the 'ResourceGroup' input in the tests to create a unique resource group,
		 as only one instance of Event Notification (Lite) is allowed per resource group.
		*/
		//ResourceGroup: resourceGroup,
	})
	return options
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()

	options := setupCompleteExampleOptions(t, "scc-cmp", completeExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupBasicExampleOptions(t, "scc", basicExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunCompleteExampleUpgrade(t *testing.T) {
	t.Parallel()

	options := setupCompleteExampleOptions(t, "scc-upg", completeExampleDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
