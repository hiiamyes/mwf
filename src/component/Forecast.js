import React from 'react';
import Hour from './Hour';
import Day from './Day';

var styles = {
	basic: {
		float: 'right',
		color: 'white',	
		width: '50%',
		height: '100%',
	},
	selector: {
		color: 'rgba(255,255,255,0.5)',
		display: 'inline-block',
		border: '1px solid rgba(255,255,255,0.5)',
		borderRadius: '2px',
		padding: '5px',
		marginRight: '30px',
	},
	selected: {
		color: 'white',
		border: '1px solid white',
	},
	hide: {
		display: 'none'
	}
};

class Forecast extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			hour: true
		};
		this.showWeek = this.showWeek.bind(this);
		this.showHour = this.showHour.bind(this);
	}

	showWeek() {
		this.setState({
			hour: false
		});
	}
	
	showHour() {
		this.setState({
			hour: true
		});
	}
	
	render() {
		var mountain = this.props.mountain
		if(Object.keys(mountain).length != 0) {
			return (
				<div style={styles.basic}>
					<h2 style={{textAlign: 'center'}}>{this.props.mountain.nameZh}</h2>
					<div style={{textAlign: 'center'}}>
						<h3 style={Object.assign({}, styles.selector, this.state.hour && styles.selected)} onMouseOver={this.showHour}>逐三小時預報</h3>
						<h3 style={Object.assign({}, styles.selector, !this.state.hour && styles.selected)} onMouseOver={this.showWeek}>一周預報</h3>
					</div>
					<div style={Object.assign({}, !this.state.hour && styles.hide)}>
						<Hour mountain={this.props.mountain}/>
					</div>
					<div style={Object.assign({}, this.state.hour && styles.hide)}>
						<Day mountain={this.props.mountain}/>
					</div>
				</div>
			)
		}else{
			return false;
		}
	}
}

export default Forecast;
