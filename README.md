# Terraform with multiple Azure Key Vaults

Terraform with multiple Azure Key Vaults to check paging behavior

Terraform version

```bash
Terraform v1.9.7
on linux_amd64
+ provider registry.terraform.io/hashicorp/azurerm v3.109.0
```

Same behavior with Terraform version 1.6.4

Configure Terraform logging

```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
```

Create 250 Key Vaults so that [/resources?filter= resourceType eq 'Microsoft.KeyVault/vaults'](https://learn.microsoft.com/en-us/rest/api/resources/resources/list?view=rest-resources-2021-04-01) API call returns multiple pages. It is not enough to create only 40 Key Vaults since paging size is not deterministic.

```bash
cd create-keyvaults-region-x

terraform init
terraform plan
terraform apply
```

Count Key Vaults in a subscription on a single page

```bash
# Check page size of the default API call that Terraform is using
az rest --method GET --uri "/subscriptions/1412f248-f41c-4c92-be6c-28f2700d1037/resources?%24filter=resourceType+eq+%27Microsoft.KeyVault%2Fvaults%27&api-version=2015-11-01" -o json | jq '.value | length'

# Look on the 2nd page to find which Key Vaults are not on the 1st page
az rest --method GET --uri "https://management.azure.com/subscriptions/1412f248-f41c-4c92-be6c-28f2700d1037/resources?%24filter=resourceType+eq+%27Microsoft.KeyVault%2fvaults%27&api-version=2015-11-01&%24skiptoken=rc3BCsIgAADQf%2fHcwWRdhG6jcswJ5Vp6ExLmnA7UUTL693YIonvXd3kL8PqZauNtBHgBao4pqNEorWICGOhczfLWQ94dskLXTIbJUEQK2bU7gURiR1rIC4SsrEzNeyedSA0XD1rareQtatzZEQ%2f34LX5RsyfpvG%2bdh%2bkKlgd1u1nx%2f%2b73w%3d%3d" -o json | jq

# Confirm the key vaults are not on the 1st page
az rest --method GET --uri "/subscriptions/1412f248-f41c-4c92-be6c-28f2700d1037/resources?%24filter=resourceType+eq+%27Microsoft.KeyVault%2Fvaults%27&api-version=2015-11-01" -o json | grep c-78
```

Now try to create secrets in each of the Key Vaults by using locals

```bash
cd create-secrets

terraform import "azurerm_resource_group.example" "/subscriptions/1412f248-f41c-4c92-be6c-28f2700d1037/resourceGroups/av-keyvault-c"

terraform init
terraform plan
terraform apply

# During repro this will want to re-create secrets for key vaults that were not on the 1st page and already have secrets
terraform plan
```

## Observations

* Terraform AzureRM versions 3.106.0, 3.109.0 and 3.110.0 have the same reproducible problem behavior when there are multiple pages of Key Vaults for both /vaults and /resources endpoints
* Terraform AzureRM versions 3.100.0, 3.105.0, 3.111.0, 3.112.0, and 3.116.0 do not exhibit the problem behavior and TF_LOG=DEBUG shows that Terraform is correctly handling paging

## Other snippets

Query secrets from Key Vault to see secret specific paging with nextLink property, if there are over 25 secrets in a Key Vault

```bash
token=$(az account get-access-token --resource https://vault.azure.net --query accessToken -o tsv)
responseJson=$(az rest --method GET --uri https://av-keyvault-a-0.vault.azure.net/secrets?api-version=7.0 --headers "Authorization=Bearer $token" --skip-authorization-header -o json)
echo $responseJson | jq '.value | length'
nextLink=$(echo $responseJson | jq -r '.nextLink')
echo $nextLink
az rest --method GET --uri $nextLink --headers "Authorization=Bearer $token" --skip-authorization-header -o json
```

Terraform import commands

```bash
for i in {0..39}; do
  terraform import "azurerm_key_vault.example[$i]" "/subscriptions/1412f248-f41c-4c92-be6c-28f2700d1037/resourceGroups/av-keyvault-a/providers/Microsoft.KeyVault/vaults/av-keyvault-a-$i"
done

terraform import "azurerm_resource_group.example" "/subscriptions/1412f248-f41c-4c92-be6c-28f2700d1037/resourceGroups/av-keyvault-c"
```
