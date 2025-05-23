#!/bin/bash

####################################################################################################
#
# Setup Your Mac Configuration Download Estimation Tester
#
# This will allow you to quickly view and tweak the download estimates without having to re-run your Setup-Your-Mac script
# until you achieve the desired output and copy the configuration parameter values to your Setup-Your-Mac script
#
####################################################################################################
#
# HISTORY
#
#   Version 0.0.4, 23-May-2025, Andrew Spokes (@iDrewbs/@TechTrekkie)
#   - Modified script to work with macOS 12 and higher
#
#   Version 0.0.3, 31-Oct-2023, Andrew Spokes (@iDrewbs/@TechTrekkie)
#   - Added support for macOS 14
# 
####################################################################################################

osVersion=$( sw_vers -productVersion )


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Configuration Download Estimation
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

### Modify these settings to adjust the Download Estimation output. 
### Instructions for getting configuration sizes can be found in @dan-snelson blog: [INSERT LINK HERE]

### Once you have the desired/accurate estimation output, you can copy these values to your Setup-Your-Mac script

correctionCoefficient="1.00"            # "Fudge factor" (to help estimate match reality)

configurationOneSize="60"               # Configuration One in Gibibits (i.e., Total File Size in Gigabytes * 7.451) 
configurationOneInstallBuffer="0"           # Buffer time added to estimates to include installation time of packages in seconds. Set to 0 to disable.

configurationTwoSize="110"               # Configuration Two in Gibibits (i.e., Total File Size in Gigabytes * 7.451) 
configurationTwoInstallBuffer="0"           # Buffer time added to estimates to include installation time of packages in seconds. Set to 0 to disable. 

configurationThreeSize="121"            # Configuration Three in Gibibits (i.e., Total File Size in Gigabytes * 7.451) 
configurationThreeInstallBuffer="0"         # Buffer time added to estimates to include installation time of packages in seconds. Set to 0 to disable. 

configurationCatchAllSize="121"          # Catch-all Configuration in Gibibits (i.e., Total File Size in Gigabytes * 7.451) 
configurationCatchAllInstallBuffer="0"      # Buffer time added to estimates to include installation time of packages in seconds. Set to 0 to disable. 



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Check Network Quality for Configurations (thanks, @bartreadon!)
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

function get_json_value() {
	JSON="$1" osascript -l 'JavaScript' \
	-e 'const env = $.NSProcessInfo.processInfo.environment.objectForKey("JSON").js' \
	-e "JSON.parse(env).$2"
}


function checkNetworkQualityConfigurations() {
	

	networkQuality -s -v -c > /var/tmp/networkQualityTest
	networkQualityTest=$( < /var/tmp/networkQualityTest )
	rm /var/tmp/networkQualityTest
	
			dlThroughput=$( get_json_value "$networkQualityTest" "dl_throughput")
			dlResponsiveness=$( get_json_value "$networkQualityTest" "dl_responsiveness" )
			dlStartDate=$( get_json_value "$networkQualityTest" "start_date" )
			dlEndDate=$( get_json_value "$networkQualityTest" "end_date" )

	
	mbps=$( echo "scale=2; ( $dlThroughput / 1000000 )" | bc )
	echo "Network Quality Test: Started: $dlStartDate, Ended: $dlEndDate; Download: $mbps Mbps, Responsiveness: $dlResponsiveness"
	echo ""
	echo "Download Speed: $mbps (Mbps)"
	echo ""
	configurationOneEstimatedSeconds=$( echo "scale=2; ((((( $configurationOneSize / $mbps ) * 60 ) * 60 ) * $correctionCoefficient ) + $configurationOneInstallBuffer)" | bc | sed 's/\.[0-9]*//' )
	echo "Configuration One Estimated Seconds: $configurationOneEstimatedSeconds"
	echo "Configuration One Estimate: $(printf '%dh:%dm:%ds\n' $((configurationOneEstimatedSeconds/3600)) $((configurationOneEstimatedSeconds%3600/60)) $((configurationOneEstimatedSeconds%60)))"
	echo ""
	configurationTwoEstimatedSeconds=$( echo "scale=2; ((((( $configurationTwoSize / $mbps ) * 60 ) * 60 ) * $correctionCoefficient ) + $configurationTwoInstallBuffer)" | bc | sed 's/\.[0-9]*//' )
	echo "Configuration Two Estimated Seconds: $configurationTwoEstimatedSeconds"
	echo "Configuration Two Estimate: $(printf '%dh:%dm:%ds\n' $((configurationTwoEstimatedSeconds/3600)) $((configurationTwoEstimatedSeconds%3600/60)) $((configurationTwoEstimatedSeconds%60)))"
	echo ""
	configurationThreeEstimatedSeconds=$( echo "scale=2; ((((( $configurationThreeSize / $mbps ) * 60 ) * 60 ) * $correctionCoefficient ) + $configurationThreeInstallBuffer)" | bc | sed 's/\.[0-9]*//' )
	echo "Configuration Three Estimated Seconds: $configurationThreeEstimatedSeconds"
	echo "Configuration Three Estimate: $(printf '%dh:%dm:%ds\n' $((configurationThreeEstimatedSeconds/3600)) $((configurationThreeEstimatedSeconds%3600/60)) $((configurationThreeEstimatedSeconds%60)))"
	echo ""
	configurationCatchAllEstimatedSeconds=$( echo "scale=2; ((((( $configurationCatchAllSize / $mbps ) * 60 ) * 60 ) * $correctionCoefficient ) + $configurationCatchAllInstallBuffer)" | bc | sed 's/\.[0-9]*//' )
	echo "Catch-all Configuration Estimated Seconds: $configurationCatchAllEstimatedSeconds"
	echo "Catch-all Configuration Estimate: $(printf '%dh:%dm:%ds\n' $((configurationCatchAllEstimatedSeconds/3600)) $((configurationCatchAllEstimatedSeconds%3600/60)) $((configurationCatchAllEstimatedSeconds%60)))"
	

}


if [[ $osVersion == "11"* ]]; then
	echo "Will not work with macOS 11"
else
	# Execute the function
	checkNetworkQualityConfigurations

fi