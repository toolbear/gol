generation = 0

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

world = Snap '#world'
world.attr
  preserveAspectRatio: "xMidYMid meet"
  ,           viewBox: "0 0 50 50"
cells = world.group()
cells.transform (Snap.matrix 1, 0, 0, 1, 25, 25)

f =
  pack: (x,y) -> (y & 0xffff) << 16 | x & 0xffff

  unpack: (cell) -> [(cell << 16) >> 16, cell >> 16]

  render: (x, y) ->
    cells.add (world.rect x, y, 1, 1)
    return true

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

alive = {}
alive[f.pack x,y] = [x,y] for [x,y] in pattern.initial

f.render x,y for k, [x,y] of alive

world.click () ->
  ++generation
  console.log generation
  alive = f.evolve alive
  (cells.selectAll 'rect').remove()
  f.render x,y for k, [x,y] of alive
