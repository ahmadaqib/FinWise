cmake_minimum_required(VERSION 3.10.2)

project(game_engine)

add_library( # Sets the name of the library.
             game_engine

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             ../../../../ios/Runner/game_engine.cpp )

target_link_libraries( # Specifies the target library.
                       game_engine

                       # Links the target library to the log library
                       # included in the NDK.
                       android
                       log )
