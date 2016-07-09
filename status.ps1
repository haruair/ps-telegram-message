$config = Get-Content .\config.json -encoding utf8 | ConvertFrom-Json

$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($config.token)/getMe"

if ($info.ok) {
	echo $info.result | Format-List
}

$updates = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($config.token)/getUpdates"

if ($updates.ok) {
    $updates.result | Select-Object -expandProperty message | Select-Object -expandProperty from text | Format-Table
}

pause
