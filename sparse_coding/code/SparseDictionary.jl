# 
# Copyright (c) 2013 Daniel Perry
#

module SparseDictionary

export matchingPursuit,orthogonalPursuit

# function matchingPursuit(f, d)
#params:
# f - original signal
# d - sparse dictionary
# lambda - number of elements in sparse representation
#returns:
# sparse representation
function matchingPursuit(F, D, lambda)

  F = F[:]
  R = F # initial residual

  gamma = zeros(size(D,2))
  for n=1:lambda
    max_similarity = 0.0
    max_i = 0.0
    for i=1:size(D,2)
      if gamma[i] == 0 # this dictionary element not already used..
        g = D[:,i]
        similarity = (g' * R)[1]
        if similarity > max_similarity
          max_similarity = similarity
          max_i = i
        end
      end
    end
    gamma[max_i] = max_similarity
    #update residual:
    R = D*gamma - F
  end
  gamma
end # end function

function orthogonalPursuit(F,D,lambda)
  println("Not yet implemented..")
end # end function

end # end module
