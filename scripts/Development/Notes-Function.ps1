# Notes-Function.ps1
function Note {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateSet('new', 'add', 'read', 'list', 'delete', 'open', 'search', 'backup', 'stats', 'micro')]
        [string]$Action,

        [Parameter(Position = 1)]
        [string]$SearchTerm,

        [switch]$ShowPreview
    )

    # Configuration
    $config = @{
        NotesDir         = Join-Path (Get-Location) "notes"
        BackupDir        = Join-Path (Get-Location) "notes\backups"
        MaxPreviewLength = 100
        DateFormat       = "yyyy-MM-dd HH:mm:ss"
        FileExtension    = ".txt"
    }

    # Ensure directories exist
    @($config.NotesDir, $config.BackupDir) | ForEach-Object {
        if (-not (Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
        }
    }

    # Helper Functions
    function Show-Menu {
        $menuItems = @(
            @{ Number = "1"; Action = "new"; Description = "Create new note" }
            @{ Number = "2"; Action = "add"; Description = "Add to existing note" }
            @{ Number = "3"; Action = "read"; Description = "Read existing note" }
            @{ Number = "4"; Action = "list"; Description = "List all notes" }
            @{ Number = "5"; Action = "delete"; Description = "Delete note" }
            @{ Number = "6"; Action = "open"; Description = "Open note in default editor" }
            @{ Number = "7"; Action = "search"; Description = "Search notes" }
            @{ Number = "8"; Action = "backup"; Description = "Backup notes" }
            @{ Number = "9"; Action = "stats"; Description = "Show notes statistics" }
            @{ Number = "10"; Action = "micro"; Description = "Open note in Micro editor" }
            @{ Number = "0"; Action = "exit"; Description = "Exit" }
        )

        Write-Host "`nNote Management:" -ForegroundColor Cyan
        foreach ($item in $menuItems) {
            Write-Host "$($item.Number). $($item.Description)" -ForegroundColor White
        }
        
        do {
            $choice = Read-Host "`nSelect an option (0-10)"
            $selectedItem = $menuItems | Where-Object { $_.Number -eq $choice }
            if ($selectedItem) {
                return $selectedItem.Action
            }
            else {
                Write-Host "Invalid option. Please try again." -ForegroundColor Red
            }
        } while ($true)
    }

    function Get-NotePreview {
        param([string]$Content)
        if ($Content.Length -gt $config.MaxPreviewLength) {
            return $Content.Substring(0, $config.MaxPreviewLength) + "..."
        }
        return $Content
    }

    function Format-FileSize {
        param([double]$Size)
        $sizes = "B", "KB", "MB", "GB"
        $order = 0
        while ($Size -ge 1024 -and $order -lt $sizes.Count) {
            $order++
            $Size = $Size / 1024
        }
        "{0:N2} {1}" -f $Size, $sizes[$order]
    }

    function Backup-Notes {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = Join-Path $config.BackupDir "notes_backup_$timestamp.zip"
        
        try {
            Compress-Archive -Path "$($config.NotesDir)\*.txt" -DestinationPath $backupPath -Force
            Write-Host "Backup created successfully at: $backupPath" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to create backup: $_" -ForegroundColor Red
        }
    }

    function Show-Statistics {
        $notes = Get-ChildItem -Filter "*$($config.FileExtension)" -Path $config.NotesDir
        $stats = @{
            TotalNotes  = $notes.Count
            TotalSize   = ($notes | Measure-Object -Property Length -Sum).Sum
            OldestNote  = ($notes | Sort-Object CreationTime | Select-Object -First 1).Name
            NewestNote  = ($notes | Sort-Object CreationTime -Descending | Select-Object -First 1).Name
            AverageSize = ($notes | Measure-Object -Property Length -Average).Average
        }

        Write-Host "`nNotes Statistics:" -ForegroundColor Cyan
        Write-Host "Total Notes: $($stats.TotalNotes)" -ForegroundColor White
        Write-Host "Total Size: $(Format-FileSize $stats.TotalSize)" -ForegroundColor White
        Write-Host "Average Size: $(Format-FileSize $stats.AverageSize)" -ForegroundColor White
        Write-Host "Oldest Note: $($stats.OldestNote)" -ForegroundColor White
        Write-Host "Newest Note: $($stats.NewestNote)" -ForegroundColor White
    }

    # Get all notes
    $notes = Get-ChildItem -Filter "*$($config.FileExtension)" -Path $config.NotesDir

    # Show menu if no action specified
    if (-not $Action) {
        $Action = Show-Menu
        if ($Action -eq 'exit') { return }
    }

    switch ($Action.ToLower()) {
        "new" {
            do {
                $noteName = Read-Host "Enter note name (without .txt)"
                if ([string]::IsNullOrWhiteSpace($noteName)) {
                    Write-Host "Note name cannot be empty." -ForegroundColor Yellow
                    continue
                }
                break
            } while ($true)

            $notePath = Join-Path $config.NotesDir "$noteName.txt"
            
            if (Test-Path $notePath) {
                Write-Host "Note already exists. Use 'add' to append content." -ForegroundColor Yellow
                return
            }

            Write-Host "Enter note content (press Ctrl+Z and Enter when done):"
            $newNote = @()
            while ($line = Read-Host) {
                $newNote += $line
            }
            
            try {
                $currentDateTime = Get-Date -Format $config.DateFormat
                $newNoteContent = "[$currentDateTime]`n$($newNote -join "`n")`n"
                Set-Content -Path $notePath -Value $newNoteContent
                Write-Host "Note created successfully: $noteName.txt" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to create note: $_" -ForegroundColor Red
            }
        }

        "add" {
            if ($notes.Count -eq 0) {
                Write-Host "No notes found." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nExisting notes:" -ForegroundColor Cyan
            $notes | ForEach-Object { Write-Host " - $($_.Name)" -ForegroundColor White }
            
            $selectedNote = Read-Host "`nSelect note to update (without .txt)"
            $notePath = Join-Path $config.NotesDir "$selectedNote.txt"
            
            if (Test-Path $notePath) {
                Write-Host "Enter additional content (press Ctrl+Z and Enter when done):"
                $additionalText = @()
                while ($line = Read-Host) {
                    $additionalText += $line
                }
                
                try {
                    $currentDateTime = Get-Date -Format $config.DateFormat
                    $appendContent = "`n[$currentDateTime]`n$($additionalText -join "`n")"
                    Add-Content -Path $notePath -Value $appendContent
                    Write-Host "Note updated successfully: $selectedNote.txt" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to update note: $_" -ForegroundColor Red
                }
            }
            else {
                Write-Host "Note not found: $selectedNote.txt" -ForegroundColor Red
            }
        }

        "read" {
            if ($notes.Count -eq 0) {
                Write-Host "No notes found." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nExisting notes:" -ForegroundColor Cyan
            $notes | ForEach-Object { Write-Host " - $($_.Name)" -ForegroundColor White }
            
            $selectedNote = Read-Host "`nSelect note to read (without .txt)"
            $notePath = Join-Path $config.NotesDir "$selectedNote.txt"
            
            if (Test-Path $notePath) {
                Write-Host "`nContents of '$selectedNote.txt':`n" -ForegroundColor Cyan
                Get-Content $notePath | ForEach-Object {
                    if ($_ -match '^\[\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\]$') {
                        Write-Host $_ -ForegroundColor Yellow
                    }
                    else {
                        Write-Host $_
                    }
                }
                Write-Host ""
            }
            else {
                Write-Host "Note not found: $selectedNote.txt" -ForegroundColor Red
            }
        }

        "list" {
            if ($notes.Count -eq 0) {
                Write-Host "No notes found." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nAvailable notes:" -ForegroundColor Cyan
            $notes | ForEach-Object {
                $lastWriteTime = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                $size = [math]::Round($_.Length / 1KB, 2)
                Write-Host "$($_.Name)" -ForegroundColor White
                Write-Host "  Last modified: $lastWriteTime" -ForegroundColor Gray
                Write-Host "  Size: $size KB" -ForegroundColor Gray
            }
            Write-Host ""
        }

        "delete" {
            if ($notes.Count -eq 0) {
                Write-Host "No notes found." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nExisting notes:" -ForegroundColor Cyan
            $notes | ForEach-Object { Write-Host " - $($_.Name)" -ForegroundColor White }
            
            $selectedNote = Read-Host "`nSelect note to delete (without .txt)"
            $notePath = Join-Path $config.NotesDir "$selectedNote.txt"
            
            if (Test-Path $notePath) {
                $confirmation = Read-Host "Are you sure you want to delete '$selectedNote.txt'? (y/n)"
                if ($confirmation -eq 'y') {
                    try {
                        Remove-Item $notePath
                        Write-Host "Note deleted successfully: $selectedNote.txt" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "Failed to delete note: $_" -ForegroundColor Red
                    }
                }
            }
            else {
                Write-Host "Note not found: $selectedNote.txt" -ForegroundColor Red
            }
        }

        "open" {
            if ($notes.Count -eq 0) {
                Write-Host "No notes found." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nExisting notes:" -ForegroundColor Cyan
            $notes | ForEach-Object { Write-Host " - $($_.Name)" -ForegroundColor White }
            
            $selectedNote = Read-Host "`nSelect note to open (without .txt)"
            $notePath = Join-Path $config.NotesDir "$selectedNote.txt"
            
            if (Test-Path $notePath) {
                try {
                    Start-Process $notePath
                    Write-Host "Opening note in default editor: $selectedNote.txt" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to open note: $_" -ForegroundColor Red
                }
            }
            else {
                Write-Host "Note not found: $selectedNote.txt" -ForegroundColor Red
            }
        }

        "search" {
            if (-not $SearchTerm) {
                $SearchTerm = Read-Host "Enter search term"
            }
            
            $results = Get-ChildItem -Filter "*$($config.FileExtension)" -Path $config.NotesDir | 
            Where-Object { 
                    (Get-Content $_.FullName -Raw) -match $SearchTerm -or 
                $_.Name -match $SearchTerm
            }

            if ($results) {
                Write-Host "`nSearch results for '$SearchTerm':" -ForegroundColor Cyan
                foreach ($result in $results) {
                    Write-Host "`n$($result.Name)" -ForegroundColor Yellow
                    if ($ShowPreview) {
                        $content = Get-Content $result.FullName -Raw
                        $preview = Get-NotePreview $content
                        Write-Host $preview -ForegroundColor Gray
                    }
                }
            }
            else {
                Write-Host "No matches found for '$SearchTerm'" -ForegroundColor Yellow
            }
        }

        "backup" {
            Backup-Notes
        }

        "stats" {
            Show-Statistics
        }

        "micro" {
            if ($notes.Count -eq 0) {
                Write-Host "No notes found." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nExisting notes:" -ForegroundColor Cyan
            $notes | ForEach-Object { Write-Host " - $($_.Name)" -ForegroundColor White }
            
            $selectedNote = Read-Host "`nSelect note to open in Micro (without .txt)"
            $notePath = Join-Path $config.NotesDir "$selectedNote.txt"
            
            if (Test-Path $notePath) {
                try {
                    # Check if micro is installed
                    if (Get-Command micro -ErrorAction SilentlyContinue) {
                        micro $notePath
                        Write-Host "Opening note in Micro editor: $selectedNote.txt" -ForegroundColor Green
                    }
                    else {
                        Write-Host "Micro editor is not installed. Please install it first." -ForegroundColor Red
                        Write-Host "You can install Micro from: https://github.com/zyedidia/micro/releases" -ForegroundColor Yellow
                    }
                }
                catch {
                    Write-Host "Failed to open note in Micro: $_" -ForegroundColor Red
                }
            }
            else {
                Write-Host "Note not found: $selectedNote.txt" -ForegroundColor Red
            }
        }

        default {
            Write-Host "Invalid action specified." -ForegroundColor Red
        }
    }
}

# Add tab completion for note names
Register-ArgumentCompleter -CommandName Note -ParameterName SearchTerm -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    $notesDir = Join-Path (Get-Location) "notes"
    Get-ChildItem -Path $notesDir -Filter "*.txt" |
        Where-Object { $_.Name -like "*$wordToComplete*" } |
        ForEach-Object { $_.Name -replace '\.txt$' }
}
