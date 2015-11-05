React = require 'react'
moment = require 'moment'

module.exports = React.createClass(
	render: ->
		mountain = this.props.mountain
		if Object.keys(mountain).length != 0

			return (
				<div>
					<div style={textAlign: 'center'}>
						{ mountain.forecast.hour.map (forecastOneDay, index) ->
							return (
								<table style={display: 'inline-block', verticalAlign: 'top'}>
									<thead>
										<tr>
											<th colSpan={3}>{moment(forecastOneDay[0].time).format('MM/DD')}</th>
										</tr>
										<tr>	
											<th>時間</th>
											<th>天氣</th>
											<th>降雨機率</th>
										</tr>
									</thead>
									<tbody>
										{ forecastOneDay.map (forecast) ->
											return (
												<tr>
													<td>{moment(forecast.time).format('H')}</td>
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
										}
									</tbody>
								</table>
							)
						}						
					</div>
				</div>
			)
		else
			return (
				<div id='hour'></div>
			)
)

# <table style={margin: 'auto'}>
# 							<thead>
# 								<tr>
# 									<th></th>
# 									<th>天氣狀況</th>
# 									<th>降雨機率</th>
# 								</tr>
# 							</thead>
# 							<tbody>
# 								{ mountain.forecast.hour.map (forecastOneDay) ->
# 									return (
# 										<tr>
# 											<td>{moment(forecastOneDay[0].time).format('MM/DD')}</td>
# 										</tr>
# 										forecastOneDay.map (forecast) -> 
# 											return (
# 												<tr>
# 													<td>{moment(forecast.time).format('HH:mm')}</td>
# 													<td>
# 														<img 
# 															src={forecast.weather.img}
# 															title={forecast.weather.title}
# 															alt={forecast.weather.title}
# 														/>
# 													</td>
# 													<td>{forecast.probabilityOfPrecipitation}</td>
# 												</tr>													
# 											)
# 									)
# 								}
# 							</tbody>
# 						</table>