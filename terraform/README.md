# htx-terraform-interview
Date: 22 Jun 2022

## Specifications
Load Balancer can be configured in redundancy or blue-green deployment.

All resources are based on `Southeast Asia` region, with the following exception:

* Azure Cosmos DB
  * Priority 0: `US East`
  * Priority 1 (failover replica): `US Central`
  
Azure CosmosDB is used and based on MongoDB representation

Default network security are applied (no additional defined in terraform code)

## Usage Instructions

### Step 1
Prepare the following information: 
   * Subscription ID `subscription_id`
   * Container Version Number `container_version_num` (optional)
   
Preferably, the information to be stored in the same directory as this `README.md` file, as `terraform.tfvars` (file is not reflected in repository as it is in `.gitignore`)



### Step 2
Run `terraform init` 

If needed, run `terraform plan`.



### Step 3
Currently, there are two ways to demonstrate this application

* Redundancy (two of same containers)
* Blue-Green Deployment Transition (two different containers) - **current mode**

Within `main.tf` in the same directory, under the following resources: 
* `azurerm_container_group.backend_frontend_primary`, and
* `azurerm_container_group.backend_frontend_secondary`

interchange out the `image` attribute under the `container` block to reflect either redundancy or blue-green deployment.

```
...
    # image  = "habhabhabs/alex-interview:${var.container_version_num}" # for redundancy concept
    image  = "habhabhabs/alex-interview:1.0" # for blue-green deployment concept
...
```



### Step 4
Run `terraform apply`.

Estimated deployment time: ~30 minutes, with Azure Cosmos DB taking about 20 minutes for dual-region redundancy configuration.


### Step 5
Access the web interface via the terraform output `appgateway_lb_endpoint`

e.g. `http://40.65.181.193/`

Database entries can be referred to upon via the Azure Cosmos DB Data Explorer (as MongoDB representation)