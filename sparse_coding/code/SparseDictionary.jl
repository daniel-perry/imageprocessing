# 
# Copyright (c) 2013 Daniel Perry
#

module SparseDictionary

export matchingPursuit,orthogonalPursuit,kSVD

# function matchingPursuit(F, D, lambda)
#params:
# F - original signal
# D - sparse dictionary
# lambda - number of elements in sparse representation
#returns:
# sparse representation
function matchingPursuit(F, D, lambda)

  F = F[:]
  R = F # initial residual

  x = zeros(size(D,2))
  for n=1:lambda
    #print(n,",")
    max_similarity = 0.0
    max_i = 0.0
    for i=1:size(D,2)
      if x[i] == 0 # this dictionary element not already used..
        g = D[:,i]
        similarity = (g' * R)[1]
        if abs(similarity) > (max_similarity)
          max_similarity = similarity
          max_i = i
        end
      end
    end
    x[max_i] = max_similarity
    #update residual:
    R = D*x - F
  end
  x
end # end function

function orthogonalPursuit(F,D,lambda)
  println("Not yet implemented..")
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
        E_total = zeros(l,k)
        for m=1:n
          if m != j
            E_total += D[:,m] * X[m,:]
          end
        end
        E_total = F - E_total
        E_restricted = E_total[:,w] # (l,nnz)
        U,S,V = svd( E_restricted )
        D[:,j] = U[:,1]  # update dictionary column
        X[j,w] = V[:,1] * S[1,1] # update non-zero elements of row of X
      end
    end
  end
  println("\nkSVD done.")
  X,D
end # end function

end # end module
