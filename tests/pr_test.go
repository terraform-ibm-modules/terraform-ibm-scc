// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"fmt"
	"log"
	"math/rand"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
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

// A test to pass existing SCC instances to complete example
func TestRunExistingResourcesInstances(t *testing.T) {
	t.Parallel()

	// ------------------------------------------------------------------------------------
	// Provision SCC instance and configure COS setting
	// ------------------------------------------------------------------------------------

	prefix := fmt.Sprintf("scc-existing-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := "./resources/existing-resources"
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))
	tags := common.GetTagsFromTravis()
	region := "us-south"

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix":        prefix,
			"region":        region,
			"resource_tags": tags,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
	} else {

		// ------------------------------------------------------------------------------------
		// Deploy complete example using existing SCC instance
		// ------------------------------------------------------------------------------------

		options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
			Testing:      t,
			TerraformDir: completeExampleDir,
			// Do not hard fail the test if the implicit destroy steps fail to allow a full destroy of resource to occur
			ImplicitRequired: false,
			Region:           region,
			TerraformVars: map[string]interface{}{
				"region":                    region,
				"resource_group":            terraform.Output(t, existingTerraformOptions, "resource_group_name"),
				"existing_scc_instance_crn": terraform.Output(t, existingTerraformOptions, "crn"),
			},
		})

		output, err := options.RunTestConsistency()
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")

	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (existing resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (existing resources)")
	}
}
