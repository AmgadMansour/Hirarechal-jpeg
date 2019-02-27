function matdown = down (mat)
	[r,c,d]=size(mat);
	y = 1:2:c;                   
	x = 1:2:r;
	matdown = mat(x,y,1:3); 