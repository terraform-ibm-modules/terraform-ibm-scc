// Tests in this file are run in the PR pipeline
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
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const resourceGroup = "geretain-test-resources"
const fullyConfigFlavorDir = "solutions/fully-configurable"
const secEnforcedDir = "solutions/security-enforced"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

// Combined list of supported SCC and EN regions
var validRegions = []string{
	"us-south",
	"eu-de",
	"eu-es",
}

var permanentResources map[string]interface{}

// Common variables re-used across tests
var preReqDir = "./resources/prereq-resources"
var customIntegrations = []map[string]interface{}{{"provider_name": "Caveonix", "integration_name": "caveonix-integration"}}
var scopeKey = "all"

// NOTE: Currently scope is hard coded to GoldenEye Dev account
var scopes = map[string]interface{}{scopeKey: map[string]interface{}{"name": "Full account", "description": "Created by SCC DA test", "environment": "ibm-cloud", "properties": map[string]interface{}{"scope_id": "abac0df06b644a9cabc6e44f55b3880e", "scope_type": "account"}}}
var attachments = []map[string]interface{}{{"profile_name": "SOC 2", "profile_version": "latest", "attachment_name": "SOC 2", "attachment_description": "Created by SCC DA test", "attachment_schedule": "none", "scope_key_references": []string{scopeKey}, "notifications": map[string]interface{}{"enabled": "false"}}}

func TestMain(m *testing.M) {
	// Read the YAML file contents
	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

// Test the fully-configurable DA with defaults (no KMS encryption on bucket)
func TestFullyConfigurable(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.Intn(len(validRegions))]

	// ------------------------------------------------------------------------------------
	// Provision COS, Sysdig, WP and EN first
	// ------------------------------------------------------------------------------------

	prefix := fmt.Sprintf("scc-da-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := preReqDir
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))
	tags := common.GetTagsFromTravis()

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
		assert.True(t, existErr == nil, "Init and Apply of pre-req resources failed in TestFullyConfigurable test")
	} else {
		// ------------------------------------------------------------------------------------
		// Deploy DA
		// ------------------------------------------------------------------------------------
		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			Region:  region,
			Prefix:  prefix,
			TarIncludePatterns: []string{
				"*.tf",
				"modules/*/*.tf",
				fullyConfigFlavorDir + "/*.tf",
			},
			TemplateFolder:         fullyConfigFlavorDir,
			Tags:                   []string{"scc-da-test"},
			DeleteWorkspaceOnFail:  false,
			WaitJobCompleteMinutes: 60,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "existing_resource_group_name", Value: terraform.Output(t, existingTerraformOptions, "resource_group_name"), DataType: "string"},
			{Name: "scc_region", Value: terraform.Output(t, existingTerraformOptions, "region"), DataType: "string"},
			{Name: "scc_instance_resource_tags", Value: options.Tags, DataType: "list(string)"},
			{Name: "scc_instance_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
			{Name: "scc_cos_bucket_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
			{Name: "prefix", Value: terraform.Output(t, existingTerraformOptions, "prefix"), DataType: "string"},
			{Name: "existing_cos_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "cos_crn"), DataType: "string"},
			{Name: "existing_scc_workload_protection_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "wp_crn"), DataType: "string"},
			{Name: "existing_event_notifications_crn", Value: terraform.Output(t, existingTerraformOptions, "en_crn"), DataType: "string"},
			{Name: "event_notifications_source_name", Value: terraform.Output(t, existingTerraformOptions, "prefix"), DataType: "string"},
			{Name: "existing_monitoring_crn", Value: terraform.Output(t, existingTerraformOptions, "monitoring_crn"), DataType: "string"},
			{Name: "custom_integrations", Value: customIntegrations, DataType: "list(object)"},
			{Name: "scopes", Value: scopes, DataType: "map(object)"},
			{Name: "attachments", Value: attachments, DataType: "list(object)"},
		}

		err := options.RunSchematicTest()
		assert.Nil(t, err, "This should not have errored")
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (prereq resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (prereq resources)")
	}
}

// Test the fully-configurable DA using existing KMS key
func TestExistingKeyFullyConfigurable(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.Intn(len(validRegions))]

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Region:  region,
		Prefix:  "scc-da-exist-key",
		TarIncludePatterns: []string{
			"*.tf",
			"modules/*/*.tf",
			fullyConfigFlavorDir + "/*.tf",
		},
		TemplateFolder:         fullyConfigFlavorDir,
		Tags:                   []string{"scc-da-test"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
		{Name: "scc_region", Value: options.Region, DataType: "string"},
		{Name: "scc_instance_resource_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_cos_instance_crn", Value: permanentResources["general_test_storage_cos_instance_crn"], DataType: "string"},
		{Name: "existing_cos_instance_crn", Value: permanentResources["hpcs_south_root_key_crn"], DataType: "string"},
		{Name: "kms_encryption_enabled_bucket", Value: true, DataType: "bool"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

// Test the security-enforced DA with defaults (pass KMS instance details and create new key)
func TestSecurityEnforced(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.Intn(len(validRegions))]

	// ------------------------------------------------------------------------------------
	// Provision COS, Sysdig, WP and EN first
	// ------------------------------------------------------------------------------------

	prefix := fmt.Sprintf("scc-da-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := preReqDir
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))
	tags := common.GetTagsFromTravis()

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
		assert.True(t, existErr == nil, "Init and Apply of pre-req resources failed in TestFullyConfigurable test")
	} else {
		// ------------------------------------------------------------------------------------
		// Deploy DA
		// ------------------------------------------------------------------------------------
		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			Region:  region,
			Prefix:  prefix,
			TarIncludePatterns: []string{
				"*.tf",
				"modules/*/*.tf",
				fullyConfigFlavorDir + "/*.tf",
				secEnforcedDir + "/*.tf",
			},
			TemplateFolder:         secEnforcedDir,
			Tags:                   []string{"scc-da-test"},
			DeleteWorkspaceOnFail:  false,
			WaitJobCompleteMinutes: 60,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "existing_resource_group_name", Value: terraform.Output(t, existingTerraformOptions, "resource_group_name"), DataType: "string"},
			{Name: "scc_region", Value: terraform.Output(t, existingTerraformOptions, "region"), DataType: "string"},
			{Name: "scc_instance_resource_tags", Value: options.Tags, DataType: "list(string)"},
			{Name: "scc_instance_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
			{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
			{Name: "scc_cos_bucket_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
			{Name: "prefix", Value: terraform.Output(t, existingTerraformOptions, "prefix"), DataType: "string"},
			{Name: "existing_cos_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "cos_crn"), DataType: "string"},
			{Name: "existing_scc_workload_protection_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "wp_crn"), DataType: "string"},
			{Name: "existing_event_notifications_crn", Value: terraform.Output(t, existingTerraformOptions, "en_crn"), DataType: "string"},
			{Name: "event_notifications_source_name", Value: terraform.Output(t, existingTerraformOptions, "prefix"), DataType: "string"},
			{Name: "existing_monitoring_crn", Value: terraform.Output(t, existingTerraformOptions, "monitoring_crn"), DataType: "string"},
			{Name: "custom_integrations", Value: customIntegrations, DataType: "list(object)"},
			{Name: "scopes", Value: scopes, DataType: "map(object)"},
			{Name: "attachments", Value: attachments, DataType: "list(object)"},
		}

		err := options.RunSchematicTest()
		assert.Nil(t, err, "This should not have errored")
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (prereq resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (prereq resources)")
	}
}

// Run upgrade test on security-enforced variation
func TestUpgradeSecurityEnforced(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.Intn(len(validRegions))]

	// ------------------------------------------------------------------------------------
	// Provision COS, Sysdig, WP and EN first
	// ------------------------------------------------------------------------------------

	prefix := fmt.Sprintf("scc-da-upg-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := preReqDir
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))
	tags := common.GetTagsFromTravis()

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
		assert.True(t, existErr == nil, "Init and Apply of pre-req resources failed in TestFullyConfigurableUpgrade test")
	} else {
		// ------------------------------------------------------------------------------------
		// Deploy DA
		// ------------------------------------------------------------------------------------
		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			Region:  region,
			Prefix:  prefix,
			TarIncludePatterns: []string{
				"*.tf",
				"modules/*/*.tf",
				fullyConfigFlavorDir + "/*.tf",
			},
			TemplateFolder:         fullyConfigFlavorDir,
			Tags:                   []string{"scc-da-upg-test"},
			DeleteWorkspaceOnFail:  false,
			WaitJobCompleteMinutes: 60,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "existing_resource_group_name", Value: terraform.Output(t, existingTerraformOptions, "resource_group_name"), DataType: "string"},
			{Name: "scc_region", Value: terraform.Output(t, existingTerraformOptions, "region"), DataType: "string"},
			{Name: "scc_instance_resource_tags", Value: options.Tags, DataType: "list(string)"},
			{Name: "scc_instance_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
			{Name: "scc_cos_bucket_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
			{Name: "prefix", Value: terraform.Output(t, existingTerraformOptions, "prefix"), DataType: "string"},
			{Name: "existing_cos_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "cos_crn"), DataType: "string"},
			{Name: "existing_scc_workload_protection_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "wp_crn"), DataType: "string"},
			{Name: "existing_event_notifications_crn", Value: terraform.Output(t, existingTerraformOptions, "en_crn"), DataType: "string"},
			{Name: "event_notifications_source_name", Value: terraform.Output(t, existingTerraformOptions, "prefix"), DataType: "string"},
			{Name: "existing_monitoring_crn", Value: terraform.Output(t, existingTerraformOptions, "monitoring_crn"), DataType: "string"},
			{Name: "custom_integrations", Value: customIntegrations, DataType: "list(object)"},
			{Name: "scopes", Value: scopes, DataType: "map(object)"},
			{Name: "attachments", Value: attachments, DataType: "list(object)"},
		}

		err := options.RunSchematicUpgradeTest()
		if !options.UpgradeTestSkipped {
			assert.Nil(t, err, "This should not have errored")
		}
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (prereq resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (prereq resources)")
	}
}

// A test to pass existing resources to the Fully configurable DA variation
func TestExistingResourcesFullyConfigurable(t *testing.T) {
	t.Parallel()
	// ------------------------------------------------------------------------------------
	// Provision SCC, and WP first
	// ------------------------------------------------------------------------------------

	prefix := fmt.Sprintf("scc-exist-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := "./resources/existing-resources-test"
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
		// Deploy DA passing existing SCC instance and WP instance
		// ------------------------------------------------------------------------------------
		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			Region:  region,
			Prefix:  prefix,
			TarIncludePatterns: []string{
				"*.tf",
				"modules/*/*.tf",
				fullyConfigFlavorDir + "/*.tf",
			},
			TemplateFolder:         fullyConfigFlavorDir,
			Tags:                   []string{"scc-da-test"},
			DeleteWorkspaceOnFail:  false,
			WaitJobCompleteMinutes: 60,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "existing_resource_group_name", Value: terraform.Output(t, existingTerraformOptions, "resource_group_name"), DataType: "string"},
			{Name: "scc_region", Value: terraform.Output(t, existingTerraformOptions, "region"), DataType: "string"},
			{Name: "scc_instance_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
			{Name: "prefix", Value: terraform.Output(t, existingTerraformOptions, "prefix"), DataType: "string"},
			{Name: "existing_scc_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "scc_crn"), DataType: "string"},
			{Name: "existing_scc_workload_protection_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "wp_crn"), DataType: "string"},
			{Name: "custom_integrations", Value: customIntegrations, DataType: "list(object)"},
			{Name: "scopes", Value: scopes, DataType: "map(object)"},
			{Name: "attachments", Value: attachments, DataType: "list(object)"},
		}

		err := options.RunSchematicTest()
		assert.Nil(t, err, "This should not have errored")

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
