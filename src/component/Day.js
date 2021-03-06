import React from 'react';
import moment from 'moment';

class Day extends React.Component {
	
	render() {

		var mountain = this.props.mountain;
		
		if (Object.keys(mountain).length != 0) {
			return (
				<div>
					<div style={{textAlign: 'center'}}>
						<table style={{margin: 'auto'}}>
							<thead>
								<tr>
									<th>日期</th>
									<th>白天天氣</th>
									<th>降雨機率</th>
									<th>晚上天氣</th>
									<th>降雨機率</th>
								</tr>
							</thead>
							<tbody>
								{ mountain.forecast.week.map(function(forecast){
									return (
										<tr>
											<td>{moment.utc(forecast.daytime.time).format('MM/DD')}</td>
											<td>
												<img 
													src={forecast.daytime.weather.img}
													title={forecast.daytime.weather.title}
													alt={forecast.daytime.weather.title}
												/>
											</td>
											<td>{forecast.daytime.probabilityOfPrecipitation}</td>
											<td>
												<img
													src={forecast.night.weather.img}
													title={forecast.night.weather.title}
													alt={forecast.night.weather.title}
												/>
											</td>
											<td>{forecast.night.probabilityOfPrecipitation}</td>
										</tr>											
									);
								})}
							</tbody>
						</table>
					</div>
				</div>
			);
		} else{
			return false
		};
	}
}

export default Day;
