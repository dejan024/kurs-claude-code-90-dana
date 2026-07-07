# Generise PDF verziju kursa iz markdown fajla, bez ikakvih instalacija:
# markdown -> HTML (ovaj skript) -> PDF (Microsoft Edge headless stampa).
# Upotreba:  powershell -ExecutionPolicy Bypass -File .\napravi-pdf.ps1 [-MdPath fajl.md] [-Lang en]
#
# Copyright (c) 2026 Dejan Major. Licencirano pod MIT licencom (vidi LICENSE-code).
param(
    [string]$MdPath  = "KURS-CLAUDE-CODE-90-DANA.md",
    [string]$PdfPath = "",
    [string]$Lang    = "sr-Latn"
)
if (-not $PdfPath) { $PdfPath = [System.IO.Path]::GetFileNameWithoutExtension($MdPath) + '.pdf' }

$ErrorActionPreference = 'Stop'

$mdFull  = (Resolve-Path $MdPath).Path
$pdfFull = Join-Path (Get-Location) $PdfPath
$lines   = [System.IO.File]::ReadAllLines($mdFull, [System.Text.Encoding]::UTF8)

function Escape-Html([string]$t) {
    return ($t -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;')
}

# GitHub-stil sidra: mala slova, izbaci interpunkciju, razmaci -> crtice
function Get-Anchor([string]$t) {
    $t = $t.ToLowerInvariant()
    $t = $t -replace '[^\p{L}\p{Nd}\s-]', ''
    $t = $t.Trim() -replace '\s+', '-'
    return $t
}

function Convert-Inline([string]$t) {
    $t = Escape-Html $t
    $t = $t -replace '^\[ \]\s*', '<span class="cb">&#9744;</span> '
    $t = $t -replace '`([^`]+)`', '<code>$1</code>'
    $t = $t -replace '\*\*(.+?)\*\*', '<strong>$1</strong>'
    $t = $t -replace '(?<![\w*])\*([^*]+)\*(?![\w*])', '<em>$1</em>'
    $t = $t -replace '\[([^\]]+)\]\(([^)\s]+)\)', '<a href="$2">$1</a>'
    return $t
}

function Split-TableRow([string]$r) {
    $inner = $r.Trim()
    $inner = $inner.TrimStart('|').TrimEnd('|')
    return ($inner -split '\|') | ForEach-Object { $_.Trim() }
}

$body = New-Object System.Text.StringBuilder
$i = 0
$n = $lines.Count
$h1seen = $false

while ($i -lt $n) {
    $line = $lines[$i]

    # prazna linija
    if ($line -match '^\s*$') { $i++; continue }

    # blok koda
    if ($line -match '^```') {
        $i++
        $code = New-Object System.Collections.Generic.List[string]
        while ($i -lt $n -and $lines[$i] -notmatch '^```') { $code.Add($lines[$i]); $i++ }
        $i++
        [void]$body.AppendLine('<pre><code>' + (Escape-Html ($code -join "`n")) + '</code></pre>')
        continue
    }

    # naslovi
    if ($line -match '^(#{1,4})\s+(.+)$') {
        $level  = $Matches[1].Length
        $text   = $Matches[2]
        $anchor = Get-Anchor $text
        $cls = ''
        if ($level -eq 1) {
            if ($h1seen) { $cls = ' class="pb"' } else { $docTitle = ($text -split '—')[0].Trim() }
            $h1seen = $true
        }
        [void]$body.AppendLine("<h$level id=""$anchor""$cls>" + (Convert-Inline $text) + "</h$level>")
        $i++
        continue
    }

    # horizontalna linija
    if ($line -match '^\s*-{3,}\s*$') { [void]$body.AppendLine('<hr>'); $i++; continue }

    # tabela
    if ($line -match '^\|') {
        $tbl = New-Object System.Collections.Generic.List[string]
        while ($i -lt $n -and $lines[$i] -match '^\|') { $tbl.Add($lines[$i]); $i++ }
        $rows = @($tbl | Where-Object { $_ -notmatch '^\|[\s:|-]+\|$' })
        if ($rows.Count -gt 0) {
            [void]$body.AppendLine('<table>')
            $hdr = Split-TableRow $rows[0]
            [void]$body.Append('<tr>')
            foreach ($c in $hdr) { [void]$body.Append('<th>' + (Convert-Inline $c) + '</th>') }
            [void]$body.AppendLine('</tr>')
            for ($r = 1; $r -lt $rows.Count; $r++) {
                $cells = Split-TableRow $rows[$r]
                [void]$body.Append('<tr>')
                foreach ($c in $cells) { [void]$body.Append('<td>' + (Convert-Inline $c) + '</td>') }
                [void]$body.AppendLine('</tr>')
            }
            [void]$body.AppendLine('</table>')
        }
        continue
    }

    # citat
    if ($line -match '^>\s?(.*)$') {
        $bq = New-Object System.Collections.Generic.List[string]
        while ($i -lt $n -and $lines[$i] -match '^>\s?(.*)$') { $bq.Add($Matches[1]); $i++ }
        [void]$body.AppendLine('<blockquote><p>' + (Convert-Inline ($bq -join ' ')) + '</p></blockquote>')
        continue
    }

    # liste (numerisane i obicne, ravne)
    if ($line -match '^\s*(-|\d+\.)\s+(.+)$') {
        $ordered = $Matches[1] -ne '-'
        $tag = 'ul'; if ($ordered) { $tag = 'ol' }
        [void]$body.AppendLine("<$tag>")
        while ($i -lt $n -and $lines[$i] -match '^\s*(-|\d+\.)\s+(.+)$') {
            [void]$body.AppendLine('<li>' + (Convert-Inline $Matches[2]) + '</li>')
            $i++
        }
        [void]$body.AppendLine("</$tag>")
        continue
    }

    # obican pasus (spaja uzastopne linije)
    $par = New-Object System.Collections.Generic.List[string]
    while ($i -lt $n -and $lines[$i] -notmatch '^\s*$' -and $lines[$i] -notmatch '^(#{1,4}\s|```|\||>|\s*-{3,}\s*$|\s*(-|\d+\.)\s)') {
        $par.Add($lines[$i].Trim())
        $i++
    }
    if ($par.Count -gt 0) {
        [void]$body.AppendLine('<p>' + (Convert-Inline ($par -join ' ')) + '</p>')
    } else {
        $i++  # sigurnosni izlaz da petlja nikad ne zaglavi
    }
}

$css = @'
@page { size: A4; margin: 20mm 18mm; }
* { box-sizing: border-box; }
body { font-family: "Segoe UI", Arial, sans-serif; font-size: 10.5pt; line-height: 1.55; color: #2d2a26; margin: 0; }
h1 { font-size: 22pt; color: #b3541e; border-bottom: 3px solid #b3541e; padding-bottom: 6px; margin: 0 0 14px 0; }
h1.pb { page-break-before: always; }
h2 { font-size: 16pt; color: #b3541e; page-break-before: always; margin: 0 0 10px 0; border-bottom: 1px solid #e0d5c8; padding-bottom: 4px; }
h3 { font-size: 12.5pt; color: #4a3f35; margin: 18px 0 6px 0; page-break-after: avoid; }
h4 { font-size: 11pt; color: #4a3f35; margin: 14px 0 4px 0; page-break-after: avoid; }
p { margin: 6px 0; }
a { color: #b3541e; text-decoration: none; }
code { font-family: Consolas, monospace; font-size: 9.5pt; background: #f5f0e8; padding: 1px 4px; border-radius: 3px; }
pre { background: #f5f0e8; border: 1px solid #e0d5c8; border-radius: 6px; padding: 10px 12px; page-break-inside: avoid; white-space: pre-wrap; word-wrap: break-word; }
pre code { background: none; padding: 0; }
blockquote { border-left: 4px solid #b3541e; background: #faf6ef; margin: 10px 0; padding: 6px 14px; page-break-inside: avoid; }
table { border-collapse: collapse; width: 100%; margin: 10px 0; page-break-inside: avoid; font-size: 9.5pt; }
th, td { border: 1px solid #d8cdbf; padding: 5px 8px; text-align: left; vertical-align: top; }
th { background: #f0e7da; }
ul, ol { margin: 6px 0; padding-left: 24px; }
li { margin: 3px 0; }
hr { border: none; border-top: 1px solid #e0d5c8; margin: 14px 0; }
.cb { color: #b3541e; }
'@

$html = @"
<!DOCTYPE html>
<html lang="$Lang">
<head>
<meta charset="utf-8">
<title>$docTitle</title>
<style>
$css
</style>
</head>
<body>
$($body.ToString())
</body>
</html>
"@

$htmlPath = Join-Path $env:TEMP ([System.IO.Path]::GetFileNameWithoutExtension($MdPath) + '.html')
[System.IO.File]::WriteAllText($htmlPath, $html, (New-Object System.Text.UTF8Encoding($true)))
Write-Host "HTML generisan: $htmlPath"

# nadji Edge
$edgeCandidates = @(
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
)
$edge = $edgeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $edge) { throw "Microsoft Edge nije pronadjen - potreban je za stampu u PDF." }

$tmpProfile = Join-Path $env:TEMP 'edge-pdf-profil'
$fileUrl = ([System.Uri]$htmlPath).AbsoluteUri
$edgeArgs = ('--headless --disable-gpu --no-pdf-header-footer --user-data-dir="{0}" --print-to-pdf="{1}" "{2}"' -f $tmpProfile, $pdfFull, $fileUrl)

if (Test-Path $pdfFull) { Remove-Item $pdfFull -Force }
Start-Process -FilePath $edge -ArgumentList $edgeArgs -Wait

if (Test-Path $pdfFull) {
    $size = [math]::Round((Get-Item $pdfFull).Length / 1KB)
    Write-Host "PDF napravljen: $pdfFull ($size KB)"
} else {
    throw "PDF nije napravljen - proveri Edge izlaz."
}
