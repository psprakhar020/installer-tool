 #ERASE ALL THIS AND PUT XAML BELOW between the @" "@ 
$inputXML = @"
<Window x:Name="tool" x:Class="installer.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:installer"
        mc:Ignorable="d"
        ResizeMode="NoResize"
        Title="MainWindow" Height="365" Width="608">

    <Grid x:Name="test" Margin="0,0,5,3" RenderTransformOrigin="0.5,0.5">

        <Grid.Background>
            <LinearGradientBrush EndPoint="0.5,1" StartPoint="0.5,0">
                <GradientStop Color="Black" Offset="0"/>
                <GradientStop Color="#FFF5EBEB" Offset="1"/>
            </LinearGradientBrush>
        </Grid.Background>
        <Grid.RenderTransform>
            <TransformGroup>
                <ScaleTransform/>
                <SkewTransform/>
                <RotateTransform Angle="0.017"/>
                <TranslateTransform/>
            </TransformGroup>
        </Grid.RenderTransform>
        <Button x:Name="start" Content="Start" HorizontalAlignment="Left" Height="27" Margin="447,267,0,0" VerticalAlignment="Top" Width="90" RenderTransformOrigin="-0.006,-0.698"/>
        <TextBox x:Name="server_name" HorizontalAlignment="Left" Height="21" Margin="162,103,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="133"/>
        <Button x:Name="browse" Content="Browse" HorizontalAlignment="Left" Height="24" Margin="312,62,0,0" VerticalAlignment="Top" Width="75" RenderTransformOrigin="-0.858,0.499"/>
        <TextBox x:Name="source" HorizontalAlignment="Left" Height="21" Margin="162,62,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="133"/>
        <TextBlock HorizontalAlignment="Left" Height="25" Margin="312,148,0,0" TextWrapping="Wrap" Text="Restart Required:" VerticalAlignment="Top" Width="132" FontSize="16" Grid.ColumnSpan="3"/>
        <RadioButton x:Name="yes" Content="Yes" HorizontalAlignment="Left" Height="20" Margin="312,194,0,0" VerticalAlignment="Top" Width="104" Checked="RadioButton_Checked" FontSize="14" Grid.ColumnSpan="3"/>
        <RadioButton x:Name="no" Content="No" HorizontalAlignment="Left" Height="20" Margin="312,218,0,0" VerticalAlignment="Top" Width="91" Checked="RadioButton_Checked_1" FontSize="14" RenderTransformOrigin="0.806,-1.652" Grid.ColumnSpan="3"/>
        <TextBlock HorizontalAlignment="Left" Height="25" Margin="10,156,0,0" TextWrapping="Wrap" Text="Credential" VerticalAlignment="Top" Width="109" FontSize="16"/>
        <TextBlock HorizontalAlignment="Left" Height="27" Margin="7,195,0,0" TextWrapping="Wrap" Text="UserName:" VerticalAlignment="Top" Width="77"/>
        <TextBlock HorizontalAlignment="Left" Height="27" Margin="7,232,0,0" TextWrapping="Wrap" Text="Paasword:" VerticalAlignment="Top" Width="77"/>
        <TextBox x:Name="username" HorizontalAlignment="Left" Height="21" Margin="84,194,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="129"/>
        <PasswordBox x:Name="password" HorizontalAlignment="Left" Height="21" Margin="84,232,0,0" VerticalAlignment="Top" Width="129"/>
        <TextBlock HorizontalAlignment="Left" Height="24" Margin="7,62,0,0" TextWrapping="Wrap" Text="Location of exe file:" VerticalAlignment="Top" Width="170" FontSize="16"/>
        <TextBlock HorizontalAlignment="Left" Height="21" Margin="7,107,0,0" TextWrapping="Wrap" Text="Server Name:" VerticalAlignment="Top" Width="109" FontSize="16"/>
    </Grid>
</Window>




"@ 

$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML

#Check for a text changed value (which we cannot parse)
If ($xaml.SelectNodes("//*[@Name]") | ? TextChanged){write-error "This Snippet can't convert any lines which contain a 'textChanged' property. `n please manually remove these entries"
        $xaml.SelectNodes("//*[@Name]") | ? TextChanged | % {write-warning "Please remove the TextChanged property from this entry $($_.Name)"}
return}

#Read XAML

    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch [System.Management.Automation.MethodInvocationException] {
    Write-Warning "We ran into a problem with the XAML code.  Check the syntax for this control..."
    write-host $error[0].Exception.Message -ForegroundColor Red
    if ($error[0].Exception.Message -like "*button*"){
        write-warning "Ensure your &lt;button in the `$inputXML does NOT have a Click=ButtonClick property.  PS can't handle this`n`n`n`n"}
}
catch{#if it broke some other way :D
    Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
        }

#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================

$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}

Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}

Get-FormVariables

#===========================================================================
# Use this space to add code to the various form elements in your GUI
#===========================================================================
                                                                   
    
#Reference 

#Adding items to a dropdown/combo box
    #$vmpicklistView.items.Add([pscustomobject]@{'VMName'=($_).Name;Status=$_.Status;Other="Yes"})
    
#Setting the text of a text box to the current PC name    
    #$WPFtextBox.Text = $env:COMPUTERNAME
    
#Adding code to a button, so that when clicked, it pings a system
# $WPFbutton.Add_Click({ Test-connection -count 1 -ComputerName $WPFtextBox.Text
# })
#===========================================================================
# Shows the form
#===========================================================================
write-host "To show the form, run the following" -ForegroundColor Cyan
'$Form.ShowDialog() | out-null'
