# Locate jemalloc library
# This module defines
#  JEMALLOC_FOUND, if false, do not try to link with jemalloc
#  JEMALLOC_LIBRARIES, Library path and libs
#  JEMALLOC_INCLUDE_DIR, where to find the ICU headers
INCLUDE (CheckLibraryExists)

FIND_PATH(JEMALLOC_INCLUDE_DIR jemalloc/jemalloc.h
          HINTS
               ENV JEMALLOC_DIR
          PATH_SUFFIXES include
          PATHS
               ~/Library/Frameworks
               /Library/Frameworks
               /opt/local
               /opt/csw
               /opt/jemalloc
               /opt)

FIND_LIBRARY(JEMALLOC_LIBRARIES
             NAMES jemalloc libjemalloc
             HINTS
                 ENV JEMALLOC_DIR
             PATH_SUFFIXES lib
             PATHS
                 ~/Library/Frameworks
                 /Library/Frameworks
                 /opt/local
                 /opt/csw
                 /opt/jemalloc
                 /opt)

IF (JEMALLOC_INCLUDE_DIR AND JEMALLOC_LIBRARIES)
  # Check that the found jemalloc library has it's symbols prefixed with 'je_'
  SET(REQUIRED_LIBS_ORIGINAL ${CMAKE_REQUIRED_LIBRARIES})
  SET(CMAKE_REQUIRED_LIBRARIES ${JEMALLOC_LIBRARIES})
  CHECK_LIBRARY_EXISTS(jemalloc je_malloc "" HAVE_JE_SYMBOLS)
  SET(CMAKE_REQUIRED_LIBRARIES ${REQUIRED_LIBS_ORIGINAL})
  UNSET(REQUIRED_LIBS_ORIGINAL)

  IF(HAVE_JE_SYMBOLS)
    SET(JEMALLOC_FOUND true)
    MESSAGE(STATUS "Found jemalloc in ${JEMALLOC_INCLUDE_DIR} : ${JEMALLOC_LIBRARIES}")
  ELSE(HAVE_JE_SYMBOLS)
    MESSAGE(STATUS "Found jemalloc in ${JEMALLOC_LIBRARIES}, but was built without 'je_' prefix on symbols so cannot be used.")
    MESSAGE("   (Consider installing pre-built package from cbdeps, by adding 'EXTRA_CMAKE_OPTIONS=-DCB_DOWNLOAD_DEPS=1' to make arguments).")
  ENDIF(HAVE_JE_SYMBOLS)
ELSE (JEMALLOC_INCLUDE_DIR AND JEMALLOC_LIBRARIES)
  SET(JEMALLOC_FOUND false)
ENDIF (JEMALLOC_INCLUDE_DIR AND JEMALLOC_LIBRARIES)

MARK_AS_ADVANCED(JEMALLOC_FOUND JEMALLOC_INCLUDE_DIR JEMALLOC_LIBRARIES)
