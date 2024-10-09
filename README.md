# Terraform with multiple Azure Key Vaults

Terraform with multiple Azure Key Vaults to check paging behavior

Terraform version

```bash
Terraform v1.9.7
on linux_amd64
+ provider registry.terraform.io/hashicorp/azurerm v3.109.0
```

Configure Terraform logging

```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
```

Create 40 Key Vaults with a secret in each

```bash
terraform init
terraform plan
terraform apply
```

Try plan again to see if it tries to create a secret again

```bash
terraform plan
```

## Screenshots

1st terraform plan

![1st terraform plan](images/terraform-plan0.png)

1st terraform apply

![1st terraform apply](images/terraform-apply0.png)

2nd terraform plan

![2nd terraform plan](images/terraform-plan1.png)

2nd terraform apply

![2nd terraform apply](images/terraform-apply1.png)

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
