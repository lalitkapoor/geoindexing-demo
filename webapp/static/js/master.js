/** Converts numeric degrees to radians */
if (typeof(Number.prototype.toRad) === "undefined") {
  Number.prototype.toRad = function() {
    return this * Math.PI / 180;
  }
}

var jQT = new $.jQTouch({
	icon: 'jqtouch.png',
	addGlossToIcon: true,
	startupScreen: 'jqt_startup.png',
	statusBar: 'black'
});

now.getLocation = function(lat, lng){
	console.log(this);
};

now.getData = function(doc){
	console.log(this);
}

function handler(location) {
	now.update(location.coords.latitude, location.coords.longitude, null);
	
	var map = document.getElementById("map");
	map.innerHTML ="<img src='http://maps.google.com/maps/api/staticmap?center="+location.coords.latitude+","+location.coords.longitude+"&zoom=15&size=300x300&markers=color:blue|label:S|"+location.coords.latitude+","+location.coords.longitude+"&sensor=true'/>"
 
	$.getJSON("/geo/near/"+location.coords.latitude+"/"+location.coords.longitude, function(data){
		data = data.documents[0].results;
		for(var i=0; i<data.length; i++){
			/*gAddress = data[i]['obj']['gAddress'];
			l = gAddress.search(",");
			gAddress = gAddress.substr(l+2,gAddress.length);*/
			phone = data[i]['obj']['phone']+"";
			html = "<li class='arrow'><a href='#hospital"+i+"'>";
			html += "<div>"
			html +="<b>"+data[i]['obj']['name']+"</b>";
			html += " ("+dis(data[i].dis)+" miles)";
			html += "</a></div></li>"
			
			$("#name"+i).html("<b>"+data[i]['obj']['name']+"</b>");
			$("#address"+i).html(data[i]['obj']['address1']+"<br />"+data[i]['obj']['city']+", "+data[i]['obj']['state']+" "+data[i]['obj']['zip']+"<br />");
			$('#phone'+i).html("<a rel='external' target='_webapp' href='tel:"+phone+"'>("+phone.substr(0,3)+") "+phone.substr(3,3)+"-"+phone.substr(6,4)+"</a>");
			$("#directions"+i).html("<a rel='external' target='_webapp' href='http://maps.google.com/maps?f=d&source=s_d&saddr="+location.coords.latitude+","+location.coords.longitude+"&daddr="+data[i]['obj']['loc'][0]+","+data[i]['obj']['loc'][1]+"&hl=en'>Get Directions</a>");
			$("#notify"+i).html("<a href='javascript:notifyContacts("+location.coords.latitude+","+location.coords.longitude+",\""+data[i]['obj']['_id']+"\");'>Notify Contacts</a>");
			
			$("#hospitals").append(html);
			if(i>=4){break;}
		}
		$('a.tel').click(function() {
			if (this.href.substr(0,4) == 'tel:') {
				$(location).attr('href',this.href);
			}
		});
		
	});
}

function notifyContacts(lat,lng,id){
	$.getJSON("/geo/notify/"+lat+"/"+lng+"/"+id, function(data){});
	now.update(lat, lng, id);
	alert("notified contacts");
}

function dis(x){
	console.log(x);
	m = x * 6378 * 0.621371192; //miles
}

function haversine (lat1,lon1, lat2, lon2){
	var R = 6371; //km
	var dLat = (lat2-lat1).toRad();
	var dLon = (lon2-lon1).toRad();
	var lat1 = lat1.toRad();
	var lat2 = lat2.toRad();

	var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
	        Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
	var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
	var d = R * c;
	var m = d* 0.621371192; //miles
	return m;
}

$(document).ready(function(){
	now.ready(function(){
		navigator.geolocation.getCurrentPosition(handler);
	});
});