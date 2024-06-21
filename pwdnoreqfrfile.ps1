Param(
  [parameter(Mandatory = $false)]
  [string]$file,
  [parameter(Mandatory = $false)]
  [string]$outFile =  "success_$env:USERDOMAIN-$(get-date -format 'ddMMyyyyHHmm').txt"
)
#global vars
$Password = ""
Write-Host -ForegroundColor Magenta "
 _    _                          _    _____   ___    ___    ___
| |_ | |__   _ __  _   _  _ __  | |_ |___ /  / _ \  / _ \  / _ \
| __|| '_ \ | '__|| | | || '_ \ | __|  |_ \ | | | || | | || | | |
| |_ | | | || |   | |_| || | | || |_  ___) || |_| || |_| || |_| |
 \__||_| |_||_|    \__,_||_| |_| \__||____/  \___/  \___/  \___/
                              ......                              
                      ++##@@@@@@@@@@@@@@##++                      
                  ##@@@@@@@@@@@@@@@@@@@@@@@@@@##                  
              ++@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@++              
            ##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@##            
          ##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@##          
        ##@@@@@@@@@@@@@@..              ..@@@@@@@@@@@@@@##        
      ..@@@@@@@@@@@@@@##                  ##@@@@@@@@@@@@@@..      
      @@@@@@@@@@@@@@@@..                  ..@@@@@@@@@@@@@@@@      
    ..@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@..    
    ##@@@@@@@@@@@@##++                      ++##@@@@@@@@@@@@##    
    @@@@@@@@@@##                                  ##@@@@@@@@@@    
    @@@@@@@@@@##                                  ##@@@@@@@@@@    
    @@@@@@@@@@@@@@##..                      ..##@@@@@@@@@@@@@@    
    @@@@@@@@@@@@@@@@@@..                  ..@@@@@@@@@@@@@@@@@@    
    @@@@@@@@@@@@@@@@@@##                  ##@@@@@@@@@@@@@@@@@@    
    ##@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@##    
    ..@@@@@@@@@@@@@@@@..                  ..@@@@@@@@@@@@@@@@..    
      @@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@      
      ++@@@@@@@@@@##++..                  ..++##@@@@@@@@@@++      
        ##@@##..                                  ..##@@##        
          ..                                          ..          

"
Write-Host "`n`n`n"

if ( $PSBoundParameters.Values.Count -eq 0 ){ 
    Write-Warning ("No parameters passed.")
    Write-Warning ("Performing an AD query to lookup for enabled users with PasswordNotRequired=True")
    $Response = Read-Host "`nDo you want to QUERY the AD for the above parameter? [y=yes/n=no]"
    if($Response.ToLower() -eq "y"){
        $userList = Get-ADUser -f 'passwordnotrequired -eq "True" -and enabled -eq "True"' -pr "distinguishedname","samaccountname"
        $userList | out-file "users_$env:USERDOMAIN-$(get-date -format 'ddMMyyyyHHmm').txt"
        }
    else{
        break
    }
}

if ( $PSBoundParameters.Values.Count -gt 0 ){
    #read from file 
$userList = Get-Content "$file"
Write-Host -ForegroundColor Yellow "Extracting users from the file $file"
}

#function constructor to test connection
function Test-ADAuthentication {
    Param(
        [Parameter(Mandatory)]
        [string]$User,
        [Parameter(Mandatory = $false)]
        [string]$Domain = $env:USERDOMAIN
    )

# add type to allow validating credentials
Add-Type -AssemblyName System.DirectoryServices.AccountManagement

# create the instance of the PrinicipalContext class by using one of the constructors
    $principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, $Domain)  -ErrorAction SilentlyContinue

# check if creds valid, if successful - add to the text file.      
    if ($principalContext.ValidateCredentials($User, $Password)) {
        Write-Host -ForegroundColor Green "$Domain\$UserName - AD Authentication OK"
        "$UserName = $Name" | out-file -Append "$outFile"
    }
    else {
        Write-Host -ForegroundColor Red "$Domain\$UserName - AD Authentication failed"
    }
}

# main loop
foreach ($acc in $userList) {
    $count+=1
    $sam = Get-ADUser $acc | select samaccountname,distinguishedname
    $Name = $sam.distinguishedname
    $UserName = $sam.samaccountname
    Test-ADAuthentication -User $UserName
}

Write-Host "`n`n`nTotal accounts: $count"
$measure = Get-Content $outFile | measure -line | select lines
$totalLines = $measure.lines
Write-Host "Total accounts with NULL pwd: $totalLines"
