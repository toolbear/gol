generation = 0
running = false
alive = {}
scale = 1
world = null
dx = 0
dy = 0

pattern =
  hblinker: [
    [-1,  0]
    [ 0,  0]
    [ 1,  0]
  ]

  block: [
    [ 0,  0]
    [ 1,  0]
    [ 0,  1]
    [ 1,  1]
  ]

  diehard: [
    [ 2,  1]
    [-4,  0]
    [-3,  0]
    [-3, -1]
    [ 1, -1]
    [ 2, -1]
    [ 3, -1]
  ]

  acorn: [
    [-2,  1]
    [ 0,  0]
    [-3, -1]
    [-2, -1]
    [ 1, -1]
    [ 2, -1]
    [ 3, -1]
  ]
pattern.initial = pattern.acorn

f =
  pack: (x,y) -> (y & 0xffff) << 16 | x & 0xffff

  unpack: (cell) -> [(cell << 16) >> 16, cell >> 16]

  bear: (k, [x,y]) ->
    dx = ($ '#world').width() / 2
    dy = ($ '#world').height() / 2

    world.fillStyle = "#0000ff"
    world.fillRect x*scale + dx, y*scale + dy, scale, scale
    k

  smite: (k, [x,y]) ->

    world.fillStyle = "#ffffff"
    world.fillRect x*scale + dx, y*scale + dy, scale, scale
    k

  evolve: (alive) ->
    next_gen = {}
    census = {}
    vicinity = {}

    survives = (k, [x,y]) ->
      population = census[k] ?= survey x,y, 1 # memoize
      2 < population < 5

    thrives = (k, [x, y]) ->
      population = census[k] ?= survey x,y, 0 # memoize
      population is 3

    survey = (x,y, distance) ->
      population = 0
      for nx in [x-1..x+1]
        for ny in [y-1..y+1]
          c = f.pack nx,ny
          if alive[c]?
            population++
          else if distance > 0
            vicinity[c] ?= [nx,ny, generation]
      population

    for k, cell of alive when survives k, cell
      next_gen[k] = cell
    for k, cell of vicinity when thrives k, cell
      next_gen[k] = cell
    next_gen

  tick: () ->
    ++generation
    next_gen = f.evolve alive
    for k, cell of next_gen when !alive[k]?
      f.bear k, cell
    for k, rect of alive when !next_gen[k]?
      f.smite k, rect
    alive = next_gen

  run: () ->
    f.tick()
    running = window.setTimeout f.run, 0 if running
    true

  pause: () ->
    window.clearTimeout running
    running = false
    console.log "paused on generation #{generation}" unless running
    true

  load: () ->
    $win = $ window
    w = $win.width()
    h = $win.height()
    dx = w / 2
    dy = w / 2
    $world = $('#world').attr width: w, height: h

    $world.click () ->
      unless running
        running = true
        f.run()
      else
        f.pause()
    world = $world[0].getContext '2d'
    for [x,y] in pattern.initial
      alive[f.pack x,y] = [x,y, generation]
    for k, cell of alive
      f.bear k, cell
    true

$ f.load
