import React from 'react';

var styles = {
	basic: {
		float: 'left',
		width: '50%',
		height: '100%',
		padding: '3%',
	}
};

var map = ''

class Map extends React.Component {
	
	componentDidMount() {
		L.mapbox.accessToken = 'pk.eyJ1IjoiaGlpYW15ZXMiLCJhIjoiY2lnZjBla2M1NjVuY3Zna3JvcTBqZDl1YyJ9.t7CASOZkWcnnPc6aPI7M0w'
		map = L.mapbox.map('map', 'mapbox.streets').setView([23.846442, 120.991577], 8)
	}

	mountainClick(index) {
		this.props.mountainClick(index);
	}

	render() {
		this.props.mountains.map(
			function(mountain, index){
				var popup = L.popup({
							closeButton: false,
							offset: L.point(0,-34)
						})
					.setLatLng([mountain.lat, mountain.lng])
					.setContent(mountain.nameZh)

				var marker = L.marker([mountain.lat, mountain.lng]).addTo(map);
				marker.on('click', this.mountainClick.bind(this, index));
				marker.on('mouseover', function(e){
					popup.openOn(map);
				});
			},
			this
		);
		return (
			<div id='map' style={styles.basic}></div>
		)
	}
}

export default Map;
