Configuration SetTimeZone
{

   Import-DSCResource -ModuleName xTimeZone

   Node TimeZone
   {
        xTimeZone TimeZoneExample
        {
            IsSingleInstance = 'Yes'
            TimeZone         = 'E. Europe Standard Time'
        }
   }
}