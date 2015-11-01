React = require 'react'
ReactDOM = require 'react-dom'
Map = require './Map'
Forecast = require './Forecast'
$ = require 'jquery'

require '../stylesheets/index.sass'

styles = 
	basic:
		backgroundColor: 'black'
		width: '100%'
		height: '100%'


Container = React.createClass(
	getInitialState: ->
		return {
			mountains: []
			mountain: {}
		}
	,

	componentDidMount: ->
		$.get '/api/mountains', ((result) ->
			this.setState({
				mountains: result
			})
		).bind(this)
	,

	mountainClick: (index) ->
		this.setState(
			mountain: this.state.mountains[index]
		)
	,

	render: ->
		return (
			<div style={styles.basic} className='container'>
				<Map mountains={this.state.mountains} mountainClick={this.mountainClick}/>
				<Forecast mountain={this.state.mountain}/>
			</div>
		)
)

ReactDOM.render <Container />, document.getElementById('content')
