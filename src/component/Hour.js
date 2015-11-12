import React from 'react';
import moment from 'moment';

class Hour extends React.Component {
	
	render() {

		var mountain = this.props.mountain;

		if (Object.keys(mountain).length != 0) {
			return (
				<div>
					<div style={{textAlign: 'center'}}>
						{ mountain.forecast.hour.map(function(forecastOneDay, index){
							return (
								<table style={{display: 'inline-block', verticalAlign: 'top'}}>
									<thead>
										<tr>
											<th colSpan={3}>{moment.utc(forecastOneDay[0].time).format('MM/DD')}</th>
										</tr>
										<tr>	
											<th>時間</th>
											<th>天氣</th>
											<th>降雨機率</th>
										</tr>
									</thead>
									<tbody>
										{ forecastOneDay.map(function(forecast){
											return (
												<tr>
													<td>{moment.utc(forecast.time).format('H')}</td>
													<td>
														<img 
															src={forecast.weather.img}
															title={forecast.weather.title}
															alt={forecast.weather.title}
														/>
													</td>
													<td>{forecast.probabilityOfPrecipitation}</td>
												</tr>													
											)
										})}
									</tbody>
								</table>
							)
						})}						
					</div>
				</div>
			);
		} else{
			return false;			
		};

	}
}

export default Hour;
