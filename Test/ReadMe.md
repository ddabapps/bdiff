# BDiff / BPatch Tests

This directory contains a set of tests of _BDiff_ and _BPatch_. They are run by calling the `Test.bat` script with various command line parameters.

## Requirements

1. `Test.bat` must _either_ be run from a command line console which has its current directory set to the directory that contains `Test.bat`, _or_ from helper scripts named `Test32.bat` and `Test64.bat` (see [Helper Scripts](#helper-scripts) below for details).

2. The `BDIFFPATH` environment variable must be set to the directory containing both `BDiff.exe` and `BPatch.exe`. `Test.bat` uses this environment variable to find the correct versions of the programs to test. This enables you to test any version of _BDiff_ and _BPatch_ on your system, prodiving they are both in the same directory.

    > Note that `Test32.bat` and `Test64.bat` will set `BDIFFPATH` for you.

    `Test.bat` will stop with an error if `BDIFFPATH` is not set or if either of `BDiff.exe` or `BPatch.exe` is not in the directory stored in `BDIFFPATH`.

3. Files named `Test1`, `Test2`, `Test1_Large`, `Test2_Large`, `Test1_Huge` and `Test2_Huge` are provided. They must be located in the same directory as `Test.bat`.

    `Test1` and `Test2` are different versions of the same file and are both smaller than 64KiB. ***They must not be modified***.
    
    `Test1_Large` and `Test2_Large` are different versions of the same file and are larger than 128KiB. These files _may_ be modified, but must remain different to each other and both must be larger than 128KiB.

    `Test1_Huge` and `Test2_Huge` are different versions of the same file and are larger than 10MiB. These files _may_ be modified, but must remain different to each other and both must be larger than 10MiB.

4. Files named `Diff-b`, `Diff-f` and `Diff-q`are provided. They must be in the same directory as `Test.bat` and ***must not be modified***. These files are used to check for the expected output from `test patch`, `test quoted` and `test filtered`, respectively. The tests will fail if these files or `Test1` or `Test2` have been modified.

## Tests

### Patching tests

#### Small file test

Run the test by entering the command: 

    Test patch
    
_BDiff_ is run on `Test1` and `Test2` and creates a binary diff file named `Patch`. _BPatch_ then applies `Patch` to `Test1` to create `Test3`, which should be identical to `Test2`. The Windows _FC_ command is used to verify that `Test2` and `Test3` are in fact the same and that `Patch` is the same as `Diff-p`.

#### Large file test

Run the test by entering the command: 

    Test patch large
    
_BDiff_ is run on `Test1_Large` and `Test2_Large` and creates a binary diff file named `Patch_Large`. _BPatch_ then applies `Patch_Large` to `Test1_Large` to create `Test3_Large`, which should be identical to `Test2_Large`. The Windows _FC_ command is used to verify that `Test2_Large` and `Test3_Large` are in fact the same.

#### Huge (> 10Mib) file test

> ⚠️ This test can take a **long time** - several minutes on the test machine.

Run the test by entering the command: 

    Test patch huge

Because of the time required for the test the user is prompted for permission to continue. Once this is given the test proceeds as follows.
    
_BDiff_ is run on `Test1_Huge` and `Test2_Huge` and creates a binary diff file named `Patch_Huge`. Because the files exceed _BDiff_'s normal 10MiB file size limit, _BDiff_ is called with the `--permit-large-files` parameter that permits the size limit to be exceeded. _BPatch_ then applies `Patch_Huge` to `Test1_Huge` to create `Test3_Huge`, which should be identical to `Test2_Huge`. The Windows _FC_ command is used to verify that `Test2_Huge` and `Test3_Huge` are in fact the same.

### Quoted format diff test

Run the test by entering the command: 

    Test quoted

or

    Test quoted view
    
_BDiff_ is run on `Test1` and `Test2` and creates a quoted text diff file named `Diff` that is compared against the expected content in `Diff-q`.

If the optional `view` parameter is provided `Diff` is displayed in _NotePad_.

### Filtered format diff test

Run the test by entering the command: 

    Test filtered
    
or

    Test filtered view

_BDiff_ is run on `Test1` and `Test2` and creates a filtered text diff file named `Diff` that is compared against the expected content in `Diff-f`.

If the optional `view` parameter is provided `Diff` is displayed in _NotePad_.

### Version test

Run the test by entering the command: 

    Test version
    
Both _BDiff_ and _BPatch_ are called with the `--version` option and both output their current version on the console. You should check that they report the expected version numbers.

### Help test

Run the test by entering the command: 

    Test help

Both _BDiff_ and _BPatch_ are called with the `--help` option and both output their help screen on the console.

### Clean up

To delete all the temporary files that were generated when running tests enter the command:

    Test clean

## Helper scripts

The most common use case for `Test.bat` is to test the programs that have just been compiled. For this reason two helper script files are provided. They are:

1. `Test32.bat` - tests 32 bit builds
2. `Test64.bat` - tests 64 bit builds

Both scripts take the same commands as `Test.bat`. Run `Test32 help` or `Test64 help` to see a list of the available commands.

These scripts set the `%BDIFFPATH%` environment variable to the directories where the compiler outputs the 32 bit and 64 bit Windows executables, respectively. Both scripts then call `Test.bat`, passing along all parameters.

### Requirements

* The scripts must be in the `Test` directory, along with `Test.bat`.
* The `Test` directory must have the same parent directory as the `_build` directory that is created by the compiler.
* The executable programs must exist in the subdirectories of `_build` specified by the Delphi project file.

## Examples

### Example 1

Suppose the versions of _BDiff_ and _BPatch_ to be tested are in `C:\Utils` and you want to:

1. check the version of the programs
2. perform the Patch test
3. clear up the generated files.

Assume that `Test.bat` is located in `D:\BDiff\Test`.

Open a command console then enter the following commands. In the following, items preceded by `>` are the commands you type and any following text represents the output (your output may vary).

    >cd D:\BDiff\Test
    
    >D:
    
    >set BDIFFPATH=C:\Utils
   
    >test version
    BDiff-v1.0.0 2025-12-01 (Windows 64 bit)
    BPatch-v1.0.0 2025-12-01 (Windows 64 bit)
    Done

    >test patch
    --- Creating binary Patch with bdiff ---
    BDiff.exe: loading old file
    BDiff.exe: loading new file
    BDiff.exe: block sorting old file
    BDiff.exe: generating patch
    BDiff.exe: done

    --- Testing Patch against expected Diff-b with fc ---
    Comparing files Patch and DIFF-B
    FC: no differences encountered

    --- Applying binary Patch with bpatch ---

    --- Testing restored Test3 file against original with fc ---
    Comparing files Test2 and TEST3
    FC: no differences encountered


    Done

    >test clean
    Done

### Example 2

Assume that `Test.bat` and `Test64.bat` are both in `D:\BDiff\Test` and that Delphi has compiled the 64 bit build of the programs into `D:\BDiff\_build\Win64\exe`. You can test the latest 64 bit versions of the programs with the following:

    >cd D:\BDiff\Test
    
    >D:

    >test64 version
    BDiff-v1.0.0 2025-12-01 (Windows 64 bit)
    BPatch-v1.0.0 2025-12-01 (Windows 64 bit)
    Done
    
    >test64 patch
    << output omitted: same as example 1 >>

    >test64 clean
    Done

### Example 3

Assume that `Test.bat` and `Test32.bat` are both in `D:\BDiff\Test` and that Delphi has compiled the 32 bit build of the programs into `D:\BDiff\_build\Win32\exe`. You can test the latest 32 bit versions of the programs with the following:

    >cd D:\BDiff\Test
    
    >D:

    >test32 version
    BDiff-v1.0.0 2025-12-01 (Windows 32 bit)
    BPatch-v1.0.0 2025-12-01 (Windows 32 bit)
    Done

    >test32 patch
    << output omitted: same as example 1 >>

    >test32 clean
    Done
