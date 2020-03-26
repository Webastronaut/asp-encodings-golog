gst(0, seq(1,2)).
gst(1, star(3)).
gst(2, seq(4,5)).
gst(3, or(6,7)).
gst(4, test(8)).
gst(5, seq(9,10)).
gst(6, move(R,D)) :- agent(R),direction(D).
gst(7, seq(11,12)).
	fst(8, 0, robot_under_shelf_with_ordered_products(R,S,P,O)) :- isRobot(R),isShelf(S),isProduct(P),isOrder(O).
gst(9, pickup(R,S)) :- isRobot(R),isShelf(S).
gst(10, seq(13,14)).
gst(11, test(15)).
gst(12, wait(R)) :- agent(R).
gst(13, star(16)).
gst(14, seq(17,18)).
	fst(15, 0, and(1,2)).
	fst(15, 1, not_on_highway(R)) :- agent(R).
	fst(15, 2, neg(3)).
	fst(15, 3, robot_on_pickingstation(R)) :- agent(R).
gst(16, or(19,20)).
gst(17, test(21)).
gst(18, seq(22,23)).
gst(19, move(R,D)) :- agent(R),direction(D).
gst(20, seq(24,25)).
	fst(21, 0, and(1,2)).
	fst(21, 1, shelf_not_on_highway(S)) :- isShelf(S).
	fst(21, 2, neg(3)).
	fst(21, 3, robot_on_pickingstation(R)) :- agent(R).
gst(22, putdown(R,S)) :- isRobot(R),isShelf(S).
gst(23, seq(26,27)).
gst(24, test(28)).
gst(25, wait(R)) :- agent(R).
gst(26, test(29)).
gst(27, star(30)).
	fst(28, 0, and(1,2)).
	fst(28, 1, not_on_highway(R)) :- agent(R).
	fst(28, 2, neg(3)).
	fst(28, 3, robot_on_pickingstation(R)) :- agent(R).
	fst(29, 0, all_delivered).
gst(30, wait(R)) :- agent(R).