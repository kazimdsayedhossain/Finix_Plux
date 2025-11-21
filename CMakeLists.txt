# ============================================================================
# FinixPlayer – Modern Qt 6 Audio Player with Complete OOP Implementation
# ============================================================================
cmake_minimum_required(VERSION 3.22)
project(FinixPlayer
    VERSION 1.0.0
    DESCRIPTION "Modern audio player with complete OOP implementation"
    LANGUAGES CXX
)

# ----------------------------------------------------------------------------
# C++ Standard Requirements
# ----------------------------------------------------------------------------
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ----------------------------------------------------------------------------
# Qt Configuration
# ----------------------------------------------------------------------------
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Find required Qt6 modules
find_package(Qt6 6.10 REQUIRED COMPONENTS
    Core
    Quick
    Multimedia
    Widgets
    Core5Compat
    Qml
)

# Setup project-wide Qt defaults
qt_standard_project_setup()

# ----------------------------------------------------------------------------
# Source Files
# ----------------------------------------------------------------------------
set(PROJECT_SOURCES
    main.cpp
    AudioController.cpp
    AudioController.h
    Track.cpp
    Track.h
    Playlist.cpp
    Playlist.h
    MusicLibrary.cpp
    MusicLibrary.h
    AudioEffect.cpp
    AudioEffect.h
    LibraryModel.cpp
    LibraryModel.h
    AudioException.h
    AudioUtils.h
    CircularBuffer.h
    Cache.h
)

# ----------------------------------------------------------------------------
# QML Files
# ----------------------------------------------------------------------------
set(PROJECT_QML_FILES
    main.qml
)

# ----------------------------------------------------------------------------
# Resources
# ----------------------------------------------------------------------------
set(PROJECT_RESOURCES
    resources.qrc
)

# ----------------------------------------------------------------------------
# Executable Target
# ----------------------------------------------------------------------------
qt_add_executable(${PROJECT_NAME}
    ${PROJECT_SOURCES}
    ${PROJECT_RESOURCES}
)

# ----------------------------------------------------------------------------
# QML Module Configuration
# ----------------------------------------------------------------------------
qt_add_qml_module(${PROJECT_NAME}
    URI FinixPlayer
    VERSION 1.0
    QML_FILES ${PROJECT_QML_FILES}
    RESOURCE_PREFIX "/qt/qml"
)

# ----------------------------------------------------------------------------
# Link Libraries
# ----------------------------------------------------------------------------
target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Core
        Qt6::Quick
        Qt6::Multimedia
        Qt6::Widgets
        Qt6::Core5Compat
        Qt6::Qml
)

# ----------------------------------------------------------------------------
# Compiler Warnings and Options
# ----------------------------------------------------------------------------
if(MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE /W4)
else()
    target_compile_options(${PROJECT_NAME} PRIVATE
        -Wall -Wextra -Wpedantic
    )
endif()

# ----------------------------------------------------------------------------
# Platform-Specific Settings
# ----------------------------------------------------------------------------
set_target_properties(${PROJECT_NAME} PROPERTIES
    WIN32_EXECUTABLE ON
    MACOSX_BUNDLE ON
)

# ----------------------------------------------------------------------------
# Import QML plugins
# ----------------------------------------------------------------------------
qt_import_qml_plugins(${PROJECT_NAME})

# ----------------------------------------------------------------------------
# Debug Info
# ----------------------------------------------------------------------------
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(STATUS "===========================================")
    message(STATUS "FinixPlayer Configuration:")
    message(STATUS "  Qt Version: ${Qt6_VERSION}")
    message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
    message(STATUS "  C++ Standard: ${CMAKE_CXX_STANDARD}")
    message(STATUS "  Install Prefix: ${CMAKE_INSTALL_PREFIX}")
    message(STATUS "  Source Files: ${PROJECT_SOURCES}")
    message(STATUS "===========================================")
endif()
