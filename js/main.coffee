class Line
	constructor:(@o={})->
		@el = document.getElementById @o.id
		@getPoints()
		@

	getPoints:->
		@points = []
		@points.push {x: parseInt(@el.getAttribute('x1'),10), y: parseInt( @el.getAttribute('y1'),10) }
		@points.push {x: parseInt(@el.getAttribute('x2'),10), y: parseInt( @el.getAttribute('y2'),10) }

		@pointsEnd = []
		@pointsEnd.push {x: parseInt(@el.getAttribute('x1e'),10), y: parseInt(@el.getAttribute('y1e'),10) }
		@pointsEnd.push {x: parseInt(@el.getAttribute('x2e'),10), y: parseInt(@el.getAttribute('y2e'),10) }


class Curve
	constructor:(@o={})->
		@el = document.getElementById @o.id
		@getPoints()
		@

	getPoints:->
		@d = @parseD('d')
		@d2 = @parseD('d2')

	parseD:(d)->
		d = @el.getAttribute(d)
		startPoint = d.split('c')[0]
		startPoint = startPoint.split ','
		startPoint =
			x: parseInt(startPoint[0].replace('M', ''),10)
			y: parseInt(startPoint[1],10)
		
		middlePoint = d.split('c')[1]
		middlePoint = middlePoint.split ','

		curve = middlePoint.slice 0,4

		curve = for point in curve
			parseInt(point,10)

		endPoint = middlePoint.slice 4,6
		endPoint =
			x: parseInt(endPoint[0],10)
			y: parseInt(endPoint[1],10)

		returnValue = 
			startPoint: startPoint
			curve: curve
			endPoint: endPoint


class Main
	defaults:
		transition:    500
		delay: 				 4000
		rainbowTime:   36000
		particleDelay: 1

	constructor:(@o={})->
		@vars()

		@animateChars()
		@animate()

	vars:->
		@settings = @extend @defaults, @o

		@percent = 6.9
		@currentProgress = 0

		@rainbow = document.getElementById('rainbow')
		@process = document.getElementById('process')


		@easing = TWEEN.Easing.Quadratic.Out
		@animate = @bind @animate, @

		@l1 = new Line id: 'l1'
		@l2 = new Line id: 'l2'
		
		@o1 = new Curve id: 'o1'
		@o2 = new Curve id: 'o2'

		@a1 = new Line id: 'a1'
		@a2 = new Line id: 'a2'
		@a3 = new Line id: 'a3'
		
		@d1 = new Line  id: 'd1'
		@d2 = new Curve id: 'd2'

		@i1 = new Line id: 'i1'

		@n1 = new Line id: 'n1'
		@n2 = new Line id: 'n2'
		@n3 = new Line id: 'n3'

		@g1 = new Line  id: 'g1'
		@g2 = new Curve id: 'g2'


		@lines = []
		@lines.push @l1, @l2, @a1, @a2, @a3, @d1, @i1, @n1, @n2, @n3, @g1

		@curves = []
		@curves.push @o1, @o2, @d2, @g2

	extend:(obj, obj2)->
		for key, value of obj2
			if obj2[key]? then obj[key] = value
		obj


	animateChars:->
		if @settings.delay isnt 'never'
			@animateLines()
			@animateCurves()
		@animateRainbow()

	animateRainbow:->
		it = @
		tween = new TWEEN.Tween({ deg: 0 })
			.to({ deg: 360 }, @settings.rainbowTime)
			.onUpdate(->
				it.rainbow.setAttribute 'transform', 'rotate(' + @deg + ', 0, 1000)'
			).start().repeat(true)


	animateCurves:->
		it = @
		for curve, i in @curves
			do (curve)=> 
				start = { curve0: curve.d.curve[0], curve1: curve.d.curve[1], curve2: curve.d.curve[2], curve3: curve.d.curve[3], startX: curve.d.startPoint.x, startY: curve.d.startPoint.y, endX: curve.d.endPoint.x, endY: curve.d.endPoint.y }
				end  	= { curve0: curve.d2.curve[0], curve1: curve.d2.curve[1], curve2: curve.d2.curve[2], curve3: curve.d2.curve[3], startX: curve.d2.startPoint.x, startY: curve.d2.startPoint.y, endX: curve.d2.endPoint.x, endY: curve.d2.endPoint.y }
				setTimeout =>
					tween = new TWEEN.Tween(start)
										.to(end, @settings.transition)
										.easing(@easing)
										.onUpdate(->
											curve.el.setAttribute 'd', "M#{@startX}, #{@startY} c#{@curve0}, #{@curve1}, #{@curve2}, #{@curve3}, #{@endX}, #{@endY}"
										).yoyo(true).delay(@settings.delay).repeat(999999999999999999999)
										.start()
				, i*@settings.particleDelay

	setProgress:(n)->
		n = @normalizeNum n
		time = Math.abs Math.abs(@currentProgress) - Math.abs(n)
		it = @
		tween = new TWEEN.Tween({ p: @currentProgress })
			.to({ p: n }, time*10)
			.easing(@easing)
			.onUpdate(->
				it.process.setAttribute 'width', "#{@p}"
				it.currentProgress = @p
			).start()
		


	animateLines:->
		it = @
		for line, i in @lines
			do (line, i)=> 
				setTimeout =>
					tween = new TWEEN.Tween({ x1: line.points[0].x, y1: line.points[0].y, x2: line.points[1].x, y2: line.points[1].y })
											.to({ x1: line.pointsEnd[0].x, y1: line.pointsEnd[0].y, x2: line.pointsEnd[1].x, y2: line.pointsEnd[1].y }, @settings.transition)
											.easing(@easing)
											.onUpdate(->
												line.el.setAttribute 'x1', @x1
												line.el.setAttribute 'y1', @y1

												line.el.setAttribute 'x2', @x2
												line.el.setAttribute 'y2', @y2
											).yoyo(true).delay(@settings.delay).repeat(999999999999999999999)
											.start()
				, i*@settings.particleDelay

	normalizeNum:(n)->
		n = n % 101
		@percent * n

	animate:->
		requestAnimationFrame(@animate)
		TWEEN.update()

	bind:(func, context) ->
		wrapper = ->
			args = Array::slice.call(arguments)
			unshiftArgs = bindArgs.concat(args)
			func.apply context, unshiftArgs
		bindArgs = Array::slice.call(arguments, 2)
		wrapper

window.Loading = Main
