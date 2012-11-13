function val = gauss_kernel( X, Y, sigma)
diff = X-Y;
n = norm(diff);
%val = exp( - n*n / sigma*sigma );
%note: this isn't the gauss, but seemed to give better results..
val = sigma*sigma / (n*n + sigma*sigma);

