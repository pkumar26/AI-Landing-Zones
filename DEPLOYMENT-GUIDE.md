# AI Landing Zone - Deployment Guide

This guide documents the steps to deploy the Azure AI Landing Zone for a demo environment.

## Prerequisites

1. **Azure CLI** - Install from https://docs.microsoft.com/cli/azure/install-azure-cli
2. **Azure Developer CLI (azd)** - Install using:
   ```bash
   # Windows (using winget)
   winget install Microsoft.Azd
   
   # Or using PowerShell
   powershell -ex AllSigned -c "Invoke-RestMethod 'https://aka.ms/install-azd.ps1' | Invoke-Expression"
   ```
3. **Bicep CLI** - Usually included with Azure CLI, or install separately

## Supported Regions

> **Important:** Not all Azure regions support all AI Landing Zone features. Use one of these recommended regions:

| Region | AI Foundry | Zone Redundancy | Recommended |
|--------|------------|-----------------|-------------|
| **East US 2** | ✅ | ✅ | ✅ **Best Choice** |
| Sweden Central | ✅ | ✅ | ✅ |
| West Europe | ✅ | ✅ | ✅ |
| East US | ✅ | ✅ | ✅ |

**Regions to avoid:** West US 2 (not supported for AI Foundry), West US (limited model/zone support)

## Azure Government Deployment

The AI Landing Zone can also be deployed to **Azure Government** (sovereign cloud) with some modifications.

### Supported Azure Government Regions

| Region | AI Foundry | Azure OpenAI | AI Search | Zone Redundancy |
|--------|------------|--------------|-----------|-----------------|
| **usgovarizona** | ✅ | ✅ (GPT-4o, GPT-4o-mini, GPT-3.5-turbo, text-embedding-3-large) | ✅ | ❌ |
| **usgovvirginia** | ✅ | ✅ (GPT-4o, GPT-3.5-turbo, text-embedding-ada-002) | ✅ | ✅ |

### Limitations in Azure Government

- **No Zone Redundancy** in usgovarizona (only usgovvirginia)
- **No Serverless endpoints**
- **No Azure AI Agents**
- **No Fine-tuning**
- **Different portal URL**: `https://ai.azure.us/`

### Azure Government Deployment Steps

1. **Set Azure cloud to Government before login:**
   ```bash
   az cloud set --name AzureUSGovernment
   az login
   azd auth login
   ```

2. **Set the location to an Azure Government region:**
   ```bash
   azd env set AZURE_LOCATION "usgovarizona"
   # or
   azd env set AZURE_LOCATION "usgovvirginia"
   ```

3. **Disable zone redundancy** in the parameter file if deploying to usgovarizona.

4. **Deploy as normal:**
   ```bash
   azd up
   ```

> **Note:** For quota increases in Azure Government, submit a request at https://aka.ms/AOAIGovQuota

## Deployment Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/Azure/AI-Landing-Zones.git
cd AI-Landing-Zones
```

### Step 2: Authenticate with Azure

```bash
# Login to Azure CLI
az login

# Login to Azure Developer CLI
azd auth login

# Set your subscription
az account set --subscription "<your-subscription-id>"
```

### Step 3: Configure Parameters

Edit the parameter file `bicep/infra/main.bicepparam` with your configuration:

```bicep
using './main.bicep'

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
  containerEnv: true                 // Container Environment
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
  firewall: false                    
  applicationGateway: false          
  applicationGatewayPublicIp: false
  wafPolicy: false
  userDefinedRoutes: false
  apiManagement: false
  
  // NSGs
  agentNsg: false
  peNsg: false
  applicationGatewayNsg: false
  apiManagementNsg: false
  acaEnvironmentNsg: false
  jumpboxNsg: false
  devopsBuildAgentsNsg: false
  bastionNsg: false
}

param resourceIds = {}

param flagPlatformLandingZone = false
```

### Step 4: Initialize Azure Developer CLI Environment

```bash
cd AI-Landing-Zones

# Initialize a new environment
azd init -e <environment-name>

# Set required environment variables
azd env set AZURE_SUBSCRIPTION_ID "<your-subscription-id>"
azd env set AZURE_LOCATION "eastus2"
azd env set AZURE_RESOURCE_GROUP "<your-resource-group-name>"
```

### Step 5: Create Resource Group

```bash
az group create --name <your-resource-group-name> --location eastus2
```

### Step 6: Deploy

```bash
azd up
```

This command will:
1. Run the **preprovision script** (builds Template Specs from wrapper modules)
2. Deploy all infrastructure to Azure
3. Run the **postprovision script** (any post-deployment configuration)

## Troubleshooting

### Error: "Resource group could not be found"

The deployment cache may have old settings. Clean up and retry:

```bash
# Delete the cached deploy folder
rm -rf bicep/deploy

# Delete the azd environment
azd env delete <environment-name> --yes

# Re-initialize and redeploy
azd init -e <new-environment-name>
azd env set AZURE_SUBSCRIPTION_ID "<your-subscription-id>"
azd env set AZURE_LOCATION "eastus2"
azd env set AZURE_RESOURCE_GROUP "<your-resource-group-name>"
azd up
```

### Error: "SKU not supported in this region"

Switch to a supported region like **eastus2**:

```bash
rm -rf bicep/deploy
azd env set AZURE_LOCATION "eastus2"
az group create --name <new-rg-name> --location eastus2
azd env set AZURE_RESOURCE_GROUP "<new-rg-name>"
azd up
```

### Error: "Zone redundancy not supported"

This error occurs in regions without availability zone support. Use **eastus2**, **swedencentral**, or **westeurope**.

### Bicep Compilation Errors

The template uses Template Specs and experimental features. **Do not use** `az deployment group create` directly. Always use `azd up` which runs the preprovision script to build the required Template Specs.

## Resources Deployed

When using the demo configuration, the following resources are deployed:

| Resource | Description |
|----------|-------------|
| Virtual Network | With subnets for private endpoints, agents, and ACA |
| AI Foundry | Azure AI Foundry hub and project |
| AI Search | Azure Cognitive Search service |
| Cosmos DB | NoSQL database for AI applications |
| Storage Account | Blob storage for AI data |
| Key Vault | Secrets management |
| Container Apps Environment | Managed container hosting |
| Container Registry | Private container image registry |
| Log Analytics | Centralized logging |
| Application Insights | Application monitoring |

## Clean Up

To delete all deployed resources:

```bash
# Delete the resource group
az group delete --name <your-resource-group-name> --yes

# Delete the azd environment
azd env delete <environment-name> --yes
```

## Additional Resources

- [AI Landing Zones Documentation](https://azure.github.io/AI-Landing-Zones/bicep/how-to-use/)
- [Azure AI Foundry Documentation](https://learn.microsoft.com/azure/ai-studio/)
- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
