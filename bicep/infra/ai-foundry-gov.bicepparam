using './ai-foundry-gov.bicep'

// ============================================================================
// AI Foundry - Azure Government Parameters
// ============================================================================

param baseName = 'aigovdemo'

param location = 'usgovarizona'

param tags = {
  Environment: 'Demo'
  Project: 'AI-Landing-Zone-Gov'
  DeployedBy: 'Bicep'
}

param vnetAddressPrefix = '10.0.0.0/16'

param peSubnetPrefix = '10.0.1.0/24'
