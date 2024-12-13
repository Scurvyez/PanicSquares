extends Node

## --------------------------------/+\--------------------------------
## math_util.gd
## 
## This script simply contains a couple (for now) math functins used 
## for smoother and more lively animations.
## --------------------------------\+/--------------------------------

func easeInOutSine(t):
	return -(cos(PI * t) - 1.0) / 2.0;


func easeInOutBack(t):
	const c1 = 1.70158;
	const c2 = c1 * 1.525;
	
	if t < 0.5:
		return (pow(2.0 * t, 2.0) * ((c2 + 1.0) * 2.0 * t - c2)) / 2.0
	else:
		return (pow(2.0 * t - 2.0, 2.0) * ((c2 + 1.0) * (t * 2.0 - 2.0) + c2) + 2.0) / 2.0;
