<?php
/**
Module Created By Vansers

This module is only use for phpVMS (www.phpvms.net) - (A Virtual Airline Admin Software)

@Created By Vansers
@Copyrighted @ 2011
@Under CC 3.0
@http://creativecommons.org/licenses/by-nc-sa/3.0/

// Version 1.0 (September 7.12) - Module Created
**/
?>
<h3><?php echo SITE_NAME?>'s Fleet Tracker For <?php echo $aircraft->fullname;?> (<?php echo $aircraft->registration;?>)</h3>
<br />
<h3>Aircraft General Info</h3>
<strong>Aircraft Image:</strong>
<?php if(!empty($aircraft->imagelink))
{
	echo '<img src="'.$aircraft->imagelink.'" /><br /><br />';
}
else
{
	echo 'No Aircraft Image Yet!';
}
?><br />
<strong>ICAO: </strong><?php echo $aircraft->icao;?>
<br />
<strong>Name: </strong><?php echo $aircraft->name;?>
<br />
<strong>Fullname: </strong><?php echo $aircraft->fullname;?>
<br />
<strong>Registration: </strong><?php echo $aircraft->registration;?>
<br />
<strong>Range: </strong><?php echo $aircraft->range;?>
<br />
<strong>Weight: </strong><?php echo $aircraft->weight;?>
<br />
<strong>Cruise: </strong><?php echo $aircraft->cruise;?>
<br />
<strong>Passengers: </strong><?php echo $aircraft->maxpax;?>
<br />
<strong>Cargo: </strong><?php echo $aircraft->maxcargo;?>
<br /> 
<h3>Aircraft Stats</h3>
<strong>Total Miles: </strong><?php echo vFleetTrackData::countMiles($aircraft->id);?>
<br />
<strong>Total Hours: </strong><?php echo vFleetTrackData::countHours($aircraft->id);?>
<br />
<strong>Total Flights: </strong><?php echo vFleetTrackData::countFlights($aircraft->id);?>
<br />
<?php if(count(vFleetTrackData::CargoAircraft($aircraft->id)) > 0)
{
?>
<strong>Total Passengers Carried: </strong><?php echo vFleetTrackData::countPassengers($aircraft->id);?>
<br />
<?php
}
else
{
?>
<strong>Total Cargo Carried: </strong><?php echo vFleetTrackData::countPassengers($aircraft->id);?>
<br />
<?php
}
?>
<h3>Latest 15 Flights List</h3>
<?php MainController::Run('vFleetTracker', 'buildLastFlightTable', $aircraft->id, 15);?>

<h3>Latest 15 Flights Map</h3>

<div class="mapcenter" align="center">
<div id="routemap" style="width: 960px; height: 520px;"></div>
</div>

<script type="text/javascript">
var options = {
	mapTypeId: google.maps.MapTypeId.ROADMAP
}

var map = new google.maps.Map(document.getElementById("routemap"), options);
var flightMarkers = [];

<?php 
$shown = array();
$pirep_list = vFleetTrackData::getLastNumFlightsAircraft($aircraft->id, 15);
foreach($pirep_list as $pirep) {	
	// Dont show repeated routes		
	if(in_array($pirep->code.$pirep->flightnum, $shown))
		continue;
	else
		$shown[] = $pirep->code.$pirep->flightnum;
	
	if(empty($pirep->arrlat) || empty($pirep->arrlng)
		|| empty($pirep->deplat) || empty($pirep->deplng))
	{
		continue;
	}
?>
	dep_location = new google.maps.LatLng(<?php echo $pirep->deplat?>, <?php echo $pirep->deplng?>);
	arr_location = new google.maps.LatLng(<?php echo $pirep->arrlat?>, <?php echo $pirep->arrlng?>);

	flightMarkers[flightMarkers.length] = new google.maps.Marker({
		position: dep_location,
		map: map,
		title: "<?php echo "$pirep->depname ($pirep->depicao)";?>"
	});

	flightMarkers[flightMarkers.length] = new google.maps.Marker({
		position: arr_location,
		map: map,
		title: "<?php echo "$pirep->arrname ($pirep->arricao)";?>"
	});

	var flightPath = new google.maps.Polyline({
		path: [dep_location, arr_location],
		geodesic: true,
		strokeColor: "#FF0000", strokeOpacity: 0.5, strokeWeight: 2
	}).setMap(map);
<?php
}
?>

if(flightMarkers.length > 0)
{
	var bounds = new google.maps.LatLngBounds();
	for(var i = 0; i < flightMarkers.length; i++) {
		bounds.extend(flightMarkers[i].position);
	}
}

map.fitBounds(bounds); 
</script>


<h3>Available Flights</h3>

<?php MainController::Run('vFleetTracker', 'buildFlightsAvbTable', $aircraft->id);?>