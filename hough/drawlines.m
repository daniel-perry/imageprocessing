function result = drawlines( orig, params )

line_color = uint8([255 0 0]);

result = uint8(zeros(size(orig,1),size(orig,2),3)); %rgb
result(:,:,1) = orig;
result(:,:,2) = orig;
result(:,:,3) = orig;

for i=1:size(params,1)
  t = params(i,1);
  r = params(i,2);
  if t < pi/4 % closer to a vertical line
    for y=1:size(result,2)
      x = ceil((r-y*sin(t))/cos(t));
      if x>=1 && x<=size(result,1)
        result(x,y,:) = line_color;
      end
    end
  else
    for x=1:size(result,1)
      y = ceil((r-x*cos(t))/sin(t));
      if y>=1 && y <=size(result,2)
        result(x,y,:) = line_color;
      end
    end
  end
end
