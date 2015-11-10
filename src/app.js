import React from 'react';
import ReactDOM from 'react-dom';
import Map from './component/Map';
import Forecast from './component/Forecast';
import $ from 'jquery';

var styles = { 	
	basic: {
		backgroundColor: 'black',
		width: '100%',
		height: '100%',
	}
}

class Container extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			mountains: [],
			mountain: {}
		};
		this.mountainClick = this.mountainClick.bind(this);
	}

	componentDidMount() {
		$.get('/api/mountains', result => {
			this.setState({
				mountains: result
			});
		})
	}

	mountainClick(index) {
		this.setState({
			mountain: this.state.mountains[index]
		});
	}
	
	render() {
		return (
			<div style={styles.basic} className='container'>
				<Map mountains={this.state.mountains} mountainClick={this.mountainClick}/>				
				<Forecast mountain={this.state.mountain}/>
			</div>
		);
	}
}

ReactDOM.render(<Container />, document.getElementById('content'));
