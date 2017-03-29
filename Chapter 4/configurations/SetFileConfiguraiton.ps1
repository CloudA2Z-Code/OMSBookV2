Configuration SetFileConfiguraiton
{

    Import-DscResource -Module nx

    Node  BaselineServers 
    {
        nxFile ImportantConfiguration  
        {
            DestinationPath = "/tmp/ImportantConfiguration"
            Contents = "ConfigurationApplied : Yes"
            Ensure = "Present"
            Type = "File"
        }

    }
}