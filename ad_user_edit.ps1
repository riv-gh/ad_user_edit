Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module ActiveDirectory

$form = New-Object System.Windows.Forms.Form
$form.Text = "Зміна користувача"
$form.Size = New-Object System.Drawing.Size(300, 200)

$loginLabel = New-Object System.Windows.Forms.Label
$loginLabel.Text = "Логін:"
$loginLabel.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($loginLabel)

$loginTextBox = New-Object System.Windows.Forms.TextBox
$loginTextBox.Location = New-Object System.Drawing.Point(150, 20)
$loginTextBox.Size = New-Object System.Drawing.Size(120, 20)
$form.Controls.Add($loginTextBox)

$passwordLabel = New-Object System.Windows.Forms.Label
$passwordLabel.Text = "Новий пароль:"
$passwordLabel.Location = New-Object System.Drawing.Point(10, 60)
$form.Controls.Add($passwordLabel)

$passwordTextBox = New-Object System.Windows.Forms.TextBox
$passwordTextBox.Location = New-Object System.Drawing.Point(150, 60)
$passwordTextBox.Size = New-Object System.Drawing.Size(120, 20)
$passwordTextBox.UseSystemPasswordChar = $true
$form.Controls.Add($passwordTextBox)

$loginSearchButton = New-Object System.Windows.Forms.Button
$loginSearchButton.Text = "Пошук"
$loginSearchButton.Location = New-Object System.Drawing.Point(10, 100)
$loginSearchButton.Size = New-Object System.Drawing.Size(120, 20)
$form.Controls.Add($loginSearchButton)

$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Text = "Змінити пароль"
$resetButton.Location = New-Object System.Drawing.Point(150, 100)
$resetButton.Size = New-Object System.Drawing.Size(120, 20)
$form.Controls.Add($resetButton)

$disableButton = New-Object System.Windows.Forms.Button
$disableButton.Text = "Відключити"
$disableButton.Location = New-Object System.Drawing.Point(10, 130)
$disableButton.Size = New-Object System.Drawing.Size(120, 20)
$form.Controls.Add($disableButton)

$enableButton = New-Object System.Windows.Forms.Button
$enableButton.Text = "Повернути"
$enableButton.Location = New-Object System.Drawing.Point(150, 130)
$enableButton.Size = New-Object System.Drawing.Size(120, 20)
$form.Controls.Add($enableButton)

$loginSearchButton.Add_Click({
    if ($loginTextBox.Text) {
        $loginPart = '*'+$loginTextBox.Text+'*'
        $search = Get-ADUser -Filter {SamAccountName -like $loginPart} | Select-Object SamAccountName, Name, Enabled    
        Write-Host "Результати пошуку:"
        $search | Format-Table -AutoSize | Out-String | Write-Host
        $loginTextBox.Text = $search[0].SamAccountName
    } else {
        [System.Windows.Forms.MessageBox]::Show("Поле логін пусте", "Помилка", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})

$resetButton.Add_Click({
    $login = $loginTextBox.Text
    $newPassword = $passwordTextBox.Text

    if ($login -and $newPassword) {
        try {
            Set-ADAccountPassword -Identity $login -NewPassword (ConvertTo-SecureString $newPassword -AsPlainText -Force)
            Write-Host "Пароль змінено для користувача $login. Додаткова інформація:"
            Get-ADUser -Filter {SamAccountName -like $login} | Out-String | Write-Host
            [System.Windows.Forms.MessageBox]::Show("Пароль змінено для користувача $login", "Пароль змінено", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            Write-Host "Помилка при зміні паролю: $_"
            [System.Windows.Forms.MessageBox]::Show("Помилка при зміні паролю: $_", "Помилка", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Заповніть усі поля", "Помилка", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})

$disableButton.Add_Click({
    $login = $loginTextBox.Text
    if ($login) {
        try {
            Get-ADUser -Filter { SamAccountName -eq $login } | Disable-ADAccount
            Write-Host "Обліковий запис користувача $login відключено. Додаткова інформація:"
            Get-ADUser -Filter {SamAccountName -eq $login} | Out-String | Write-Host
            [System.Windows.Forms.MessageBox]::Show("Обліковий запис користувача $login відключено", "Обліковий запис змінено", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            Write-Host "Помилка при відключенні облікового запису: $_"
            [System.Windows.Forms.MessageBox]::Show("Помилка при відключенні облікового запису: $_", "Помилка", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Поле логін пусте", "Помилка", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})

$enableButton.Add_Click({
    $login = $loginTextBox.Text
    if ($login) {
        try {
            Get-ADUser -Filter { SamAccountName -eq $login } | Enable-ADAccount
            Write-Host "Обліковий запис користувача $login включено. Додаткова інформація:"
            Get-ADUser -Filter {SamAccountName -eq $login} | Out-String | Write-Host
            [System.Windows.Forms.MessageBox]::Show("Обліковий запис користувача $login включено", "Обліковий запис змінено", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            Write-Host "Помилка при включенні облікового запису: $_"
            [System.Windows.Forms.MessageBox]::Show("Помилка при включенні облікового запису: $_", "Помилка", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Поле логін пусте", "Помилка", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})

[void]$form.ShowDialog()
