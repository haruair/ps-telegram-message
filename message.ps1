$config = Get-Content .\config.json -encoding utf8 | ConvertFrom-Json

$haruair = Invoke-WebRequest -Uri "http://haruair.com/blog/"
$titles = $haruair.ParsedHtml.getElementsByTagName("h2") | Where-Object { $_.className -eq "entry-title" }
$links = $titles.getElementsByTagName("a") | Select-Object innerText, href

try {
  $oldLinks = Import-Csv .\data.csv
}
catch [System.IO.FileNotFoundException] {
  $oldLinks = @()
}

$diff = Compare-Object $oldLinks $links -property innerText, href | Where-Object { $_.SideIndicator -eq '=>' }
$measure = $diff | Measure-Object

if ($measure.Count -ne 0) {
  foreach ($link in $diff) {
    $message = "New Post! $($link.innerText) $($link.href)"
    $encodedMessage = [System.Web.HttpUtility]::UrlEncode($message)

    $info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($config.token)/sendMessage?text=$encodedMessage&chat_id=$($config.chatId)"
  }
  $links | Export-Csv .\data.csv -Encoding utf8
}
