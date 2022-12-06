[rossum]: https://github.com/kobbled/rossum
[ktransw]: https://github.com/kobbled/ktransw_py
[GPP]: https://github.com/logological/gpp
[here]: https://github.com/kobbled/rossum/releases
[TP-Plus]: https://github.com/kobbled/tp_plus
[yamljson2xml]: https://github.com/kobbled/yamljson2xml
[Ka-Boost]: https://github.com/kobbled/Ka-Boost

# Ka-Boost

This is repository of a collection of FANUC Karel libraries. Each package is formatted to work with the karel package manager [rossum].

> [!**IMPORTANT**]
> Documentation is currently fairly sparse. If no documentation exists for the package, look in the **"/tests"** folder for usage.

> [!**IMPORTANT**]
> Some modules are formatted as classes or templates, and can be identified with the _".klc"_ file extension. These heavily use the preprocessor [GPP] in order to define generics, as generics are not a part of the Karel language. Definition of the generics can be found in the **"/tests/config"** folder in each module.

## Dependencies

* Install [rossum] (https://github.com/kobbled/rossum). Alternatively, a convenience distribution can be downloaded [here].
* Install [TP-Plus] (https://github.com/kobbled/tp_plus) to use high level functionality for creating TP programs.

> [!**NOTE**]
> [TP-Plus] is not required to use rossum, regular **TP/LS** files are also supported.

* yaml/json conversion to xml is also supported with the [yamljson2xml] package. This doesn't need to be installed independently as it is included with [rossum].

> [!**WARNING**]
> While reading xml is supported in karel, and a helper package [kl-xml](https://github.com/kobbled/kl-xml) is included in [Ka-Boost], xml handling is still very difficult. Look through the test examples, and note the formatting of the xml file, and their corresponding karel structs.


## Install

To install all of Ka-Boost's modules use:

```shell
  git clone https://github.com/kobbled/Ka-Boost --recurse-submodules
```

Add the path where this is stored to the environment variable **ROSSUM_PKG_PATH** to start using.

## Building
  
* Open the root folder of the interested package in a terminal.
* Set your roboguide configuration with:
```shell
del /f robot.ini
setrobot
```
* Create a build directory
```
mkdir build && cd build
```

Build and send to robot with the following:

- Build all source files
```
rossum .. -w -o
ninja
kpush
```

- Build all source files and tests. (This will include assosiated objects in the tests)
```
rossum .. -w -o -t
ninja
kpush
```

- Build all dependencies
```
rossum .. -w -o -b
ninja
kpush
```

### Removing off of controller

All files in the build directory can be removed with:

```
kpush --delete
```

Alternatively the support folder **/scripts** contains windows batch files to remove all of the programs found in [Ka-Boost] from the controller. They can be run with:

```
cd ./scripts
./master_del.bat
```

> [!**IMPORTANT**]
> Cross dependencies in [Ka-Boost] can sometimes lead to a `MEMO-128 parameters are different` error when trying to load the new programs onto the controller. This is specifically a problem when using the [kl-draw](https://github.com/kobbled/kl-draw), and [kl-paths](https://github.com/kobbled/kl-paths) modules, as they are the most complicated. The best course of action is to run `master_del.bat`, and `master_test_del.bat`.

> [!**NOTE**]
> Delete test programs off the controller with 
> ```
> cd ./scripts
> ./master_test_del.bat
> ```
> They take up space, and are only useful for illustration/usage purposes.

## Getting Started

[rossum_examples_ws]: https://github.com/kobbled/rossum_example_ws

Use [rossum_examples_ws] as a basic introduction to using [rossum], and [Ka-Boost]. Proper documentation, and tutorials should be added. 


