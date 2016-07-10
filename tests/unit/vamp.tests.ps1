Import-Module .\vamp.ps1 -Verbose
Import-Module .\private\PSYaml\PSYaml.psm1 -Verbose

Describe 'Yaml Conversion' -Tags 'Unit' {
  Context 'PSYaml Module' {
    It 'Should be able to convert to Yaml vampspec.yml (Example file)' {
       { [Vamp]::ReadYaml("$pwd\vampspec.yml") } | Should not throw
    }
    It 'Should be able to convert to Yaml example.yml (Example file)' {
       { [Vamp]::ReadYaml("$pwd\examples\BasicExample.yml")  } | Should not throw
    }
    It 'Should be able to convert to Yaml customModules.yml (Example file)' {
       { [Vamp]::ReadYaml("$pwd\examples\AnotherExample.yml")  } | Should not throw
    }
    It 'Should be able to convert to Yaml customModulesAdvanced.yml (Example file)' {
       { [Vamp]::ReadYaml("$pwd\examples\YetAnotherExample.yml") } | Should not throw
    }
    It 'Should be able to generate new yml for localhost' {
@'
-  nodes:
    name : 
     - localhost

   configs:
    name : 
     - BasicExample
     - AnotherExample
     - YetAnotherExample
    
'@ | Out-file .\vampspec.yml -Force

{ ConvertFrom-Yaml -Path .\vampspec.yml } | Should not throw 
  }

    }
}
Describe 'static methods tests' {
        It 'placeholder' {

        $true | Should be $true   
    }
}

Describe 'vamp core' -Tags 'Acceptance' {
  Context 'Calling vamp help' {
        It 'Should not throw even though no parmeters passed in' {
           { vamp } | Should not throw
        }
        It 'Should bring up the help for vamp when using -?' {
           { vamp -? } | Should not throw
        }
    }
    Context 'Calling vamp -prep' {
        It 'Should run vamp -prep correctly and download required modules' {
           { vamp -prep -verbose } | Should not throw
        }
    }
    Context 'vamp -prep output' { #needs to be rewritten to check version etc
    $Current = Get-Module -ListAvailable 

        It 'Should locate required modules downloaded by -prep | xWebAdministration' {
           $Current.Where{$Psitem.name -eq 'xWebAdministration'} | Should be $true
           Test-Path 'C:\Program Files\WindowsPowerShell\Modules\xWebAdministration' | Should be $true
           }
        It 'Should locate required modules downloaded by -prep | xPowerShellExecutionPolicy' {
           $Current.Where{$Psitem.name -eq 'xPowerShellExecutionPolicy'} | Should be $true
           Test-Path 'C:\Program Files\WindowsPowerShell\Modules\xPowerShellExecutionPolicy' | Should be $true
           }
        It 'Should locate required modules downloaded by -prep | xDSCFireWall' {
           $Current.Where{$Psitem.name -eq 'xDSCFirewall'} | Should be $true
           Test-Path 'C:\Program Files\WindowsPowerShell\Modules\xDSCFirewall' | Should be $true
           }
        }
    }
Describe 'vamp -generate output' {
    Context 'vamp -generate should call the Main Method to create required .mof files' { #break this down into many more detailed tests
        It 'Should call vamp -generate correctly' {
        { vamp -generate } | Should not throw
        }
        It 'Should call vamp -generate correctly' {
        
        $spec = [Vamp]::ReadYaml("$pwd\vampspec.yml")
        $mofs = (Get-Childitem $pwd\configs\*.mof).Basename
        foreach ($item in $mofs)
        {
            $item -in $spec.nodes.name | Should be $true
        } 
           
        }
    }
}
Describe 'vamp -apply output' {
    Context 'vamp -apply should apply the generated mof files' { #break this down into many more detailed tests
        It 'Should apply configurations correctly' {

        { vamp -apply -Verbose } | Should not throw

        }  
    }
}
    

