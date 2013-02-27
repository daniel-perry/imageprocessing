How to build and run:

some utility scripts are included in the bin/ folder:
run_ch.sh - run chambolles algorithm
run_pd.sh - run the primal dual algorithm
run_sb.sh - run split-bregman algorithm

Each script has some preset arguments that should work,
running the script without an argument will give you 
the usage.
But you mainly need to provide the input, output,
max iterations, and number of threads.

each script runs the compiled binary "tv", generated
by following the build directions below.

To build tv:

Dependencies:
ITK (tested with v.4.2)
cmake (tested with v.2.8.7)

Fromd the code directory (where this file is located):

$ cd ../bin
$ cmake ../code
$ make

Assuming ITK installed in the default locations.
Otherwise you will need to specify its location
in the cmake command or use "ccmake" or the cmake
gui to select the location.


