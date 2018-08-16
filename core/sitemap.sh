function writeSitemapHeader() {
    cat > "${1}/sitemap.xml" <<XML
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
XML
}

function writeSitemapEntry() {
    cat >> "${1}/sitemap.xml" <<XML
    <url>
        <loc>${2}</loc>
    </url>
XML
}

function writeSitemapFooter() {
    cat >> "${1}/sitemap.xml" <<XML
</urlset>
XML
}