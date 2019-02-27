function matup = up(mat)
[r,c,d]=size(mat);
%if (rem2 ~=0) Val=[Val;
% w = r*2-1 ;
% h = c*2-1 ;
% temp=zeros(w,h);
% y(1:2:w,1:2:h) = Val;
% y(2:2:w,2:2:h) = Val(1:r-1,1:c-1);
% y(1:2:w,2:2:h) = Val(1:r  ,1:c-1);
% y(2:2:w,1:2:h) = Val(1:r-1,1:c  );
% 
% V=y;
w = r*2 ;
h = c*2 ;
%temp =zeros(w,h,d);
temp(1:2:w,1:2:h,1:3) = mat(:,:,1:3);
temp(2:2:w,2:2:h,1:3) = mat(:,:,1:3);
temp(1:2:w,2:2:h,1:3) = mat(:,:,1:3);
temp(2:2:w,1:2:h,1:3) = mat(:,:,1:3);
matup = temp;