$base = (Get-Location).ProviderPath
$git  = [System.IO.Path]::Combine($base, '.git')

Get-ChildItem -Recurse -Force -FollowSymlink -ErrorAction SilentlyContinue |
Where-Object {
    $full = $_.FullName
    -not ($full -eq $git -or $full -like "$git\*" -or $full -like "$git/*")
} |
ForEach-Object {
    $rel = Resolve-Path -Relative $_.FullName -ErrorAction SilentlyContinue
    if ($rel) {
        # 1) usuń wiodące "./" lub ".\"
        $rel = $rel -replace '^(?:\.[\\/])+', ''
        # 2) zamień backslashe na slashe i sklej wielokrotne slashe
        $rel = ($rel -replace '\\','/') -replace '/+','/'
        # 3) dołóż dokładnie jedno "./"
        './' + $rel.TrimStart('/')
    }
} | Sort-Object -Unique | Out-File -FilePath 'paths.txt' -Encoding utf8
