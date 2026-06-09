using './main.bicep'

param projectName = 'markiac'
param location = 'uksouth'
param openAiLocation = 'swedencentral'
param searchLocation = location

// Provide these at deployment time or update values in a secure process.
param sqlAdminObjectId = '00000000-0000-0000-0000-000000000000'
param sqlAdminLogin = 'admin@contoso.com'
