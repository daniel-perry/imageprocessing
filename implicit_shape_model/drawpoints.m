function result = drawpoints( image, points )

circle_rad = 1;
point_color = uint8([255 0 0]);

result = uint8(zeros(size(image,1),size(image,2),3)); %rgb
result(:,:,1) = image;
result(:,:,2) = image;
result(:,:,3) = image;

for i=1:size(points,1)
  point = points(i,:);
  pt_x = point(1);
  pt_y = point(2);
  result(pt_x,pt_y,:) = point_color;
  % draw a circle..
  for x=pt_x-circle_rad:pt_x+circle_rad
    for y=pt_y-circle_rad:pt_y+circle_rad
      if(x > 0 && x <= size(image,1) && y > 0 && y <= size(image,2))
        if( (x-pt_x)*(x-pt_x) + (y-pt_y)*(y-pt_y) <= circle_rad*circle_rad)
          result(x,y,:) = point_color;
        end
      end
    end
  end
end
