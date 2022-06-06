#script to be used solely after xpertrack_claro_gencfg.ps1 have been succesfully ran from within the same folder on the same day 

$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"

$date = Get-Date -format FileDate
#write-host $date
$current_folder = Get-Location | Select-Object -ExpandProperty Path
#write-host $current_folder
$carga = "$current_folder\carga"
#write-host $carga
$xpertrack_csv_files = Get-ChildItem $carga -Name
#write-host $xpertrack_csv_files
$log_file = "$current_folder\log\xpt_api_cfg_${date}.log"
#write-host $log_file
$xpertrack_servers_ip = ".\xpt_bf_2_ip.list"
#write-host $xpertrack_servers_ip

Start-Transcript -path "$log_file" -append

Foreach ($i in $xpertrack_csv_files){
	# var
    #write-host $i
    $file_path = "${carga}\${i}"
    #write-host $file_path
    $ip = Import-Csv $xpertrack_servers_ip | Where-Object {$_.xpertrack_file -eq $i} | Select-Object -ExpandProperty ip
    #write-host $ip
    $api_login = "http://${ip}/pathtrak/api/auth/login"
    #write-host $api_login
    $api_csv = "http://${ip}/pathtrak/api/topology/import/csv"
    #write-host $api_csv
    $api_logout = "http://${ip}/pathtrak/api/auth/logout"
    #write-host $api_logout
    $file_tag_curl = "file=@${file_path};type=application/vnd.ms-excel"
    #write-host $file_tag_curl
        
    #api login
    Write-Host
    Write-Host "."
    Write-Host ".."
    Write-Host "..."
	Write-Host "trying to login via topology api to $ip"
    curl -m2 -X POST $api_login -H "accept: application/json" -H "Content-Type: application/json" -d '{ \"password\": \"ViaviBrasil\", \"username\": \"ViaviBrasil\"}'
            
    #send config file to xpertrack api topology import csv
    Write-Host
    Write-Host "."
    Write-Host ".."
    Write-Host "..."
	Write-Host "sending: $i to $ip on $date"
    Write-Host "http: $http"
    Write-Host "filetag: $file_tag_curl"
    Write-Host    
    (measure-command {curl -m2 -X POST $api_csv -H "accept: application/json" -H "Content-Type: multipart/form-data" -F "address=5" -F $file_tag_curl -F "latitude=3" -F "longitude=4" -F "name=1" -F "nodeName=2" -F "separator=;"}).TotalSeconds

    #api logout
    Write-Host
    Write-Host "."
    Write-Host ".."
    Write-Host "..."
	Write-Host "trying to logout via topology api to $ip"
    curl -m2 -X GET $api_logout -H "accept: application/json"

}

Stop-Transcript