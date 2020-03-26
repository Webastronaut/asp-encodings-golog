gst(0, seq(1,2)).
gst(1, star(3)).
gst(2, seq(4,5)).
gst(3, seq(6,7)).
gst(4, test(8)).
	fst(8, 0, neg(1)).
	fst(8, 1, on(N)) :- floor(N).
gst(5, seq(9,10)).
gst(6, test(11)).
	fst(11, 0, on(N)) :- floor(N).
gst(7, seq(12,13)).
gst(9, star(14)).
gst(10, seq(15,16)).
gst(12, or(17,18)).
gst(13, seq(19,20)).
gst(14, down(E,0)) :- elevator(E).
gst(15, test(21)).
	fst(21, 0, current_floor(E,0)) :- elevator(E).
gst(16, seq(22,23)).
gst(17, up(E,N)) :- elevator(E),floor(N).
gst(18, down(E,N)) :- elevator(E),floor(N).
gst(19, turnoff(E,N)) :- elevator(E),floor(N).
gst(20, seq(24,25)).
gst(22, open(E)) :- elevator(E).
gst(23, star(26)).
gst(24, open(E)) :- elevator(E).
gst(25, close(E)) :- elevator(E).
gst(26, idle(E)) :- elevator(E).