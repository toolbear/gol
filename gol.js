(function() {
  var centered = Snap.matrix(1, 0, 0, 1, 25, 25)

  snap = Snap('#world')
  snap.attr({
    preserveAspectRatio: "xMidYMid meet"
    , viewBox: "0 0 50 50"
  })

  snap
    .rect(0,0,1,1)
    .transform(centered)
})(this)
