# What's New
This page will be updated after a branch PR is merged.

## Tuesday, February 3, 2022

- Added "Bot Defense" profile
  - [Bot Defense](https://www.volterra.io/docs/services/shape/bot-defense)
  
## Tuesday, September 7, 2021

- Added "App Setting" object
  - [Time-series Anomaly Detection](https://www.volterra.io/docs/how-to/app-security/tsa-detection) is now available
  - [User Behavior Analysis](https://www.volterra.io/docs/how-to/app-security/user-behavior-analysis) is now available 

## Monday, December 13, 2021

- Refactored 'loadgen' container traffic generator
  - No longer uses 'k6' user agent header
  - Generates miscellaneous bot traffic (allowed and blocked)

## Thursday, December 16, 2021

- Updated HTTP LB based on new Terraform provider release (0.11.2)
- Replaced App Firewall policy based on the new schema/functionality
  - [App Firewall](https://volterra.io/docs/api/app-firewall)
- Added 'User Identification' based on 