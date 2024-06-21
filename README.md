# README

## Overview
This PowerShell script queries Active Directory (AD) for enabled users with `PasswordNotRequired=True` and tests their authentication status.

## Parameters
- `file`: (Optional) User list file path.
- `outFile`: (Optional) Output file name (default: `success_<USERDOMAIN>-<timestamp>.txt`).

## Usage
- **No Parameters**: Prompts to query AD for users with `PasswordNotRequired=True`.
- **With `file`**: Reads users from the file and tests AD authentication.

## Output
Results are saved to `outFile`.
