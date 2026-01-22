using './main.bicep'

// ============================================================================
// New VNet Deployment - AI Landing Zone (Demo Configuration)
// ============================================================================
// Deploys: AI Foundry, AI Search, Cosmos DB, Storage, Key Vault, 
//          Container Apps, Monitoring into new VNet.

// ============================================================================
// DEPLOYMENT TOGGLES
// ============================================================================
param deployToggles = {
  // AI Services
  aiFoundry: true                    // AI Foundry
  searchService: true                // AI Search
  groundingWithBingSearch: false
  
  // Data & Storage
  cosmosDb: true                     // Cosmos DB
  storageAccount: true               // Storage Account
  keyVault: true                     // Key Vault
  appConfig: false
  
  // Container & Compute
  containerEnv: true                 // Container Environment (required for Container Apps)
  containerRegistry: true            // Container Registry
  containerApps: true                // Container Apps
  buildVm: false
  jumpVm: false
  bastionHost: false
  
  // Monitoring
  logAnalytics: true                 // Log Analytics
  appInsights: true                  // Application Insights
  
  // Networking - create new VNet
  virtualNetwork: true               // true = create new VNet
  firewall: false                    // No firewall
  applicationGateway: false          // No App Gateway
  applicationGatewayPublicIp: false
  wafPolicy: false
  userDefinedRoutes: false
  apiManagement: false
  
  // NSGs - minimal set
  agentNsg: false
  peNsg: false
  applicationGatewayNsg: false
  apiManagementNsg: false
  acaEnvironmentNsg: false
  jumpboxNsg: false
  devopsBuildAgentsNsg: false
  bastionNsg: false
}

// ============================================================================
// VNET CONFIGURATION (not needed - template will create VNet)
// ============================================================================
param resourceIds = {}

// ============================================================================
// PLATFORM INTEGRATION
// ============================================================================
param flagPlatformLandingZone = false

