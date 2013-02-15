
PROJECT( nonlinear_deblurring )
cmake_minimum_required(VERSION 2.8)  

#Match everything when analyzing dependencies
INCLUDE_REGULAR_EXPRESSION("^.*$")
OPTION (BUILD_SHARED_LIBS "Build shared libraries" OFF)

IF (WIN32 AND MSVC)
  ADD_DEFINITIONS(-D_SCL_SECURE_NO_WARNINGS)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_WARNINGS)
ENDIF (WIN32 AND MSVC)

FIND_PACKAGE(ITK REQUIRED)
IF (ITK_FOUND)
  INCLUDE (${USE_ITK_FILE})
ENDIF(ITK_FOUND)

SET(CMAKE_INCLUDE_CURRENT_DIR ON)

# tv = total variation smoothing
SET( tv_SRCS
     tv.cc
)

SET( tv_HDRS
  TotalVariationFilter.h
  TotalVariationFilter.hxx
)

ADD_EXECUTABLE( tv
                ${tv_SRCS}
                ${tv_HDRS}
				      )

TARGET_LINK_LIBRARIES(  tv
                        ${ITK_LIBRARIES}
                     ) 

