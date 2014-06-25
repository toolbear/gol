generation = 0
running = false
alive = {}
scale = 2
max_generation = 500
corpse = {}

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

pattern.initial = pattern.hblinker

world = Snap '#world'
graves = world.group()
cells = world.group()
for g in [graves, cells]
  g.transform (Snap.matrix scale, 0, 0, scale, window.world.offsetWidth / 2, window.world.offsetHeight / 2)

 rects = {}

f =
  pack: (x,y) -> (y & 0xffff) << 16 | x & 0xffff

  unpack: (cell) -> [(cell << 16) >> 16, cell >> 16]

  bear: (k, [x, y]) ->
    throw "[#{x},#{y}] already rendered" if rects[k]?
    rects[k] = if corpse[k]?
      f.resurrect k
    else
      cells
        .rect x, y, 1, 1
        .attr fill: "#00f"

  resurrect: (k) ->
    throw "[#{x},#{y}] not a corpse" unless corpse[k]?
    rect = corpse[k]
    delete corpse[k]
    rect
     .stop()
     .remove()
     .appendTo(cells)
     .attr fill: "#00f"

  smite: (k, rect) ->
    throw "[#{x},#{y}] never rendered" unless rects[k]?
    delete rects[k]
    f.bury k, rect

  bury: (k, rect) ->
    corpse[k] = rect
     .stop()
     .remove()
     .appendTo graves
     .attr fill: "#eee"

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
            vicinity[c] ?= [nx,ny]
      population

    next_gen[k] = cell for k, cell of alive    when survives k, cell
    next_gen[k] = cell for k, cell of vicinity when thrives  k, cell
    next_gen

  tick: () ->
    ++generation
    alive = f.evolve alive
    f.bear k, cell for k, cell of alive when !rects[k]?
    f.smite k, rect for k, rect of rects when !alive[k]?
    true

  run: () ->
    f.tick()
    f.pause() unless generation < max_generation
    running = window.setTimeout f.run, 0 if running
    true

  pause: () ->
    console.timelineEnd()
    console.profileEnd()
    window.clearTimeout running
    running = false
    console.log "paused on generation #{generation}" unless running
    world.text(window.world.offsetWidth / 2, window.world.offsetHeight / 2,"paused")
    true

  load: () ->
    alive[f.pack x,y] = [x,y] for [x,y] in pattern.initial
    f.bear k, cell for k, cell of alive

world.click () ->
  unless running
    console.timeline()
    console.profile()
    running = true
    f.run()
  else
    f.pause()

window.addEventListener 'load', f.load, false
