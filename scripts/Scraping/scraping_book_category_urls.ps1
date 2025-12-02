#scraping_book_category_urls.ps1
function Get-BookCategoryUrls {
    $scraped_links = (Invoke-WebRequest -Uri 'https://books.toscrape.com/').Links.Href  | Get-Unique 
    $reg_expression = 'catalogue/category/books/.*'
    $all_matches = ($scraped_links | Select-String $reg_expression -AllMatches).Matches
     
    $urls = foreach ($url in $all_matches) {
        $url.Value
    }
    return $urls
}