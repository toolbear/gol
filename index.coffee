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
    census = {}
    next_gen = {}
    for k, cell of alive
      [fit, census] = f.fit k, cell, census
      next_gen[k] = cell if fit
    next_gen

  fit: (k, [x,y], census) ->
    population = census[k] ?= f.survey x,y
    [2 < population < 5, census]

  survey: (x,y) ->
    population = 0
    for nx in [x-1..x+1]
      population++ for ny in [y-1..y+1] when alive[f.pack nx,ny]?
    population

alive = {}
alive[f.pack x,y] = [x,y] for [x,y] in pattern.initial

f.render x,y for k, [x,y] of alive

world.click () ->
  ++generation
  console.log generation
  alive = f.evolve alive
  (cells.selectAll 'rect').remove()
  f.render x,y for k, [x,y] of alive
