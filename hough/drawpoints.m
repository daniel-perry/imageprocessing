% draw points at detected maxima on the accumulator image
function result = drawpoints( accum_rescaled, params, theta, rho )

circle_rad = 5;
point_color = uint8([255 0 0]);

result = uint8(zeros(size(accum_rescaled,1),size(accum_rescaled,2),3)); %rgb
result(:,:,1) = accum_rescaled;
result(:,:,2) = accum_rescaled;
result(:,:,3) = accum_rescaled;

for i=1:size(params,1)
  t = params(i,1);
  r = params(i,2);
  theta_i = ceil( (t-theta(1))/theta(2) )+1;
  rho_i = ceil( (r-rho(1))/rho(2) )+1;
  result(theta_i,rho_i,:) = point_color;
  % draw a circle..
  for x=theta_i-circle_rad:theta_i+circle_rad
    for y=rho_i-circle_rad:rho_i+circle_rad
      if(x > 0 && x <= size(accum_rescaled,1) && y > 0 && y <= size(accum_rescaled,2))
        if( (x-theta_i)*(x-theta_i) + (y-rho_i)*(y-rho_i) <= circle_rad*circle_rad)
          result(x,y,:) = point_color;
        end
      end
    end
  end
end
