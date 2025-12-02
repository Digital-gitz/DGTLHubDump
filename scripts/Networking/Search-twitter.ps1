##############################################################################
##
## Search-Twitter
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##############################################################################
<#
.SYNOPSIS
Search Twitter for recent mentions of a search term
12.2 Download a Web Page from the Internet | 315
.EXAMPLE
Search-Twitter PowerShell
Searches Twitter for the term "PowerShell"
#>
param(
## The term to search for
$Pattern = "PowerShell"
)
Set-StrictMode -Version Latest
## Create the URL that contains the Twitter search results
Add-Type -Assembly System.Web
$queryUrl = 'http://integratedsearch.twitter.com/search.html?q={0}'
$queryUrl = $queryUrl -f ([System.Web.HttpUtility]::UrlEncode($pattern))
## Download the web page
$wc = New-Object System.Net.WebClient
$wc.Encoding = [System.Text.Encoding]::UTF8
$results = $wc.DownloadString($queryUrl)
## Extract the text of the messages, which are contained in
## segments that look like "<div class='msg'>...</div>"
$matches = $results |
Select-String -Pattern '(?s)<div[^>]*msg[^>]*>.*?</div>' -AllMatches
foreach($match in $matches.Matches) {
    ## Replace anything in angle brackets with an empty string,
    ## leaving just plain text remaining.
    $tweet = $match.Value -replace '<[^>]*>', ''
    ## Output the text
[System.Web.HttpUtility]::HtmlDecode($tweet.Trim()) + "`n"
}
Text parsing on less structured web pages, while possible to accomplish with compli-
cated regular expressions, can often be made much simpler through more straightfor-
ward text manipulation. Example 12-2 uses this second approach to fetch “Instant
Answers” from Bing.
Example 12-2. Get-Answer.ps1
##############################################################################
##
## Get-Answer
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##############################################################################