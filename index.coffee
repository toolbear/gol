generation = 0
alive = {}

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
pattern.initial = pattern.hblinker

view_box_size = 100
world = Snap '#world'
world.attr
  preserveAspectRatio: "xMidYMid meet"
  ,           viewBox: "0 0 #{view_box_size} #{view_box_size}"
cells = world.group()
cells.transform (Snap.matrix 1, 0, 0, 1, view_box_size / 2, view_box_size / 2)
rects = {}
running = false

f =
  pack: (x,y) -> (y & 0xffff) << 16 | x & 0xffff

  unpack: (cell) -> [(cell << 16) >> 16, cell >> 16]

  birth: (k, [x, y]) ->
    throw "[#{x},#{y}] already rendered" if rects[k]?
    rect = world.rect x, y, 1, 1
    rect.attr opacity: 0
    rect.animate { opacity: 1 }, 250, mina.easein
    cells.add rect
    rects[k] = rect

  death: (k, rect) ->
    throw "[#{x},#{y}] never rendered" unless rects[k]?
    delete rects[k]
    rect.animate { opacity: 0 }, 100, mina.easeout, () -> rect.remove()

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
    console.log generation
    alive = f.evolve alive
    f.birth k, cell for k, cell of alive when !rects[k]?
    f.death k, rect for k, rect of rects when !alive[k]?
    running = window.setTimeout f.tick, 300
    true

alive[f.pack x,y] = [x,y] for [x,y] in pattern.initial

f.birth k, cell for k, cell of alive

world.click () ->
  unless running
    f.tick()
  else
    window.clearTimeout running
    running = false
  console.log 'paused' unless running
  true
