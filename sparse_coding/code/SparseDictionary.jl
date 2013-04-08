# 
# Copyright (c) 2013 Daniel Perry
#

module SparseDictionary

export matchingPursuit,orthogonalPursuit,kSVD,kSVDDenoising

using MAT

# function matchingPursuit(F, D, lambda)
#params:
# F - original signal
# D - sparse dictionary
# lambda - max number of elements in sparse representation
#returns:
# sparse representation
function matchingPursuit(F, D, lambda)

  F = F[:]
  R = F # initial residual

  x = zeros(size(D,2))
  alphas = x
  ind = Array(Int64,0)
  for n=1:lambda
    similarity = abs(D' * R)
    maxVal,maxLoc = findmax(similarity)
    try
      ind = [ind, maxLoc[1]]
    catch
      # try doing it a different way:
      tmp = zeros(Int64,length(ind)+1)
      for i=1:length(ind)
        tmp[i] = ind[i]
      end
      tmp[length(tmp)] = maxLoc[1]
      ind = tmp
    end
    alphas = pinv(D[:,ind[1:n]]) * F
    R = F - D[:,ind[1:n]]*alphas
    if sum(R.^2) < 1e-20
      break
    end
  end
  x[ind] = alphas
  x
end # end function

# function kSVD(F, D, lambda)
#params:
# F - original signal, F= [ F_1 F_2 ... F_k ] , F_i \in R^l            (l,k)
# D - initial sparse dictionary D = [ D_1 D_2 ... D_n ] , D_i \in R^l  (l,n)
# lambda - number of elements in sparse representation
# maxIters - maximum iterations
#returns:
# (X, D)
# X - sparse representation, X = [ X_1 X_2 ... X_k ], X_i \in R^n    (n,k)
# D - sparse dictionary                                              (l,n)
function kSVD(F, D, lambda, maxIters)
  # make sure columns of D or normalized using L2 norm:
  for i=1:size(D,2)
    D[:,i] = D[:,i] / norm(D[:,i],2)
  end

  l = size(F,1) # size of a single signal or atom
  n = size(D,2) # number of dictionary atoms
  k = size(F,2) # number of signals 

  println("INFO: number of atoms = ",n)
  println("INFO: number of signals = ",k)

  X = zeros(n,k) # sparse representation  nxk

  mse = 1e5 # init to something big
  last_mse = mse
  last_last_mse = mse

  for i=1:maxIters
    println("\n",i)
    # sparse coding step:
    println("sparse coding step")
    for j=1:k # each column of X,F
      if j%100 == 0
        print(".") # progress...
      end
      X[:,j] = matchingPursuit(F[:,j],D,lambda)
    end
    # codebook update step:
    println("\ncodebook update step")
    for j=1:n # each column of D
      if j%100 == 0
        print(".") # progress...
      end
      tmp = [X[j,ii] > 0 for ii=1:size(X,2)] # which atoms are being used  (1,k)
      w = find(tmp)
      if length(w) > 0 # only update if this atom is used
        D_sub = [D[:,1:j-1] D[:,j+1:]]
        X_sub = [X[1:j-1,:]; X[j+1:,:]]
        E_total = D_sub * X_sub
        E_total = F - E_total
        E_restricted = E_total[:,w] # (l,nnz)
        failed = true
        U = Array(Float64, (1,1)) #(size(E_restricted,1),size(E_restricted,1)) )
        S = Array(Float64, (1,1)) #(size(E_restricted,1),size(E_restricted,1)) )
        V = Array(Float64, (1,1)) #(size(E_restricted,2),size(E_restricted,2)) )
        try
          U,S,V = svd( E_restricted )
          failed = false
        catch
          failed = true
        end
        if failed
          # try it with matrix transposed
          # (as indicated here: http://r.789695.n4.nabble.com/Observations-on-SVD-linpack-errors-and-a-workaround-td837282.html)
          try
            V,S,U = svd( E_restricted' )
            #V = V'
            #U = U'
            failed = false
          catch
            failed = true
          end
        end
        if failed
          error("ERROR: svd(E) and svd(E') failed!")
        end

        try
        D[:,j] = U[:,1]  # update dictionary column
        X[j,w] = V[:,1] * S[1,1] # update non-zero elements of row of X
        catch
          println("size(E_restricted)=",size(E_restricted))
          println("size(D[:,j])=",size(D[:,j]))
          println("size(U[:,1])=",size(U[:,1]))
          println("size(X[j,w])=",size(X[j,w]))
          println("size(V[:,1])=",size(V[:,1]))
          error("Failed to update")
        end
      end
    end

    # check for convergence
    last_last_mse = last_mse
    last_mse = mse
    mse = normfro(F-D*X)
    println()
    println("last_mse = ",last_mse)
    println("mse = ",mse)
    println("|last_mse-mse| = ",abs(mse-last_mse))
    if abs(last_mse-mse) < 0.01 || abs(last_last_mse-mse) < 0.01
      println("INFO: kSVD converged in ",i," iterations.")
      break 
    end
  end
  println("\nINFO: kSVD done.")
  X,D
end # end function

# chunk up an image, into overlapping patches
function enChunk(image,patchRadius)
  chunkSize = [1+2*patchRadius 1+2*patchRadius]
  chunkLength = chunkSize[1] * chunkSize[2]
  imageSize=size(image)
  chunks = Array(Float32, (chunkLength,0) )
  for r=patchRadius+1:imageSize[1]-patchRadius
    for c=patchRadius+1:imageSize[2]-patchRadius
      chunk = image[r-patchRadius:r+patchRadius,c-patchRadius:c+patchRadius]
      chunks = [chunks chunk[:]]
    end
  end
  chunks
end

# combine overlapping patches into a full image, by using the average of each patch
function deChunk(F,patchRadius,imageSize)
  chunkSize = [1+2*patchRadius 1+2*patchRadius]
  image = zeros(imageSize)
  ind = 1
  for r=patchRadius+1:imageSize[1]-patchRadius
    for c=patchRadius+1:imageSize[2]-patchRadius
      chunk = F[:,ind]
      image[r,c] = mean(chunk)
      ind = ind + 1
    end
  end
  image
end

function loadCache()
  cache = Dict{String,Array{Float64,2}}()
  if isfile("chunkcache.mat")
    file = matopen("chunkcache.mat")
    #cachekeys = read(file,"cachekeys")
    #cachevals = read(file,"cachevals")
    cache = read(file,"cache")
    close(file)
    #for k,v in zip(cachekeys,cachevals)
    #  cache[k] = v
    #end
  end
  cache
end
function saveCache(cache)
  file = matopen("chunkcache.mat","w")
  #cachekeys = keys(cache)
  #cachevals = values(cache)
  #write(file,"cachekeys",cachekeys)
  #write(file,"cachevals",cachevals)
  write(file,"cache",cache)
  close(file)
end

# function kSVDDenoising(I, D, lambda)
#params:
# filename - filename
# I - original noisy image
# D - initial sparse dictionary 
# lambda - number of elements in sparse representation
# maxIters - maximum iterations
# patchRadius - radius of patches for denoising
#returns:
# (DI, D)
# DI - denoised image
# D - resuling sparse dictionary 
function kSVDDenoising(filename, I, D, lambda, maxIters, patchRadius)
  println("INFO: chunking image into patches")
  cache = loadCache()
  F = zeros(Float64, (1,1))
  if has(cache,filename)
    println("loading patches from cache...")
    F = cache[filename]
  else
    F = enChunk( I, patchRadius )
    cache[filename] = F
    saveCache(cache)
  end

  println("INFO: running kSVD")
  X,D = kSVD( F, D, lambda, maxIters )

  println("INFO: rebuilding image from patch means")
  DI = deChunk( D*X, patchRadius, size(I) )
  DI,D
end # end function


end # end module
