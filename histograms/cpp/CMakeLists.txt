PROJECT( emgmm )
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

#FIND_PACKAGE(VTK REQUIRED)
#IF (VTK_FOUND)
# INCLUDE( ${USE_VTK_FILE} )
#ENDIF(VTK_FOUND)

#find_package(OpenCV REQUIRED)

#FIND_PACKAGE(Boost REQUIRED)
#link_directories ( ${Boost_LIBRARY_DIRS} )
#include_directories ( ${Boost_INCLUDE_DIRS} )

SET(CMAKE_INCLUDE_CURRENT_DIR ON)

# emgmm
SET( emgmm_SRCS
     emgmm.cc
)

SET( emgmm_HDRS
     emgmm.h
)


ADD_EXECUTABLE( emgmm
                ${emgmm_SRCS}
                ${emgmm_HDRS}
				      )

TARGET_LINK_LIBRARIES(  emgmm
                        ${ITK_LIBRARIES}
                     ) 

# emgmm_md - multi-dimensional version
SET( emgmm_md_SRCS
     emgmm_md.cc
)

SET( emgmm_md_HDRS
     emgmm_md.h
)


ADD_EXECUTABLE( emgmm_md
                ${emgmm_md_SRCS}
                ${emgmm_md_HDRS}
				      )

TARGET_LINK_LIBRARIES(  emgmm_md
                        ${ITK_LIBRARIES}
                     ) 

