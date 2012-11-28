% compute the hough accumulation image
% params:
%  edge - the edge image
%  theta - a list [theta_min, d_theta,  theta_max]
% returns:
%  accum - the accumulator image
%  rho - a list [rho_min, d_rho, rho_max]
function [accum,rho] = hough( edge , theta )

%dtheta = theta ./ accum_size(1)
%drho = rho ./ accum_size(2)

accum_x = ceil((theta(3)-theta(1))/theta(2)) + 1;

rho_max = ceil(norm(size(edge)));
rho_min = 0;
d_rho = rho_max/accum_x;
rho = [rho_min, d_rho, rho_max];
accum_y = accum_x;

accum = zeros(accum_x,accum_y);

for x=1:size(edge,1)
  for y=1:size(edge,2)
    if edge(x,y) > 0
      theta_i = 1;
      for t=theta(1):theta(2):theta(3)
        r = x * cos(t) + y * sin(t);
        rho_i = ceil((r-rho(1))/rho(2));
        accum(theta_i,rho_i) = accum(theta_i,rho_i) + 1;
        theta_i = theta_i + 1;
      end
    end
  end
end

