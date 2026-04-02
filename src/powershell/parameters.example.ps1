# Example parameter file for Nutanix to Azure Local migration scripts
# Fill in values matching your environment before running Invoke-*.ps1 scripts.
# Organization: Infinite Improbability Corp (IIC)

# Path to your populated variables.yml
$ConfigPath = ".\config\variables\variables.yml"

# Credential — leave $null to trigger Key Vault or interactive prompt
$Credential = $null

# Example: Provide static credential (not recommended for production)
# $securePass = ConvertTo-SecureString "YourPassword" -AsPlainText -Force
# $Credential = [PSCredential]::new("administrator", $securePass)

# Target node override — leave empty to use value from variables.yml
$TargetNode = ""

# Log directory override
$LogPath = ""

# Example: Run preflight
# .\Invoke-MigrationPreflight.ps1 -ConfigPath $ConfigPath -Credential $Credential -Verbose

# Example: Generate VM batch inventory
# .\New-VMBatchInventory.ps1 -ConfigPath $ConfigPath -BatchSize 10 -Verbose

# Example: Veeam cutover
# .\Invoke-VeeamBatchCutover.ps1 -ConfigPath $ConfigPath -Credential $Credential -Verbose

# Example: HYCU restore
# .\Invoke-HYCUBackupRestore.ps1 -ConfigPath $ConfigPath -Credential $Credential -Verbose

# Example: Azure Migrate cutover (run after VMs are replicating)
# .\Invoke-AzureMigrateCutover.ps1 -ConfigPath $ConfigPath -WhatIf -Verbose

# Example: Re-IP VMs after restore
# .\Set-VMNetworkConfig.ps1 -ConfigPath $ConfigPath -TargetNode "hyperv-staging.iic.local" -WhatIf -Verbose

# Example: Post-migration validation
# .\Test-MigrationValidation.ps1 -ConfigPath $ConfigPath -Verbose
